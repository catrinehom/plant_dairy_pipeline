#!/bin/sh
#PBS -W group_list=cge -A cge
### Number of nodes
#PBS -l nodes=1:ppn=1
### Memory
#PBS -l mem=10gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 12 hours)
#PBS -l walltime=20:00:00
### Only send mail when job is aborted or terminates abnormally
#PBS -m n
#PBS -e /home/projects/cge/people/cathom/results/XXX/XXX.err
#PBS -o /home/projects/cge/people/cathom/results/XXX/XXX.log

# Load all required modules for the job
module load tools
module load anaconda2/4.0.0
module load SPAdes/3.9.0
module load perl
module load ncbi-blast/2.2.26
module load cgepipeline/20180109
module load kma/1.2.11

# Make sure that this script is not bigger than 64kb ~ 150 lines, otherwise put in seperat script and execute from here:

./XXX_make_db.sh
./XXX_run.sh
./XXX_collect.py
