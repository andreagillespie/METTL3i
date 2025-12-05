#!/bin/bash
 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=prod_med
#SBATCH --mem-per-cpu=8G
#SBATCH --time=0-12:00:00
#SBATCH --output=../../logs/iso_dunk%j.stdout
#SBATCH --mail-user=andrea.gillespie@petermac.org
#SBATCH --mail-type=END,TIME_LIMIT_80
#SBATCH --job-name="slamdunk"

module purge

module load slamdunk/0.2.4

bname=`basename $1 .trim.fq.gz`
rl=100
Ref=/data/reference/dawson_labs/joint_genomes/Mm38Dm6/Mm38Dm6.fa
utr=/dawson_genomics/Projects/METTL3i/SLAMseq/220203_NB501056_0755_AHFFWCBGXL/reference_files/Mm10Dm6utr.bed

mkdir ${bname}slamout

slamdunk all -r $Ref -b $utr -fb $utr -o ${bname}slamout -n 100 -m -mv 0.2 -rl $rl $1

alleyoop collapse -o collapse/ -t 1 ${bname}slamout/count/*tcount.tsv &

alleyoop snpeval -o ${bname}slamout/ -s ${bname}slamout/snp/ -r $Ref -b $utr -l $rl -t 1 ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &
alleyoop rates -o ${bname}slamout/ -r $Ref -t 1 ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &
alleyoop tccontext -o ${bname}slamout/ -r $Ref -t 1 ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &
alleyoop tcperutrpos -o ${bname}slamout/ -r $Ref -b $utr -s ${bname}slamout/snp/ -l $rl -t 1 ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &
alleyoop tcperreadpos -o ${bname}slamout/ -r $Ref -s ${bname}slamout/snp/ -l $rl -t 1 ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &
alleyoop utrrates -o ${bname}slamout/ -r $Ref -l $rl -t 1 -b $utr ${bname}slamout/filter/*_slamdunk_mapped_filtered.bam &

wait
