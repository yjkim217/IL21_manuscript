# Codes to process and analyze CUT&RUN data
Author of the codes in this folder: Ray Kim (KimH7@mskcc.org)
- moveFastqFilesFromServer_v3.sh : to concatenate R1/R2 fastq files split between lanes/machines into single file.
- runFastqcCNRTrimAndrunFastqcAndAlignAndMarkDup_dovetailONandOFF_andSpikeIn_CNR_RKv1.sh : to get QC metrics via fastQC, trim reads, align using bowtie2 for both samples and spike-in DNA
- generate_tables.Rmd : to generate tables for input to IP for peak calling and generate spike-in scaling factor
- indivPeakCallandIDR_CUTANDRUN_dovetailON.sh : to call peaks using MACS2
- makeTracks_scaled_nondedup_RKv1.sh : to generate bigwig tracks using spike-in scaling factors
- bigwigAverage_RKv2_CNR.sh : to average sample replicates into single bigwig track
