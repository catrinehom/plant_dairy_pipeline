#!/usr/bin/env bash

# Program: make_db_kmerfinder.sh
# Description: This program makes a database for KmerFinder, which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## make_db_kmerfinder.sh [-p <path to dairy pipeline>]
    ## -p, path to dairy pipeline folder (str)

# Output:
    ## Outputfile 1
    ## Outputfile 2

# This pipeline consists of 3 steps:
    ## STEP 1: Downlad genes
    ## STEP 2: Make database
    ## STEP 3: Index database

################################################################################
# GET INPUT
################################################################################

# Load all required modules for the job
module load tools

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to dairy pipeline>]"; exit 1; }

# Parse flags
while getopts ":p:b:h" opt; do
    case "${opt}" in
        p)
            p=${OPTARG}
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
if [ -z "${p}" ]; then
    echo "p is a required flags"
    usage
fi

date=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting make_db_kmerfinder.sh ($date)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: $p"
echo -e "Time stamp: $SECONDS seconds.\n"

################################################################################
# STEP 1: DOWNLOAD DATABASE
################################################################################

if [ ! -d $p/data/db/kmerfinder ]; then
    mkdir $p/data/db/kmerfinder/
    wget ftp://ftp.cbs.dtu.dk/public/CGE/databases/KmerFinder/version/latest/* -P $p/data/db/kmerfinder
    chmod -R 774 $p/data/db/kmerfinder/
    fi
    
echo "Database is downloaded for KmerFinder. Timestamp is $SECONDS"


