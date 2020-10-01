#!/usr/bin/env bash

# Program: make_db_resfinder.sh
# Description: This program makes a database for ResFinder, which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## make_db_resfinder.sh [-p <path to dairy pipeline>]
    ## -p, path to dairy pipeline folder (str)

# Output:
    ## Outputfile 1
    ## Outputfile 2

# This pipeline consists of 3 steps:
    ## STEP 1: Download database
    ## STEP 2: Index database

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
echo "Starting make_db_resfinder.sh ($date)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: $p"
echo -e "Time stamp: $SECONDS seconds.\n"

################################################################################
# STEP 1: DOWNLOAD DATABASE
################################################################################

if [ ! -d $p/data/db/resfinder ]; then
    git clone https://git@bitbucket.org/genomicepidemiology/resfinder_db.git $p/data/db/resfinder
    chmod -R 774 $p/data/db/resfinder
    cd $p/data/db/resfinder
    python3 $p/data/db/resfinder/INSTALL.py
    chmod -R 774 $p/data/db/resfinder
    fi
    
echo "Database is downloaded for KmerFinder. Timestamp is $SECONDS"


