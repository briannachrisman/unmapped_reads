#!/bin/bash
#SBATCH --job-name=convert_to_fasta
#SBATCH -p owners
#SBATCH --output=/oak/stanford/groups/dpwall/users/briannac/logs/convert_to_fasta.out
#SBATCH --error=/oak/stanford/groups/dpwall/users/briannac/logs/convert_to_fasta.err
#SBATCH --time=1:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu
#SBATCH --mem=64G

ml python/3.6.1

python3 /oak/stanford/groups/dpwall/users/briannac/virus/src/convert_to_fasta.py

#ml biology
#module load ncbi-blast+/2.7.1


#for path in /oak/stanford/groups/dpwall/ihart/bam/unmapped/*.fasta; do
#    file=$(basename "$path")
#    echo $file
#    out_file=$(echo $file | sed 's/fasta/out/')
#    if [ ! -f /oak/stanford/groups/dpwall/users/briannac/virus/data/viral_blast/${out_file} ]; then
#        blastn -db /oak/stanford/groups/dpwall/users/briannac/virus/data/viral_genomes -query $path  -outfmt  '6 sseqid qseqid' > #/oak/stanford/groups/dpwall/users/briannac/virus/data/viral_blast/${out_file}
#    fi
#done


