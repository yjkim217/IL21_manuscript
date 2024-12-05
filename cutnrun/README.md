# Codes to process and analyze CUT&RUN data
Author of the codes in this folder: Ray Kim (KimH7@mskcc.org)
- bigwigAverage_scaledTracks.sh : to average sample replicates into single bigwig track
- generateInputIPtablesandSpikeinScaleFactors.Rmd : to generate tables for input to IP for peak calling and generate spike-in scaling factor
- makeTracks_spikeinscaled_dedup.sh : to generate bigwig tracks using spike-in scaling factors
- moveFastqFilesFromServer.sh : to concatenate R1/R2 fastq files split between lanes/machines into single file.
- peakCallwithMACS2.sh : to call peaks using MACS2
- runFastQCTrimAlignMarkdup.sh : to get QC metrics via fastQC, trim reads, align using bowtie2 for both samples and spike-in DNA
