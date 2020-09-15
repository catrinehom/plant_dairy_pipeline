#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=cge -A cge
### Number of nodes
#PBS -l nodes=1:ppn=1
### Memory
#PBS -l mem=6gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 12 hours)
#PBS -l walltime=02:00:00
### Only send mail when job is aborted or terminates abnormally
#PBS -m n
#PBS -e /home/projects/cge/people/cathom/results/kmerfinder/kmerfinder.err
#PBS -o /home/projects/cge/people/cathom/results/kmerfinder/kmerfinder.log


# Load all required modules for the job
module load tools
module load anaconda3/4.4.0
module load anaconda2/2.2.0
module load kma/1.2.11

# This is where the work is done
# Make sure that this script is not bigger than 64kb ~ 150 lines, otherwise put in seperat script and execute from here


./myb12finder_make_db.sh
./myb12finder_run.sh
./myb12finder_collect.py
./myb12finder_transform.py
