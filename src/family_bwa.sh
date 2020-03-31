#!/bin/bash
#SBATCH --job-name=family_bwa
#SBATCH --array=13-43%5
#SBATCH -p dpwall
#SBATCH --output=/oak/stanford/groups/dpwall/users/briannac/logs/family_bwa%a.out
#SBATCH --error=/oak/stanford/groups/dpwall/users/briannac/logs/family_bwa%a.err
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu
#SBATCH --mem=64G

ml biology
ml samtools

# Print this sub-job's task ID
echo "My SLURM_ARRAY_TASK_ID is " $SLURM_ARRAY_TASK_ID

LINE="$(sed -n ${SLURM_ARRAY_TASK_ID}p < /oak/stanford/groups/dpwall/users/briannac/virus/data/family_ids.csv)"
KID="$(echo $LINE | awk '{print $1;}')"
DAD="$(echo $LINE | awk '{print $2;}')"
MOM="$(echo $LINE | awk '{print $3;}')"

unmapped_path=/oak/stanford/groups/dpwall/ihart/bam/unmapped/hg38

echo $KID
if [ -d ${unmapped_path}/$KID ]; then
    if [ -d ${unmapped_path}/$DAD ]; then
        if [ -d ${unmapped_path}/$MOM ]; then
        echo "Child + parents present"
        mkdir ${unmapped_path}/$KID/family_blast
fi
fi
fi

if [  -d ${unmapped_path}/$KID/family_blast ]; then
    if [  ! -f ${unmapped_path}/$KID/family_blast/parents_bwa_mem.done ]; then
        cat ${unmapped_path}/$MOM/$MOM.final.unmapped.fasta ${unmapped_path}/$DAD/$DAD.final.unmapped.fasta > ${unmapped_path}/$KID/family_blast/parents.fasta
        ref=${unmapped_path}/$KID/family_blast/parents.fasta
        #in_path=${unmapped_path}/$KID/$KID.prokaryote_virus.unmapped
        
        out_path=${unmapped_path}/$KID/family_blast/parents_bwa_mem

        $bwa index $ref ${unmapped_path}/$KID/family_blast/parents
        $bwa mem $ref  test_ch.fasta
        #$bwa mem $ref ${in_path}.bam > ${out_path}.sai; $bwa samse  $ref ${out_path}.sai ${in_path}.bam | tee >(samtools view - -Sb -f 0x04 -o ${out_path}.unmapped.bam) | samtools view - -Sb -F 0x04 -o | samtools sort -o ${out_path}.mapped.bam
        echo "DONE" > ${out_path}.done
    fi
fi
echo "DONE ALIGNING TO FAMILY"

#samtools sort ${out_path}.mapped.bam -o ${out_path}.sorted.mapped.bam
#samtools index ${out_path}.sorted.mapped.bam
#echo "DONE SORTING / INDEXING"