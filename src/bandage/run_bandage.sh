#!/usr/bin/env bash

# Program: run_bandage.sh
# Description: This program run Bandage which is a part of the dairy pipeline
# Version: 1.1
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_bandage.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)

# Output:
    ## .svg images of all assemblies

# This pipeline consists of 1 steps:
    ## STEP 1:  Run Bandage

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
echo "Starting run_bandage.sh ($datestamp)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: ${path}"
echo "Results will be saved in: ${name}_${date}"

################################################################################
# STEP 1: RUN BANDAGE
################################################################################

# Load modules
module purge
module load tools
module load bandage/0.8.1

echo "Starting STEP 1: Run Bandage"

# Define variables
tool_name=bandage
outputfolder=${path}/results/${name}_${date}/summary/$tool_name

# Make output directory
[ -d $outputfolder ] && echo "Output directory: $outputfolder already exists. Files will be overwritten." || mkdir -p $outputfolder

# Define variables
samples_path=${path}/results/${name}_${date}/foodqcpipeline
samples=$(cat ${path}/results/${name}_${date}/tmp/gfa_approved.txt)
count=$((1))
total=$(wc -w <<<$samples)

# Run foodqcpipeline for all samples
for sample in $samples
  do
    echo "Starting with: $sample ($count/$total)"

    # Define tool inputs
    input_gfa=${samples_path}/${sample}/Assemblies/*/assembly_graph_with_scaffolds.gfa
    output_png=$outputfolder/${sample}.png

    # Run tool
    Bandage image $input_gfa $output_png --colour depth

    count=$(($count+1))
  done

echo "$tool_name finished in $SECONDS seconds."

