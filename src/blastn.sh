#!/bin/bash
#SBATCH --job-name=blastn
#SBATCH --array=9-100%5
#SBATCH -p dpwall
#SBATCH --output=/oak/stanford/groups/dpwall/users/briannac/logs/blastn_%a.out
#SBATCH --error=/oak/stanford/groups/dpwall/users/briannac/logs/blastn_%a.err
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu
#SBATCH --mem=64G

ml biology
module load ncbi-blast+/2.7.1

ls /oak/stanford/groups/dpwall/ihart/bam/unmapped/*.fasta > /tmp/fasta_files.out

# Print this sub-job's task ID
echo "My SLURM_ARRAY_TASK_ID is " $SLURM_ARRAY_TASK_ID

LINE="$(sed -n ${SLURM_ARRAY_TASK_ID}p < /tmp/fasta_files.out)"
path="$(echo $LINE | awk '{print $1;}')"
FILE=$(basename "$path")
echo $FILE
OUT_FILE=$(echo $FILE | sed 's/fasta/out/')
DONE_FILE=$(echo $FILE | sed 's/fasta/done/')

    
if [ ! -f /oak/stanford/groups/dpwall/users/briannac/virus/data/viral_blast/${DONE_FILE} ]; then
    blastn -db /oak/stanford/groups/dpwall/users/briannac/virus/data/viral_genomes -query $path  -outfmt  '6 sseqid qseqid' > /oak/stanford/groups/dpwall/users/briannac/virus/data/viral_blast/${OUT_FILE}
    echo "DONE" > /oak/stanford/groups/dpwall/users/briannac/virus/data/viral_blast/${DONE_FILE}
fi


