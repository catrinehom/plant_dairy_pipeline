#!/usr/bin/env bash

# Program: run_resfinder.sh
# Description: This program run ResFinder which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_resfinder.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str or int)

# Output:
    ## Resistance genes found in each sample

################################################################################
# GET INPUT
################################################################################

# Load all required modules for the job
module purge
module load tools
module load anaconda3/4.4.0
module load anaconda2/2.2.0
module load kma/1.2.11
source /home/projects/cge/apps/env/rf4_env/bin/activate
module load perl
module load ncbi-blast/2.8.1+

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
echo "Starting run_resfinder.sh ($datestamp)"
echo "--------------------------------------------------------------------------------"

################################################################################
# STEP 1: RUN RESFINDER
################################################################################

# Define variables
tool_name=resfinder
#tool=${path}/tools/${tool_name}/run_resfinder.py
tool=/home/projects/cge/apps/resfinder/resfinder/run_resfinder.py
db=${path}/data/db/resfinder
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
  ifq=${path}/results/${name}_${date}/foodqcpipeline/${sample}/Trimmed/*.trim.fq.gz
  #ifa=${sample_path}/Assemblies/*.fa

  # Run tool
  $tool -ifq $ifq -o $sample_path -db_res $db -acq > /dev/null 2>&1

  count=$(($count+1))
  done

# Run collect script
module purge
module load tools
module load anaconda3/4.0.0
${path}/src/${tool_name}/collect_${tool_name}.py -p ${path} -n ${name} -d ${date}

echo -e "The tool ${tool_name} finished in $SECONDS seconds\n"

