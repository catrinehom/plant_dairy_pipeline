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
    ## GC% of assemblies

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

datestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting run_GC.sh (${datestamp})"
echo "--------------------------------------------------------------------------------"

################################################################################
# STEP 1: RUN TOOL
################################################################################

# Define variables
tool_name=GC
outputfolder=${path}/results/${name}_${date}/summary

# Make output directory
[ -d $outputfolder ] || mkdir $outputfolder

# Define variables
samples=$(cat ${path}/results/${name}_${date}/tmp/qc_approved.txt)
count=$((1))
total=$(wc -w <<<$samples)
tool=${path}/src/GC/calculate_GC_content.py

for sample in $samples
  do
    echo "Running: $sample ($count/$total)"
    cd ${outputfolder}

    # Define tool inputs
    i=${path}/results/${name}_${date}/foodqcpipeline/${sample}/Assemblies/*.fa
    s=$sample
    o=${outputfolder}/GC_content.txt

    # Run tool
    $tool $i $s $o
    count=$(($count+1))
  done

echo -e "Results can be found in: $o"

echo -e "The tool ${tool_name} finished in $SECONDS seconds.\n"

