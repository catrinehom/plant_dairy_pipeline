#!/usr/bin/env bash

# Program: run_GC.sh
# Description: This program run GC which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## rh run_GC [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)

# Output:
    ## Outputfile 1
    ## Outputfile 2

# This pipeline consists of 1 steps:
    ## STEP 1:  Run GC


################################################################################
# GET INPUT
################################################################################

# Load all required modules for the job
module purge
module load tools
module load python36

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to main>] [-n <name of project>] [-d <date of run (optional)>]"; exit 1; }

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

datestamp=$(date "+_%Y-%m-%d %H:%M:%S")
echo "Starting run_GC.sh (${datestamp})"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Name of project used is: ${name}"
echo "Path used is: ${path}"

################################################################################
# STEP 1: RUN TOOL
################################################################################

echo "Starting STEP 1: Run GC"

# Define variables
tool_name=GC
outputfolder=${path}/results/${name}_${date}/summary

# Make output directory
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir $outputfolder

# Define variables
samples=$(cat ${path}/results/${name}_${date}/tmp/fasta_approved.txt)
count=$((1))
total=$(wc -w <<<$samples)
tool=${path}/src/misc/calculate_GC_content.py

for sample in $samples
  do
    echo "Starting with: $sample ($count/$total)"
    cd ${outputfolder}

    # Define tool inputs
    i=${path}/results/${name}_${date}/foodqcpipeline/${sample}/Assemblies/*.fa
    s=$sample
    o=${outputfolder}/GC_content.txt

    # Run tool
    $tool $i $s $o
    echo "Finished with: $sample"
    count=$(($count+1))
  done

echo "${tool_name} finished in $SECONDS seconds."

