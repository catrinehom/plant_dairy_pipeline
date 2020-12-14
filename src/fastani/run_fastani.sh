#!/usr/bin/env bash

# Program: run_fastani.sh
# Description: This program run fastANI which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_mydbfinder.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)

# Output:
    ## whole-genome Average Nucleotide Identity in matrix format

################################################################################
# GET INPUT
################################################################################

# Load all required modules for the job
module purge
module load tools
module load anaconda3/4.4.0
module load fastani/1.1

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run>]"; exit 1; }

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
echo "Starting run_fastani.sh ($datestamp)"
echo "--------------------------------------------------------------------------------"

################################################################################
# STEP 1: RUN fastANI
################################################################################

# Define variables
tool_name=fastani

# Create ani_path folder if it doesnt already exists
ani_path=${path}/results/${name}_${date}/${tool_name}
mkdir -p $ani_path

# Define input files in txt
echo ${path}/results/${name}_${date}/foodqcpipeline/*/Assemblies/*.fa > ${ani_path}/fastANI_inputfiles_first.txt
echo ${path}/data/references/raw/*.fna >> ${ani_path}/fastANI_inputfiles_first.txt
tr ' ' '\n' < ${ani_path}/fastANI_inputfiles_first.txt > ${ani_path}/fastANI_inputfiles.txt
rm ${ani_path}/fastANI_inputfiles_first.txt

# Define input
i=${ani_path}/fastANI_inputfiles.txt
o=${path}/results/${name}_${date}/fastani/fastani_results

# Run fastANI
fastANI --ql $i --rl $i -o $o --matrix > /dev/null 2>&1

echo -e "Results can be found in: $o"

echo -e "The tool ${tool_name} finished in $SECONDS seconds.\n"

