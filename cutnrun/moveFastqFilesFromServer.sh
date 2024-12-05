#!/bin/bash
# concatenate reads if split over lanes/machines, specific for institutional data delivery
## Note: must be signed into server
folder=$( dirname $0 )
project=$( basename $folder )
serverFolder=/PATH/TO/FASTQS/$project

# Move folders to correct place if not already ####################################
## dev null quiets standard out output; if there is no file found, would otherwise say that no such directory is found
if [ `ls -1 ${serverFolder}/*/Sample_*/*fastq.gz 2>/dev/null | wc -l ` -eq 0 ]
then
    echo 'No fastq files found in this folder.'
    exit
else
    uniq_samples=( $(basename -a ${serverFolder}/*/Sample_* |sort |uniq) ) # make multiple arguments and an array
    numSamp=$( echo ${#uniq_samples[@]} )

    #make folder for uniq samples and check that each sample has an R1 and R2
    echo '--- Step 1: Making new folders ---'

    for i in ${uniq_samples[@]}
    do
        if [ `ls -1 ${serverFolder}/*/$i/*_R1_*fastq.gz 2>/dev/null | wc -l ` -eq 0 ]
        then
            echo "Sample '$i' does not have any R1 files."
            exit
        fi
        if [ `ls -1 ${serverFolder}/*/$i/*_R2_*fastq.gz 2>/dev/null | wc -l ` -eq 0 ]
        then
            echo "Sample '$i' does not have any R2 files."
            exit
        fi
        mkdir ${folder}/$i
    done

    # rename samplesheets so that it has name of machine it was sequenced on
    echo '--- Step 2: Moving sample sheets to new folders ---'
    if [ `ls -1 ${serverFolder}/*/Sample_*/Samplesheet.csv 2>/dev/null | wc -l ` -gt 0 ]
    then
        for i in ${serverFolder}/*/Sample_*/SampleSheet.csv
        do
            mach=$( echo $i |rev |cut -f3 -d '/' |rev )
            sample=$( echo $i |rev |cut -f2 -d '/' |rev )
            newFile=${folder}/${sample}/Samplesheet_${mach}.csv
            cp $i ${newFile}
        done
    else
        echo '...No sample sheets. Moving on to step 3...'
    fi

    echo '--- Step 3: Concatenating fastq files ---'
    for i in ${uniq_samples[@]}
    do
        R1=$( ls ${serverFolder}/*/$i/*_R1_*fastq.gz )
        printf "%s\n" "$R1" > ${folder}/$i/${i}_R1.txt
        echo "cat $R1 > ${folder}/$i/${i}_R1_ALL.fastq.gz"
        cat $R1 > ${folder}/$i/${i}_R1_ALL.fastq.gz
        wait
        if [ `gzip -cd $R1 | wc -l ` -ne `gzip -cd ${folder}/$i/${i}_R1_ALL.fastq.gz | wc -l ` ]
        then
            echo "Concatenated '$i' R1 fastq file is not the same length as its parts."
            exit
        else
            R2=$( ls ${serverFolder}/*/$i/*_R2_*fastq.gz )
            printf "%s\n" "$R2" > ${folder}/$i/${i}_R2.txt
            echo "cat $R2 > ${folder}/$i/${i}_R2_ALL.fastq.gz"
            cat $R2 > ${folder}/$i/${i}_R2_ALL.fastq.gz
            wait
            if [ `gzip -cd $R2 | wc -l ` -ne `gzip -cd ${folder}/$i/${i}_R2_ALL.fastq.gz | wc -l ` ]
            then
                echo "Concatenated '$i' R2 fastq file is not the same length as its parts."
                exit
            else
                echo "$i complete!"
            fi
        fi
    done
    wait

    echo '--- Step 4: Checking fastq files ---'

    num=$( echo "$(($numSamp * 2))" )
    actualNum=$( ls -1 ${folder}/Sample_*/*ALL.fastq.gz 2>/dev/null | wc -l )
    actualNum=$(echo $actualNum)
    if [ $actualNum -ne $num ]
    then
        echo "Something is not lining up. There should be $num FASTQ files, but there are only ${actualNum}. Please check!"
        exit
    else
        echo 'Looks good!'
    fi
fi
