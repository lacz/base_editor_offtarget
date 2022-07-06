#!/bin/bash

echo "start script"

echo "folders structure"
mkdir sam3 bam3
ref="../../ref/hg38/HG38"
runs="*fastq.gz"
run1=($(ls *R1_001.fastq.gz))
run2=($(ls *R2_001.fastq.gz))
liczba=${#run1[*]}

echo "fastqc analysis and aligment"
i=0
while [ $i -lt $liczba ]
do
	echo "${run1[$i]}"
	echo "${run2[$i]}"
	name=${run1[$i]%%_*}
	fastqc ${run1[$i]} -o fastqc/
	fastqc ${run2[$i]} -o fastqc/
	hisat2 -p 8 -x ../../ref/hg38/HG38.fna -1 ${run1[$i]} -2 ${run2[$i]} -S sam3/$name".sam"
	samtools sort sam3/$name".sam" > bam3/$name".bam"
	samtools index bam3/$name".bam"
	i=$[i+1]
	python ~/REDItools/main/REDItoolDnaRna.py -i bam3/$name".bam" -f ../../ref/hg38/HG38.fna -n 6 -t 12 -o $name
done
echo "differential expression"
featureCounts -g gene_name -a $ref.”/Homo_sapiens.GRCh38.96.chr.gtf “-o counts.txt bam/*.bam
cat counts.txt | Rscript ../../\!skrypty/edger.r 2x4 > edger-results.csv
echo "end script"
