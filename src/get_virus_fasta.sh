#!/bin/bash
#SBATCH --job-name=get_virus_fastas
#SBATCH -p dpwall
#SBATCH --output=/oak/stanford/groups/dpwall/users/briannac/logs/get_virus_fastas.out
#SBATCH --error=/oak/stanford/groups/dpwall/users/briannac/logs/get_virus_fastas.err
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu
#SBATCH --mem=64G

#cd /oak/stanford/groups/dpwall/users/briannac/virus/data/ref_genomes/human_virus
#cut -f1 human_virus_list.txt | sed 's/\,/\n/g' | sort | uniq | python2 /oak/stanford/groups/dpwall/users/briannac/virus/src/get_virus_fasta.py
#echo "concatenating human viruses"
#cat *.fa > all.fasta
#echo "done!"

cd /oak/stanford/groups/dpwall/users/briannac/virus/data/ref_genomes/prokaryote_virus
cut -f1 prokaryote_virus_list.txt | sed 's/\,/\n/g' | sort | uniq | python2 /oak/stanford/groups/dpwall/users/briannac/virus/src/get_virus_fasta.py
echo "concatenating prokaryote viruses"
cat *.fa > all.fasta
echo "done!"

echo "done-- success!"

