#!/usr/bin/env bash

# Program: run_bandage.sh
# Description: This program run Bandage which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_bandage.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)

# Output:
    ## .png images of all assemblies

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
d=$(date "+_%Y%m%d_%H%M%S")

# Parse flags
while getopts ":p:n:d:h" opt; do
    case "${opt}" in
        p)
            p=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
        d)
            d=_${OPTARG}
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
if [ -z "${p}" ] || [ -z "${n}" ]; then
    echo "p and n are required flags"
    usage
fi

date=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting run_bandage.sh ($date)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: ${p}"
echo "Results will be saved in: ${n}${d}"

echo -e "Time stamp: $SECONDS seconds.\n"


################################################################################
# STEP 1: RUN BANDAGE
################################################################################

# Load modules
module load tools
module load bandage/0.8.1

echo "Starting STEP 1: Run Bandage"

# Define variables
tool_name=bandage
outputfolder=${p}/results/${n}${d}/summary/$tool_name

# Make output directory
[ -d $outputfolder ] && echo "Output directory: $outputfolder already exists. Files will be overwritten." || mkdir -p $outputfolder


# Define variables
samples_path=${p}/results/${n}${d}/foodqcpipeline
samples=$(ls $samples_path)
count=$((1))
total=$(wc -w <<<$samples)

# Run foodqcpipeline for all samples
for sample in $samples
  do
    echo "Starting with: $sample ($count/$total)"

    # Define tool inputs
    input_gfa=${samples_path}/${sample}/Assemblies/*_trimmed/*assembly_graph_with_scaffolds.gfa
    output_png=$outputfolder/${sample}.png

    # Run tool
    Bandage image $input_gfa $output_png --colour uniform

    count=$(($count+1))
  done

echo "Images of assemblies were succesfully made."
echo "Time stamp: $SECONDS seconds."

