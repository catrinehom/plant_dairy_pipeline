#!/bin/sh

Samples=$(ls /home/projects/cge/people/cathom/data/prepros)

for sample in $Samples
do
if [ -d "/home/projects/cge/people/cathom/results/SpeciesFinder/$sample" ] 
then
    echo "Directory exists."
else
    mkdir /home/projects/cge/people/cathom/results/SpeciesFinder/$sample
    kma -i /home/projects/cge/people/cathom/data/prepros/$sample/Assemblies/*.fa -o /home/projects/cge/people/cathom/results/SpeciesFinder/${sample}/${sample}_16srna -t_db /home/projects/cge/people/cathom/data/speciesfinder_db/16srna_database -mem_mode -Sparse
fi
echo "Finished with $sample"
done

checkjob -v $PBS_JOBID







