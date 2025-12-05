#!/bin/bash
 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=prod_med
#SBATCH --mem-per-cpu=8G
#SBATCH --time=0-12:00:00
#SBATCH --output=/dawson_genomics/Projects/METTL3i/SLAMseq/220622_A01524_0035_BHHYWMDRX2/logs/dunk%j.stdout
#SBATCH --mail-user=andrea.gillespie@petermac.org
#SBATCH --mail-type=END,TIME_LIMIT_80
#SBATCH --job-name="slamdunk"

module purge

module load slamdunk/0.2.4
#module load varscan/2.4.3
#module load fastqc/0.11.6
#module load trimmomatic/0.39

bname=`basename $1 _R1_001.fastq.gz`
rl=100
Ref=/data/reference/dawson_labs/joint_genomes/Mm38Dm6/Mm38Dm6.fa
utr=/dawson_genomics/Projects/METTL3i/SLAMseq/220622_A01524_0035_BHHYWMDRX2/reference_files/Mm10_allutrunique.bed

mkdir ${bname}slamout

#java -jar /config/binaries/trimmomatic/0.39/trimmomatic-0.39.jar SE -threads 1 -phred33 $1 fastq/${bname}.trim.fq.gz ILLUMINACLIP:/config/binaries/trimmomatic/0.39/adapters/TruSeq3-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

#fastqc -o fastq fastq/${bname}.trim.fq.gz

slamdunk all -r $Ref -b $utr -fb $utr -o ${bname}slamout -n 100 -m -mv 0.2 -rl $rl ../../alignment/fastq/${bname}.trim.fq.gz

alleyoop collapse -o collapse/ -t 1 ${bname}slamout/count/*tcount.tsv &

alleyoop snpeval -o ${bname}slamout/ -s ${bname}slamout/snp/ -r $Ref -b $utr -l $rl -t 1 ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &
alleyoop rates -o ${bname}slamout/ -r $Ref -t 1 ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &
alleyoop tccontext -o ${bname}slamout/ -r $Ref -t 1 ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &
alleyoop tcperutrpos -o ${bname}slamout/ -r $Ref -b $utr -s ${bname}slamout/snp/ -l $rl -t 1 ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &
alleyoop tcperreadpos -o ${bname}slamout/ -r $Ref -s ${bname}slamout/snp/ -l $rl -t 1 ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &
alleyoop utrrates -o ${bname}slamout/ -r $Ref -l $rl -t 1 -b $utr ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &

wait
