import pandas as pd
from collections import Counter
import subprocess
import os

files = [file for _,_,file in os.walk("/oak/stanford/groups/dpwall/ihart/bam/unmapped/")][0]
sample_ids = [f[:-5] for f in files if f[-4:]=='done']
print(len(sample_ids))
sample_ids = ([s for s in sample_ids if not os.path.exists("/oak/stanford/groups/dpwall/ihart/bam/unmapped/" + s + '.fasta')])
print(len(sample_ids))
for s in sample_ids:
    print(s)
    with open("/oak/stanford/groups/dpwall/ihart/bam/unmapped/" + s + ".txt") as sequence_file:
        sequence_data = sequence_file.read().splitlines()
    #N = len(sequence_data)
    #with open("/oak/stanford/groups/dpwall/ihart/bam/unmapped/" + s + ".txt", 'r') as infile:
    #    sequence_data = [line[:-1] for line in infile][:N]
    
    with open("/oak/stanford/groups/dpwall/ihart/bam/unmapped/" + s + ".fasta", "w") as fasta_file:
        for i in range(len(sequence_data)):
            fasta_file.write(">" + str(i) + "\n" + sequence_data[i] + "\n")
