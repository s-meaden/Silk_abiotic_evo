
#!/usr/bin/env bash


# Script to search for phage mutations in whole population seq from Ella project.
# Rule out / identify escape mutations

# Annotate LC53 genome

#[sm758@athena-l01 ella_proj]$ pwd
# /nobackup/beegfs/home/ISAD/sm758/ella_proj

module load Conda/Python3/3.7.2
conda init bash

conda activate phage_mapping

conda install -c bioconda prokka
conda install -c bioconda sickle-trim
conda install -c bioconda breseq

# Might be issues installing all these in the same environment.


# Repeat data filtering that was done for the SNP mapping (on a different server)

# Adapters removed during demultiplex (and checked w/ FastQC)

# Same script as host mapping:

for i in `ls data/*R1_001.fastq.gz`
do
	echo $i
	base=$(basename $i "_R1_001.fastq.gz")
	echo $base
	sickle pe -f  data/${base}_R1_001.fastq.gz  -r data/${base}_R2_001.fastq.gz -t sanger -o data/${base}_R1_001_trimmed.fastq.gz -p data/${base}_R2_001_trimmed.fastq.gz -s data/${base}_R1_001.trimmed_singles.fastq.gz
done


# Annotate LC53 w/ prokka to SNP call.
# Got PHROG HMMs (modified to be prokka friendly) from  wget http://s3.climb.ac.uk/ADM_share/all_phrogs.hmm.gz
prokka --outdir LC53 --force --prefix LC53 --kingdom Viruses --hmms all_phrogs.hmm --cdsrnaolap LC53.fasta

# Call SNPs with breseq

# Test run:
breseq -r LC53/LC53.gbk data/ANC_S26_R1_001_trimmed.fastq.gz  data/ANC_S26_R2_001_trimmed.fastq.gz -j 2 -p
# 0% alignmend rate.

breseq -r LC53/LC53.gbk data/P_4_1_S43_R1_001_trimmed.fastq.gz  data/P_4_1_S43_R2_001_trimmed.fastq.gz -j 2 -p

# Job is queued up on athena server:
sbatch phage_mapping_LC53_slurm.sh 

# Check results 

















