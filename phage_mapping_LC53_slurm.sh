#!/bin/bash
#SBATCH --job-name=SM_read_mapping     		# job name (shows up in the queue)
#SBATCH --time=06:00:00         				# Walltime (HH:MM:SS)  revised down from OG 20hrs.
#SBATCH --mem=5G     
#SBATCH --cpus-per-task=10	  

module load Conda/Python3/3.7.2
conda activate phage_mapping


for i in `ls data/*R1_001_trimmed.fastq.gz`
do
	echo $i
	base=$(basename $i "_R1_001_trimmed.fastq.gz")
	echo $base
	breseq -r LC53/LC53.gbk data/${base}_R1_001_trimmed.fastq.gz data/${base}_R2_001_trimmed.fastq.gz -j 10 -p
	mkdir ${base}_breseq_output
	mv 0* ${base}_breseq_output
	mv data ${base}_breseq_output
	mv output ${base}_breseq_output
	done
done