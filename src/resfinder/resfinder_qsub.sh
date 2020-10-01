#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=cge -A cge
### Number of nodes
#PBS -l nodes=1:ppn=1
### Memory
#PBS -l mem=6gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 12 hours)
#PBS -l walltime=00:20:00
#PBS -m n
#PBS -e /home/projects/cge/people/cathom/results/resfinder/resfinder.err
#PBS -o /home/projects/cge/people/cathom/results/resfinder/resfinder.log


# Load all required modules for the job
module load tools
module load anaconda2/4.0.0
module load SPAdes/3.9.0
module load perl
module load ncbi-blast/2.2.26
module load cgepipeline/20170113

# This is where the work is done
# Make sure that this script is not bigger than 64kb ~ 150 lines, otherwise put in seperat script and execute from here

./resfinder_run.sh
./resfinder_collect.py
