#!/usr/bin/env bash

# Program: run_dbcan.sh
# Description: This program run dbcan which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_dbcan.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str or int)

# Output:
    ## GH families for all samples

################################################################################
# GET INPUT
################################################################################
# Load all required modules for the job
module purge
module load tools
module load anaconda3/4.4.0

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
echo "Starting run_dbcan.sh ($datestamp)"
echo "--------------------------------------------------------------------------------"

################################################################################
# STEP 1: RUN DBCAN
################################################################################

cd ${path}/tools/dbcan

# Activate env
source ${path}/tools/dbcan/dbcan_env/bin/activate

# Load all required modules for the job
module purge
module load tools
module load anaconda3/4.4.0
module load diamond/0.9.29
module load hmmer/3.2.1
module load prodigal/2.6.3
module load signalp/4.1c

# Define variables
tool_name=dbcan
tool=run_dbcan.py
outputfolder=${path}/results/${name}_${date}/${tool_name}

# Make output directory
[ -d $outputfolder ] || mkdir $outputfolder

# Define variables
samples=$(cat ${path}/results/${name}_${date}/tmp/species_approved.txt)
count=$((1)) #First sample
total=$(wc -w <<<$samples) #Total number of samples

# Run tool on all samples
for sample in $samples; do
  echo  "Running: $sample ($count/$total)"

  # Create sample output folder
  sample_path=${outputfolder}/${sample}
  [ -d $sample_path ] || mkdir $sample_path

  # Define tool inputs
  inputFile=${path}/results/${name}_${date}/prokka/${sample}/${sample}.faa
  inputType=protein
  o=${sample_path}
  gff=${path}/results/${name}_${date}/prokka/${sample}/${sample}.gff

  # Run tool
  $tool $inputFile $inputType --use_signalP=True --out_dir $o -c $gff  > /dev/null 2>&1

  count=$(($count+1))
  done

# Run collect script
module purge
module load tools
module load anaconda3/4.0.0
${path}/src/dbcan/collect_dbcan.py -p ${path} -n ${name} -d ${date}

echo -e "The tool dbcan finished in $SECONDS seconds.\n"

