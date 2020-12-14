#!/usr/bin/env bash

# Program: run_roary.sh
# Description: This program run Roary which is a part of the dairy pipeline
# Version: 1.1
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_roary.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)

# Output:
    ## core and pan genome, and phylogeny for each genus and for each species. 

################################################################################
# GET INPUT
################################################################################

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to main>] [-n <name of project>] [-d <date of run>]"; exit 1; }

# Default values
date=$(date "+%Y%m%d_%H%M%S")

# Parse flags
while getopts ":p:n:d:h" opt; do
    case "${opt}" in
        p)
            path=${OPTARG}
            ;;
        n)
            name=${OPTARG}
            ;;
        d)
            date=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            echo "Invalid option: ${OPTARG}"
            usage
            ;;
    esac
done

# Check if required flags are empty
if [ -z "${path}" ] || [ -z "${name}" ]; then
    echo "p and n are required flags"
    usage
fi

datestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting run_roary.sh ($datestamp)"
echo "--------------------------------------------------------------------------------"

################################################################################
# STEP 1: RUN ROARY
################################################################################

# Load modules
module purge
module load tools
module load anaconda2/4.0.0
module load perl/5.30.2
module load roary/3.13.0
module load FastTree/2.1.11

# Silence citation notice
parallel --citation

# Define variables
tool_name=roary
outputfolder=${path}/results/${name}_${date}/roary

# Make output directory
[ -d $outputfolder ] || mkdir -p $outputfolder

# Find species to do Roary on
roary_groups=$(ls ${path}/results/${name}_${date}/tmp/genus)

for genus_file in $roary_groups
  do
    genus_name=$(echo "$genus_file" | cut -f 1 -d '.')
    [ -d ${outputfolder}/${genus_name} ] || mkdir -p $outputfolder
    echo -e "Roary started on $genus_name.\n"

    # Define tool inputs
    ref_path=${path}/results/references*/prokka/${genus_name}*/*.gff
    samples=$(cat ${path}/results/${name}_${date}/tmp/genus/${genus_file})
    sample_path=()
    for sample in ${samples[@]}
      do
        sample_path+=(${path}/results/${name}_${date}/prokka/$sample/*.gff)
      done

    # Run Roary
    roary -p 8 -r -o $genus_name -f ${outputfolder}/${genus_name} $ref_path $sample_path  > /dev/null 2>&1

    # Run FastTree phylogeny
    FastTree -nt -gtr ${outputfolder}/${genus_name}/core_gene_alignment.aln  > ${outputfolder}/${genus_name}/${genus_name}_tree.newick
  done

# Find species to do Roary on
roary_groups=$(ls ${path}/results/${name}_${date}/tmp/species)

for species_file in $roary_groups
  do
    species_name=$(echo "$species_file" | cut -f 1 -d '.')
    [ -d ${outputfolder}/${species_file} ] && echo "Output directory: ${outputfolder}/${species_file} already exists." || mkdir -p $outputfolder
    echo -e "Roary started on $species_name.\n"

    # Define tool inputs
    o=$species_name
    samples=$(cat ${path}/results/${name}_${date}/tmp/species/${species_file})
    sample_path=()
    for sample in ${samples[@]}
      do
        sample_path+=(${path}/results/${name}_${date}/prokka/$sample/*.gff)
      done

    # Run Roary
    roary -e -mafft -p 8 -r -o $o -f $outputfolder $sample_path > /dev/null 2>&1

    # Run FastTree phylogeny
    FastTree -nt -gtr ${outputfolder}/${species_name}/core_gene_alignment.aln  > ${outputfolder}/${species_name}/${species_name}_tree.newick
  done
echo -e "${tool_name} finished in $SECONDS seconds.\n"

