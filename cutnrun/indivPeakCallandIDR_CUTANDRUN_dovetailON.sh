#!/bin/bash
# 2022.01.10 indivPeakCall_CUTANDRUN_dovetailON.sh
# Using comments from Wilfred Wong about keepdup and dovetail. Trying to see what difference it makes.
folder=$( dirname $0 )
genome=mm10
IPpairs=${folder}/input_IP_pairs_dovetailON.txt

## Peak calling ######################################################################

if [ $genome == mm10 ]; then
    gm=mm
elif [ $genome == hg38 ]; then
    gm=hs
fi

num=$(cat $IPpairs | wc -l)
for i in `seq 1 $num`
do
  input=$(awk -v i="$i" 'NR==i {print $1}' $IPpairs)
  chip=$(awk -v i="$i" 'NR==i {print $2}' $IPpairs)
  base=$(basename $chip)
  name=${base/_dupMark\.bam/}

  dirname=${folder}/MACS2_BAMPE_narrowPeak_cutoffAnalysis_SPMR_dovetailON_keepdupall/${name}_MACS2
  if [ -f "${dirname}/${name}_peaks.narrowPeak" ]
  then
      echo "${name} for BAMPE narrow peak cutoff analysis exists. Moving to next sample."
  else
      echo "${name} processing BAMPE narrow peak cutoff analysis..."
      mkdir -p $dirname
      macs2 callpeak --cutoff-analysis -p 1e-5 --keep-dup all -B --SPMR \
      -t ${folder}/${chip} -c ${folder}/${input} -f BAMPE -g $gm --outdir ${dirname} --name ${name} &> ${dirname}/macs2.log
  fi

done
wait
