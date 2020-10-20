#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=cge -A cge
### Number of nodes
#PBS -l nodes=1:ppn=1
### Memory
#PBS -l mem=6gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds>
#PBS -l walltime=48:00:00
#PBS -e /home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/plasmidfinder/plasmidfinder.err
#PBS -o /home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/plasmidfinder/plasmidfinder.log

# Load all required modules for the job
module load tools
module load anaconda3/4.4.0
module load anaconda2/2.2.0
module load kma/1.2.11

# This is where the work is done
# Make sure that this script is not bigger than 64kb ~ 150 lines, otherwise put in seperat script and execute from here

path=/home/projects/cge/people/cathom
n=DTU_LAB
date=20200825_110300

${path}/src/plasmidfinder/run_plasmidfinder.sh -p ${path} -n ${n} -d ${date}

