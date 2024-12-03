#!/bin/bash

# Declare a string array with type
SampleArray=("Naive-1" "Naive-2" "Naive-3" 
  "40-6hr-1" "40-6hr-2" "40-6hr-3" 
  "40-24hr-1" "40-24hr-2" "40-24hr-3" 
  "44-6hr-1" "44-6hr-2" "44-6hr-3" 
  "44-24hr-1" "44-24hr-2" "44-24hr-3" 
  "61-6hr-1" "61-6hr-2" "61-6hr-3" 
  "61-24hr-1" "61-24hr-2" "61-24hr-3" 
  "65-6hr-1" "65-6hr-2" "65-6hr-3" 
  "65-24hr-1" "65-24hr-2" "65-24hr-3")

# Define the directory
workDir="/data/chaudhujlab/youngjunkim"
projectDir="${workDir}/20221004_rnaseq"
genomeDir="${workDir}/salmon_index/prebuilt"
tempDir="/scratch/kimy3/$(date +%s)"

# Declare tool paths 
toolDir="/home/kimy3/tool"
salmon="${toolDir}/salmon-1.9.0_linux_x86_64/bin/salmon"

# Create the output directory
salmonResultDir="${projectDir}/salmon_result"
mkdir -p $salmonResultDir

# Run salmon
for val1 in ${SampleArray[*]}; 
do
  samp=`basename ${val1}`
  echo "Started processing sample ${samp} with Salmon"
  
  $salmon quant -i ${genomeDir} -l A \
  -1 ${projectDir}/fastq/${samp}_R1.fastq.gz \
  -2 ${projectDir}/fastq/${samp}_R2.fastq.gz \
  -p 1000 \
  --validateMappings \
  -o ${salmonResultDir}/${samp}

  echo "Finished processing sample ${samp} with Salmon"
done