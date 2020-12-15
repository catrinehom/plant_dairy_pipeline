#!/usr/bin/env bash

# Program: run_foodqcpipeline.sh
# Description: This program run foodqcpipeline which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_foodqcpipeline.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)

# Output:
    ## Trimmed directory: For each sample there exists 2 trimmed fastq files
    # (1 if single-end), along with a file containing discarded reads, and if
    # paired-end a file containing reads that could not be paired.
    ## Assembly directory: An assembly in FASTA format for each WGS sample.
    # The assembly only contains contigs greater thean 500 bp.
    # For each assembly exists a directory with the details of the assembly.
    ## QC directory: For each sample there exists a single line text file,
    # with all the QC information.

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
echo "Starting run_foodqcpipeline.sh ($datestamp)"
echo "--------------------------------------------------------------------------------"

################################################################################
# STEP 1: RUN FOODQCPIPELINE
################################################################################

# Define variables
tool_name=foodqcpipeline
outputfolder=${path}/results/${name}_${date}/${tool_name}

# Make output directory
[ -d $outputfolder ] || mkdir -p $outputfolder

# Define variables
raw=${path}/data/${name}/raw
samples=$(cat ${path}/results/${name}_${date}/tmp/raw_approved.txt)
count=$((1))
total=$(wc -w <<<$samples)

tool=${path}/tools/${tool_name}/FoodQCPipeline.py

# Run foodqcpipeline for all samples
for sample in $samples
  do
    echo "Running: $sample ($count/$total)"

    # Create sample output folder
    sample_path=${outputfolder}/${sample}
    [ -d $sample_path ] || mkdir $sample_path

    # Define tool inputs
    input=${raw}/${sample}/*.gz
    assembly_output=${sample_path}/Assemblies
    qc_output=${sample_path}/QC
    trim_output=${sample_path}/Trimmed
    tmp_dir=${sample_path}/tmp

    # Run tool
    python3 $tool $input --clean_tmp --assembly_output $assembly_output --qc_output $qc_output --trim_output $trim_output --tmp_dir $tmp_dir --spades > /dev/null 2>&1
    count=$(($count+1))
  done

# Check of all qc are done
jobs_no=$(echo ${samples} | wc -w)
files_no=0
while [ $jobs_no -ne $files_no ]
  do
    sleep 60s
    files_no=$(ls ${outputfolder}/*/QC/*.qc.txt  2> /dev/null  | wc -l)
    echo -ne "Finished with $files_no out of $jobs_no."\\r
  done
echo -e "\nAll assembly and QC completed\n"

# Insert header and sample name
for sample in $samples
  do
    # Define paths
    sample_path=${outputfolder}/${sample}
    qc_output=${sample_path}/QC
    # Add sample name to result
    sed -i "1s/^/${sample}\t/" ${qc_output}/*.qc.txt
    # Insert header in files
    sed -i "1s/^/Sample_name\tRead_name\tBases_(MB)\tQual_Bases(MB)\tQual_bases(%)\tReads\tQual_reads(no)\tQual_reads(%)\tMost_common_adapter_(count)\t2._Most_common_adapter_(count)\tOther_adapters_(count)\tinsert_size\tN50\tno_ctgs\tlongest_size(bp)\ttotal_bps\n/" ${qc_output}/*.qc.txt
  done

# Run collect script
module purge
module load tools
module load anaconda3/4.0.0
${path}/src/${tool_name}/collect_${tool_name}.py -p ${path} -n ${name} -d ${date}

echo -e "The tool ${tool_name} finished in $SECONDS seconds\n"

