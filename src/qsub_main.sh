#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=cge -A cge
### Number of nodes
#PBS -l nodes=1:ppn=1
### Memory
#PBS -l mem=6gb
### Only send mail when job is aborted or terminates abnormally
#PBS -m n
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 12 hours)
#PBS -l walltime=11:00:00:00
#PBS -e /home/projects/cge/people/cathom/results/NZ_Leu.err
#PBS -o /home/projects/cge/people/cathom/results/NZ_Leu.log


/home/projects/cge/people/cathom/src/main.sh -n NZ_Leu
