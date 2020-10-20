#!/usr/bin/env bash

# Program: run_plasmidfinder.sh
# Description: This program run PlasmidFinder which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_plasmidfinder.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str or int)

# Output:
    ## Outputfile 1
    ## Outputfile 2

# This pipeline consists of 1 steps:
    ## STEP 1:  Run ResFinder


################################################################################
# GET INPUT
################################################################################

# Load all required modules for the job
module load tools
module load anaconda3/4.4.0
module load anaconda2/2.2.0
module load kma/1.2.11

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to main>] [-n <name of project>] [-d <date of run>]"; exit 1; }

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
echo "Starting run_plasmidfinder.sh ($date)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: ${p}"
echo "Results will be saved: ${n}${d}"

echo -e "Time stamp: $SECONDS seconds.\n"

################################################################################
# STEP 1: RUN PLASMIDFINDER
################################################################################

echo "Starting STEP 1: Run PlasmidFinder"

# Define variables
tool_name=plasmidfinder
tool=/home/projects/cge/apps/${tool_name}/plasmidfinder.py
db=${p}/data/db/${tool_name}/
outputfolder=${p}/results/${n}${d}/${tool_name}

# Make output directory
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir $outputfolder

# Define variables
samples=$(ls ${p}/results/${n}${d}/foodqcpipeline)
count=$((1)) #First sample
total=$(wc -w <<<$samples) #Total number of samples

# Run tool on all samples
for sample in $samples; do
  echo  "Starting with: $sample ($count/$total)"

  # Create sample output folder
  sample_path=${outputfolder}/${sample}
  [ -d $sample_path ] && echo "Output directory: ${sample_path} already exists. Files will be overwritten." || mkdir $sample_path

  # Define tool inputs
  #i=$p/results/${n}${d}/foodqcpipeline/${sample}/Trimmed/*.trim.fq.gz
  i=$p/results/${n}${d}/foodqcpipeline/${sample}/Assemblies/*_trimmed.fa

  # Run tool
  $tool -i $i -o $sample_path -p $db

  echo -e "Finished with $sample.\n"
  count=$(($count+1))
  done

echo "Results of PlasmidFinder were succesfully made."
echo "Time stamp: $SECONDS seconds."

