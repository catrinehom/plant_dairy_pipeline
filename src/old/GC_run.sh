#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=cge -A cge
### Number of nodes
#PBS -l nodes=1:ppn=1
### Memory
#PBS -l mem=12gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 12 hours)
#PBS -l walltime=01:00:00
 
# Load all required modules for the job
module load tools
module load python36 
module load anaconda3/4.4.0

# This is where the work is done
# Make sure that this script is not bigger than 64kb ~ 150 lines, otherwise put in seperat script and execute from here


Samples=$(ls /home/projects/cge/people/cathom/data/prepros)
###sample=/home/projects/cge/people/cathom/data/prepros/EFB1C4ZNR2

for sample in $Samples
do
/home/projects/cge/people/cathom/scripts/GC_content_calculate.py /home/projects/cge/people/cathom/data/prepros/$sample/Assemblies/*.fa $sample /home/projects/cge/people/cathom/results/GC_content.txt
echo "Finished with $sample"
done

module load shared moab
checkjob -v $PBS_JOBID
