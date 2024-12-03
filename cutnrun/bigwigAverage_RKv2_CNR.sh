#!/bin/bash
# 2024.04.14 bigwigAverage_RKv2_CNR.sh
# Using deeptools' bigwigAverage. This needs >= 3.5.1, so I have to conda activate to 3.5.2 env (deeptools352)
# Could generate a txt file for samples and new name then awk, but too lazy right now. Todo for later.

folder=$( dirname $0 )

mkdir ${folder}/tracks_scaled_spikein_Average



bigwigAverage -b ${folder}/tracks_spikeinscaled/Sample_WT_400k_STAT3_IL21_IgM_1_IGO_14624_12_dupMark.bw ${folder}/tracks_spikeinscaled/Sample_WT_400k_STAT3_IL21_IgM_2_IGO_14624_13_dupMark.bw \
-o ${folder}/tracks_scaled_spikein_Average/Sample_WT_400k_STAT3_IL21_IgM_AVERAGED.bw \
-bs 10 -p max -v
wait

bigwigAverage -b ${folder}/tracks_spikeinscaled/Sample_WT_400k_STAT3_IL4_IgM_1_IGO_14624_8_dupMark.bw ${folder}/tracks_spikeinscaled/Sample_WT_400k_STAT3_IL4_IgM_2_IGO_14624_9_dupMark.bw \
-o ${folder}/tracks_scaled_spikein_Average/Sample_WT_400k_STAT3_IL4_IgM_AVERAGED.bw \
-bs 10 -p max -v
wait
