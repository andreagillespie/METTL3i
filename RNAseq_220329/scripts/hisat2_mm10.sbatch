#!/bin/bash 
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --mem-per-cpu=10G
#SBATCH --time=0-24:00:00
#SBATCH --output=logs/hisat2%j.stdout
#SBATCH --mail-user=andrea.gillespie@petermac.org
#SBATCH --mail-type=END,TIME_LIMIT_80
#SBATCH --job-name=“hisat2”
#SBATCH --partition=prod_med

module load trimgalore/0.4.4
module load hisat2/2.1.0
module load samtools/1.13
module load igvtools/2.3.95
module load htseq/0.11.2

bname=`basename $1 _R1_001.fastq.gz`

srun -n 1 trim_galore -o trimmed_fastqs $1
srun -n 1 hisat2 -q -x /data/reference/indexes/mouse/mm10/hisat2/grcm38/Mus_musculus.GRCm38.dna.toplevel -U trimmed_fastqs/${bname}_R1_001_trimmed.fq.gz -S bams/${bname}.sam -p 8 --qc-filter
srun -n 1 samtools view -bS bams/${bname}.sam > bams/${bname}.bam
srun -n 1 samtools sort bams/${bname}.bam -o bams/${bname}.sort.bam
srun -n 1 samtools index bams/${bname}.sort.bam
srun -n 1 htseq-count -f bam -t transcript -i transcript_id -s no -a 10 bams/${bname}.sort.bam /data/reference/indexes/mouse/mm10/bowtie2/Tophat2_transcriptome_data/Mus_musculus.GRCm38.78.gtf > counts/${bname}.count
srun -n 1 igvtools count bams/${bname}.sort.bam tdf/${bname}.tdf mm10
srun -n 1 fastqc -o fastqc $1
srun -n 1 fastqc -o fastqc trimmed_fastqs/${bname}_R1_001_trimmed.fq.gz
