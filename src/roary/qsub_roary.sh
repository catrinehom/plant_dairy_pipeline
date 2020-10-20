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
module load perl/5.30.2
module load roary/3.13.0


# Make sure that this script is not bigger than 64kb ~ 150 lines, otherwise put in seperat script and execute from here:

FastTree -nt -gtr < /home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/roary/_1602143776/core_gene_alignment.aln  > /home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/roary/_1602143776/Leuconostoc_mesenteroides.newick

