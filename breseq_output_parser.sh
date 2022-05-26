#!/usr/bin/env bash


# Move breseq output vcfs to new folder and rename accordingly.
mkdir combined_output

#for i in `ls *_breseq_output/output/*.vcf`
#do 
## 	echo $i
# 	dir="$(dirname "$i")"
# 	echo $dir
#	#echo "$dir" | sed 's/breseq/ /g' 
# 	sample_name="$(echo "$dir" | sed -r 's/_S[0-9]+_breseq_output//g')"
# 	echo $sample_name 
# 	cp $i combined_output/${sample_name}.vcf
#done

# Only works on samples with SNPs. The others just print the whole vcf file for some reason.

# Repeat with file list for samples that had SNPs.


while IFS= read -r line
do
sample_name="$(echo "$line" | sed -r 's/_S[0-9]+//g')"
echo $line
echo $sample_name
cp  ${line}_breseq_output/output/output.vcf combined_output/${sample_name}.vcf
done < file_list.txt

# Concatenate into single dataset with filename as a column.

awk '{print $0","FILENAME}' combined_output/*.vcf >  combined_output/all_samples.vcf