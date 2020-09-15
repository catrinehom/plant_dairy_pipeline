#!/bin/sh
#PBS -W group_list=cge -A cge -l nodes=1:ppn=1, mem=10gb, walltime=01:00:00
### Only send mail when job is aborted or terminates abnormally
#PBS -m n

# Load all required modules for the job
module load tools

# Make sure that this script is not bigger than 64kb ~ 150 lines, otherwise put in seperat script and execute from here
veghurt=/home/projects/cge/people/veghurt/
path=${veghurt}data/raw/

# Creation of sample name list
foldername=NZ_genomes_2
gunzip ${path}${foldername}.tar.gz
(ls ${path}$foldername) >> ${path}samplenames.txt

# rm -rf foldername

echo "Unzipped $foldername, created /raw/samplenames.txt and removed the unzipped folder again."
