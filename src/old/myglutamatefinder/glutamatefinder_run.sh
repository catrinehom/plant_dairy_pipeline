#!/bin/sh

module load tools
module load anaconda3/4.4.0
module load anaconda2/2.2.0
module load kma/1.2.11

Samples=$(ls /home/projects/cge/people/cathom/data/foodqcpipeline)
###Samples=EFB1C4ZNPB

for sample in $Samples
do
echo $sample
if [ -d "/home/projects/cge/people/cathom/results/glutamatefinder/$sample" ] 
then
    echo "Directory exists."
else
    mkdir /home/projects/cge/people/cathom/results/glutamatefinder/$sample
    /home/projects/cge/people/cathom/tools/mydbfinder/mydbfinder.py -i /home/projects/cge/people/cathom/data/foodqcpipeline/${sample}/Trimmed/*P_trimmed.trim.fq.gz -o /home/projects/cge/people/cathom/results/glutamatefinder/$sample -p /home/projects/cge/people/cathom/data/glutamatefinder_db
fi
echo "Finished with $sample"
done
