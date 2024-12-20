#!/bin/bash
# Generate spike-in DNA size factor scaled bigwig tracks

folder=$( dirname $0 )
bamfiles=$( basename -a ${folder}/bam_dovetailON/*bam )
sfTxt=( ${folder}/sizeFactors_inverse_SacCer_Y.txt )

bwdir=${folder}/tracks_spikeinscaled
mkdir $bwdir
mkdir $bwdir/logs
files=$( awk '{print $2}' ${sfTxt} )
for i in ${files}
do
  base=$(basename $i)
  name=${base/\.bam/}
  sizeFactor=$(grep ${base} ${sfTxt} | cut -f3)
  echo "$i"
  bamCoverage --bam ${folder}/$i -o ${bwdir}/${name}.bw \
   --binSize 10 \
   --scaleFactor $sizeFactor \
   --samFlagExclude 1024 \
   --numberOfProcessors 14 2> ${bwdir}/logs/${name}.log
# bin size is basepair #
# scale factor - can extract scale factor with awk'ing $3 as variable to put here
# samflag - 1024 optional duplicated flag excluded

done
wait
