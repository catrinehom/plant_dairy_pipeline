#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=cge -A cge
### Number of nodes
#PBS -l nodes=1:ppn=1
### Memory
#PBS -l mem=12gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 12 hours)
#PBS -l walltime=00:20:00
#PBS -m n
#PBS -e /home/projects/cge/people/cathom/results/speciesfinder/speciesfinder.err
#PBS -o /home/projects/cge/people/cathom/results/speciesfinder/speciesfinder.log

 
# Load all required modules for the job
module load tools
module load python36
module load anaconda3/4.4.0
module load kma/1.2.11
module load perl
module load ncbi-blast/2.2.26

# This is where the work is done
# Make sure that this script is not bigger than 64kb ~ 150 lines, otherwise put in seperat script and execute from here

./speciesfinder_make_db.sh
./speciesfinder_run.sh
./species_collect.py
