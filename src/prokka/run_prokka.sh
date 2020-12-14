#!/usr/bin/env bash

# Program: run_prokka.sh
# Description: This program run PROKKA which is a part of the dairy pipeline
# Version: 1.1
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_prokka.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)

# Output:
    ## gene annotation files for all samples

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
echo "Starting run_prokka.sh ($datestamp)"
echo "--------------------------------------------------------------------------------"

################################################################################
# STEP 1: RUN PROKKA
################################################################################

# Load modules
module purge
module load tools
module load perl
module load ncbi-blast/2.8.1+
module load hmmer/3.2.1
module load aragorn/1.2.36
module load tbl2asn/20191211
module load prodigal/2.6.3
module load infernal/1.1.2
module load barrnap/0.7
module load jdk/15
module load minced/0.2.0
module load rnammer/1.2
module load signalp/4.1c
module load prokka/1.14.0

# Define variables
tool_name=prokka
outputfolder=${path}/results/${name}_${date}/$tool_name

# Make output directory
[ -d $outputfolder ] || mkdir -p $outputfolder


# Define variables
samples_path=${path}/results/${name}_${date}/foodqcpipeline/
samples=$(cat ${path}/results/${name}_${date}/tmp/species_approved.txt)
count=$((1))
total=$(wc -w <<<$samples)

# Run prokka for all samples
for sample in $samples
  do
    echo "Running: $sample ($count/$total)"

    # Create sample output folder
    sample_path=${outputfolder}/${sample}
    [ -d $sample_path ] || mkdir $sample_path

    # Define tool inputs
    input_fasta=${samples_path}/${sample}/Assemblies/*.fa

    # Run tool
    prokka --outdir $sample_path --prefix $sample $input_fasta --force > /dev/null 2>&1

    count=$(($count+1))
  done

# Run collect script
module purge
module load tools
module load anaconda3/4.0.0
${path}/src/${tool_name}/collect_${tool_name}.py -p ${path} -n ${name} -d ${date}
${path}/src/${tool_name}/collect_all_${tool_name}.py -p ${path} -n ${name} -d ${date}

echo -e "The tool ${tool_name} finished in $SECONDS seconds\n"

