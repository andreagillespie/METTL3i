#!/bin/bash
 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=prod
#SBATCH --mem=12G
#SBATCH --time=2-00:00:00
#SBATCH --output=logs/slamdunk%j.stdout
#SBATCH --mail-user=andrea.gillespie@petermac.org
#SBATCH --mail-type=END,TIME_LIMIT_80
#SBATCH --job-name="slamdunk"

module load ngm/0.5.2
module load slamdunk/0.2.4
module load samtools/1.4.1

# run ngm paired alignment on trimmed reads, with slamseq settings 
bname=`basename $1 _R1_001.fastq.gz`
Ref=/data/reference/dawson_labs/genomes/mm10/Mus_musculus.GRCm38.dna.toplevel.fa
utr=/dawson_genomics/Projects/METTL3i/SLAMseq/220203_NB501056_0755_AHFFWCBGXL/reference_files/Mus_musculus.GRCm38.90_3utr.bed
#/data/reference/dawson_labs/bed_files/Mm10/Mm10_allutrunique.bed
rl=100

mkdir SLAMout/${bname}

slamdunk all -r $Ref -b $utr -fb $utr -o SLAMout/${bname} -n 100 -m -mv 0.2 -rl $rl trimmed_fastqs/${bname}_R1_001_trimmed.fq.gz

alleyoop collapse -o SLAMout/collapse/ -t 1 SLAMout/${bname}/count/*tcount.tsv &

alleyoop snpeval -o SLAMout/${bname}/ -s SLAMout/${bname}/snp/ -r $Ref -b $utr -l $rl -t 1 SLAMout/${bname}/filter/*_slamdunk_mapped_filtered.bam &
alleyoop rates -o SLAMout/${bname}/ -r $Ref -t 1 SLAMout/${bname}/filter/*_slamdunk_mapped_filtered.bam &
alleyoop tccontext -o SLAMout/${bname}/ -r $Ref -t 1 SLAMout/${bname}/filter/*_slamdunk_mapped_filtered.bam &
alleyoop tcperutrpos -o SLAMout/${bname}/ -r $Ref -b $utr -s SLAMout/${bname}/snp/ -l $rl -t 1 SLAMout/${bname}/filter/*_slamdunk_mapped_filtered.bam &
alleyoop tcperreadpos -o SLAMout/${bname}/ -r $Ref -s SLAMout/${bname}/snp/ -l $rl -t 1 SLAMout/${bname}/filter/*_slamdunk_mapped_filtered.bam &
alleyoop utrrates -o SLAMout/${bname}/ -r $Ref -l $rl -t 1 -b $utr SLAMout/${bname}/filter/*_slamdunk_mapped_filtered.bam &

wait


