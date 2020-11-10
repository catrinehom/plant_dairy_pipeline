#!/usr/bin/env bash

# Program: run_kmerfinder.sh
# Description: This program run kmerfinder which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_kmerfinder.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)

# Output:
    ## Each sample will have results file under project_name/kmerfinder/sample_name
    # the results are split in each database name

# This pipeline consists of 1 steps:
    ## STEP 1:  Run KmerFinder

###########################################################################
# GET INPUT
###########################################################################

# Load all required modules for the job
module purge
module load tools
module load anaconda2/4.0.0
module load SPAdes/3.9.0
module load perl
module load ncbi-blast/2.2.26
module load cgepipeline/20180109
module load kma/1.2.11

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
echo "Starting kmerfinder_run.sh ($datestamp)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: ${path}"
echo "Results will be saved: ${name}_${date}"

################################################################################
# STEP 1: Run KmerFinder
################################################################################

echo "Starting STEP 1: Run KmerFinder"

# Define variables
tool_name=kmerfinder
outputfolder=${path}/results/${name}_${date}/${tool_name}

# Make output directory
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir $outputfolder

# Define variables
samples=$(cat ${path}/results/${name}_${date}/tmp/fastq_approved.txt)
count=$((1))
total=$(wc -w <<<$samples)
tool=${path}/tools/${tool_name}/kmerfinder.py
databases=$(ls ${path}/data/db/${tool_name}/*/* | grep .name | sed -e 's/\.name$//')

# Run tool on all samples
for sample in $samples
  do
  echo  "Starting with: $sample ($count/$total)"

  # Create sample output folder
  sample_path=${outputfolder}/${sample}
  [ -d $sample_path ] && echo "Output directory: ${sample_path} already exists. Files will be overwritten." || mkdir $sample_path

  for database in $databases
    do
      # Define tool inputs
      i=${path}/results/${name}_${date}/foodqcpipeline/${sample}/Trimmed/*.trim.fq.gz
      t=$(echo ${database} | cut -f1 -d'.')
      tax=${t}.tax

      # Run tool
      $tool -db $database -i $i -o $sample_path -tax $tax -x -q
      db_name=$(basename $t)
      # Move result for each database, so it wont overwrite it
      mv ${sample_path}/results.txt ${sample_path}/${db_name}_results.txt
    done
  echo -e "Finished with $sample.\n"
  count=$(($count+1))
  done

echo "Results of KmerFinder were succesfully made."

# Run collect script
module purge
module load tools
module load anaconda3/4.0.0
${path}/src/${tool_name}/collect_${tool_name}.py -p ${path} -n ${name} -d ${date}

echo -e "${tool_name} finished in $SECONDS seconds.\n"

