#!/bin/bash
#SBATCH --job-name=unmapped_reads_assemble
#SBATCH --array=21-441%10
#SBATCH -p dpwall
#SBATCH --output=/oak/stanford/groups/dpwall/users/briannac/logs/unmapped_reads_assemble%a.out
#SBATCH --error=/oak/stanford/groups/dpwall/users/briannac/logs/unmapped_reads_assemble%a.err
#SBATCH --time=20:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu
#SBATCH --mem=64G

ml biology
ml samtools

# Print this sub-job's task ID
echo "My SLURM_ARRAY_TASK_ID is " $SLURM_ARRAY_TASK_ID

LINE="$(sed -n ${SLURM_ARRAY_TASK_ID}p < /oak/stanford/groups/dpwall/users/briannac/virus/data/bam_mappings_on_aws.csv)"
HOST="$(echo $LINE | awk '{print $2;}')"
unmapped_path=/oak/stanford/groups/dpwall/ihart/bam/unmapped/hg38


in_path=${unmapped_path}/${HOST}/${HOST}.final.unmapped.fasta
out_path=${unmapped_path}/${HOST}/megahit_assembled

echo $HOST
if [ ! -f ${out_path}/DONE ]; then
    $megahit -r ${in_path} -o ${out_path} &> /oak/stanford/groups/dpwall/users/briannac/logs/unmapped_reads_assemble_$HOST.log
    echo "DONE" > ${out_path}/DONE
fi
if [ -f ${unmapped_path}/${HOST}/${HOST}.megahit_assembled.done ]; then
    echo "success for megahit on $HOST"
fi


