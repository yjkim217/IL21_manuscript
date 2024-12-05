#!/bin/bash
# FastQC, read trimming, alignments

folder=$( dirname $0 )
project=$( basename $folder )

genome=/PATH/TO/bowtie2index/UCSC.mm10/UCSC_mm10_bowtie2_index
adaptorFilePath=/PATH/TO/TRIMMOMATIC/adapters/TruSeq3-PE-2.fa
spikeingenome=/PATH/TO/bowtie2index/sacCer3/sacCer3_bowtie2_index

# Run FastQC on untrimmed ####################################################
mkdir ${folder}/fastqc_untrimmed/
for i in ${folder}/Sample_*/*ALL.fastq.gz
do
    if [ -f "$i" ]; then
      fastqc -o ${folder}/fastqc_untrimmed/ -t 20 $i
    else
      exit
    fi
done
wait

# Trim fastq ##################################################################
for i in ${folder}/Sample_*
do
F1=( $i/*R1_ALL.fastq.gz )
F2=( $i/*R2_ALL.fastq.gz )
java -jar /PATH/TO/TRIMMOMATIC/trimmomatic-0.39.jar PE \
	-threads 20 \
	$F1 \
	$F2 \
  ${F1/R1_ALL/R1_trimmed} \
  ${F1/R1_ALL/R1_trimmed_UP} \
  ${F2/R2_ALL/R2_trimmed}  \
  ${F2/R2_ALL/R2_trimmed_UP} \
	ILLUMINACLIP:${adaptorFilePath}:2:15:4:4:true \
	LEADING:20 TRAILING:20 SLIDINGWINDOW:4:15 MINLEN:25 2>> $i/trim_report.txt
done
wait

# Run FastQC on trimmed ####################################################
mkdir ${folder}/fastqc_trimmed/
for i in ${folder}/Sample_*/*trimmed.fastq.gz
do
    if [ -f "$i" ]; then
      fastqc -o ${folder}/fastqc_trimmed/ -t 20 $i
    else
      exit
    fi
done
wait

# Alignments - dovetail on ##################################################################
### Bowtie2 to make sorted bam files
# dovetail on
mkdir -p ${folder}/bam_dovetailON/
for i in ${folder}/Sample_*
do
    name=$(basename $i)
    echo "$name"
    F1=( $i/*R1_trimmed.fastq.gz )
    F2=( $i/*R2_trimmed.fastq.gz )
    bowtie2 --dovetail --phred33 -p 20 --met-file ${folder}/bam_dovetailON/${name}_metrics.txt -x $genome -1 $F1 -2 $F2 2>> ${folder}/bam_dovetailON/${name}_align.log | \
    samtools view -Sh -F 0x04 -f 0x02 -@ 20 - | \
    samtools sort -o ${folder}/bam_dovetailON/${name}.bam -O bam -T $i/temp.bam -@ 20 - 2>> ${folder}/bam_dovetailON/${name}_align.log

    java -jar /PATH/TO/PICARD/picard-2.23.0/picard.jar MarkDuplicates \
        I=${folder}/bam_dovetailON/${name}.bam O=${folder}/bam_dovetailON/${name}_dupMark.bam \
        M=${folder}/bam_dovetailON/${name}_dupMark_metrics.txt \
        REMOVE_DUPLICATES=false \
        OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 \
        USE_JDK_DEFLATER=true USE_JDK_INFLATER=true 2> ${folder}/bam_dovetailON/${name}_dupMark.log

    ## check to see that there are the same number of reads in marked BAM and og BAM

    unmarked=$( samtools view -c -@ 20 ${folder}/bam_dovetailON/${name}.bam )
    marked=$( samtools view -c -@ 20 ${folder}/bam_dovetailON/${name}_dupMark.bam )

    if [ "$unmarked" == "$marked" ]; then
        echo "---Duplicate-marked BAM file successfully made. Removing unmarked BAM."
        rm ${folder}/bam_dovetailON/${name}.bam
    else
        echo "---Something went wrong with duplicate marking."
        exit
    fi

done
wait

# generate bai files ##################################################################
for i in ${folder}/bam_dovetailON/*.bam
do
   samtools index $i
done

wait


# Alignments - spikein bam ##################################################################
# Align to spikein bam - S. Cerevisiae
mkdir -p ${folder}/spikein_bam/
for i in ${folder}/Sample_*
do
    name=$(basename $i)
    echo "$name"
    F1=( $i/*R1_trimmed.fastq.gz )
    F2=( $i/*R2_trimmed.fastq.gz )
    bowtie2 --dovetail --phred33 -p 20 --met-file ${folder}/spikein_bam/${name}_metrics.txt -x $spikeingenome -1 $F1 -2 $F2 2>> ${folder}/spikein_bam/${name}_align.log | \
    samtools view -Sh -F 0x04 -f 0x02 -@ 20 - | \
    samtools sort -o ${folder}/spikein_bam/${name}.bam -O bam -T $i/temp.bam -@ 20 - 2>> ${folder}/spikein_bam/${name}_align.log

    #$logdir/"$base".spikein.bowtie2
    total_reads=`cat ${folder}/spikein_bam/${name}_align.log | grep "reads; of these:" | awk '{print $1}' - FS=' '`
    align_ratio=`cat ${folder}/spikein_bam/${name}_align.log | grep "overall alignment" | awk '{print $1}' - FS=' ' | cut -f1 -d"%"`
    spikein_reads=`printf "%.0f" $(echo "$total_reads * $align_ratio/100"|bc)`

    echo "[info] $i : Spikein reads number is $spikein_reads, consisting of $align_ratio % of total reads" >> ${folder}/spikein_bam/info.log
    #echo "[info] This information could be used in spike-in normalization when generating bigwig files" 2>> ${folder}/spikein_bam/info.log


done
wait
