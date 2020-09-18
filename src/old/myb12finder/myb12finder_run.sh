#!/bin/sh
Samples=$(ls /home/projects/cge/people/plantgurt/data/foodqcpipeline)
###Samples=EFB1C4ZNPB

for sample in $Samples
do
echo $sample
if [ -d "/home/projects/cge/people/plantgurt/results/myb12finder/$sample" ] 
then
    echo "Directory exists."
else
    mkdir /home/projects/cge/people/plantgurt/results/myb12finder/$sample
    /home/projects/cge/people/plantgurt/tools/mydbfinder/mydbfinder.py -i /home/projects/cge/people/plantgurt/data/foodqcpipeline/${sample}/Trimmed/*P_trimmed.trim.fq.gz -o /home/projects/cge/people/plantgurt/results/myb12finder/$sample -p /home/projects/cge/people/plantgurt/data/myb12finder_db
fi
echo "Finished with $sample"
done
