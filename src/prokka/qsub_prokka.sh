#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=cge -A cge
### Number of nodes
#PBS -l nodes=1:ppn=1
### Memory
#PBS -l mem=6gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds>
#PBS -l walltime=24:00:00
#PBS -e /home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/prokka/prokka.err
#PBS -o /home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/prokka/prokka.log

# Load all required modules for the job
module load tools
module load perl
module load ncbi-blast/2.8.1+
module load hmmer/3.2.1
module load aragorn/1.2.36
module load tbl2asn/20191211
module load prodigal/2.6.3
module load infernal/1.1.2
module load barrnap/0.7
module load jdk/15
module load minced/0.2.0
module load rnammer/1.2
module load signalp/4.1c
module load prokka/1.14.0

# This is where the work is done
# Make sure that this script is not bigger than 64kb ~ 150 lines, otherwise put in seperat script and execute from here

path=/home/projects/cge/people/cathom
n=DTU_LAB
date=20200825_110300

${path}/src/prokka/run_prokka.sh -p ${path} -n ${n} -d ${date}

