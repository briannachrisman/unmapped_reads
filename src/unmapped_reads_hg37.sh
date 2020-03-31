#!/bin/bash
#SBATCH --job-name=unmapped_reads
#SBATCH --array=20-40%10
#SBATCH -p dpwall
#SBATCH --output=/oak/stanford/groups/dpwall/users/briannac/logs/unmapped_reads_%a.out
#SBATCH --error=/oak/stanford/groups/dpwall/users/briannac/logs/unmapped_reads_%a.err
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu
#SBATCH --mem=64G

ml biology
ml samtools

# Print this sub-job's task ID
echo "My SLURM_ARRAY_TASK_ID is " $SLURM_ARRAY_TASK_ID

LINE="$(sed -n ${SLURM_ARRAY_TASK_ID}p < /oak/stanford/groups/dpwall/users/briannac/virus/data/bam_mappings_on_aws.csv)"
HOST="$(echo $LINE | awk '{print $2;}')"
unmapped_path=/oak/stanford/groups/dpwall/ihart/bam/unmapped/hg37
aws_path=s3://ihart-main/bam-gatk3.4

echo $HOST
if [ -f ${unmapped_path}/$HOST ]; then
    mkdir ${unmapped_path}/$HOST
fi

if [ ! -f ${unmapped_path}/$HOST/$HOST.bam.done ]; then
    if [ "$(aws s3 ls ihart-main/bam-gatk3.4/$HOST.bam | wc -l)" -eq "1" ]; then
        echo "finding upmapped reads for on $HOST"
        # -f 4 = flag 4 corresponds to unmapped reads, cut -f 10 means take the 10th column (sequence)
        \rm ${unmapped_path}/$HOST.bam
        samtools view ${aws_path}/$HOST.bam -f 4 -b -o ${unmapped_path}/$HOST/$HOST.bam
    fi
fi


if [ -f ${unmapped_path}/$HOST/$HOST.bam ]; then
    echo "success for unmapped reads on $HOST"
    echo "DONE" > ${unmapped_path}/$HOST/$HOST.bam.done
fi

echo "Aligning to decoy..."
ref=/oak/stanford/groups/dpwall/users/briannac/virus/data/ref_genomes/hg37_decoy/hg37_decoy.fa 
in_path=${unmapped_path}/${HOST}/${HOST}
out_path=${unmapped_path}/${HOST}/${HOST}.decoy
$bwa aln -b $ref ${in_path}.bam > ${out_path}.sai; $bwa samse  $ref ${out_path}.sai ${in_path}.bam | tee >(samtools view - -Sb -f 0x04 -o ${out_path}.unmapped.bam) | samtools view - -Sb -F 0x04 -o ${out_path}.mapped.bam
echo "DONE ALIGNING TO DECOY"

echo "Aligning to human viruses..."
ref=/oak/stanford/groups/dpwall/users/briannac/virus/data/ref_genomes/human_virus/all.fasta
in_path=${unmapped_path}/${HOST}/${HOST}.decoy.unmapped
out_path=${unmapped_path}/${HOST}/${HOST}.human_virus
$bwa aln -b $ref ${in_path}.bam > ${out_path}.sai; $bwa samse  $ref ${out_path}.sai ${in_path}.bam | tee >(samtools view - -Sb -f 0x04 -o ${out_path}.unmapped.bam) | samtools view - -Sb -F 0x04 -o ${out_path}.mapped.bam
echo "DONE ALIGNING TO HUMAN VIRUS"

echo "Aligning to prokaryote viruses..."
ref=/oak/stanford/groups/dpwall/users/briannac/virus/data/ref_genomes/prokaryote_virus/all.fasta
in_path=${unmapped_path}/${HOST}/${HOST}.human_virus.unmapped
out_path=${unmapped_path}/${HOST}/${HOST}.prokaryote_virus
$bwa aln -b $ref ${in_path}.bam > ${out_path}.sai; $bwa samse  $ref ${out_path}.sai ${in_path}.bam | tee >(samtools view - -Sb -f 0x04 -o ${out_path}.unmapped.bam) | samtools view - -Sb -F 0x04 -o ${out_path}.mapped.bam
echo "DONE ALIGNING TO PROKARYOTE VIRUS"

echo "Converting to fastq..."
in_path=${unmapped_path}/${HOST}/${HOST}.prokaryote_virus.unmapped
out_path=${unmapped_path}d/${HOST}/${HOST}
samtools fasta ${in_path}.bam > ${out_path}.prefinal.unmapped.fasta
awk -v myvar=\>$HOST '/^>/{print myvar "_"  ++i; next}{print}' < ${out_path}.prefinal.unmapped.fasta > ${out_path}.final.unmapped.fasta
$bwa index ${out_path}.final.unmapped.fasta ${out_path}.final.unmapped
echo "DONE CONVERTING TO FASTQ"


#
#ref=/oak/stanford/groups/dpwall/ihart/bam/unmapped/02C11625.prokaryote_virus.final.fasta
#in_path=/oak/stanford/groups/dpwall/ihart/bam/unmapped/02C11624.prokaryote_virus.unmapped
#out_path=/oak/stanford/groups/dpwall/ihart/bam/unmapped/02C11624.family
#$bwa aln -b $ref ${in_path}.bam > ${out_path}.sai; $bwa samse  $ref ${out_path}.sai ${in_path}.bam | tee >(samtools view #- -Sb -f 0x04 -o ${out_path}.unmapped.bam) | samtools view - -Sb -F 0x04 -o | samtools sort -o ${out_path}.mapped.bam
#echo "DONE ALIGNING TO FAMILY"

#samtools sort ${out_path}.mapped.bam -o ${out_path}.sorted.mapped.bam
#samtools index ${out_path}.sorted.mapped.bam
#echo "DONE SORTING / INDEXING"