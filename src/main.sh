#!/bin/bash

# Program: main
# Description: This program run all parts of the dairy pipeline
# Version: 2.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## main [-n name of project>] [-q <qc>]
    ## -n, name of project
    ## -q, flag to run qc

# Output:
    ## Quality control of data
    ## Assemblies
    ## Species identification 
    ## Resistance genes
    ## Dairy genes 

# This pipeline consists of many steps:
    ## STEP 100: write


################################################################################
# LOADING MODULES
################################################################################

module load tools
module load anaconda3/4.0.0

################################################################################
# WELCOME
################################################################################    

date=$(date "+_%Y%m%d_%H%M%S") 
echo -e "\nWelcome to this amazing program. Your time stamp is ${date}\n"    
   
################################################################################
# PARSING
################################################################################    
    
usage() { echo "Usage: $0 [-n <name of project>] [-h <help>]"; }
exit_abnormal() { usage; exit 1; }

while getopts ":n:h" opt; do
   case "${opt}" in
       n)
           n=${OPTARG}
           ;;
       h)
           h=${OPTARG}
           usage
           exit 1
           ;;
       *)
           echo "Invalid option: ${OPTARG}"
           exit_abnormal
           ;;
   esac
done

################################################################################
# SETUP THE DIRECTORIES
################################################################################

# Get the root folder name
path=$(echo `realpath $0` | rev | cut -d'/' -f4- | rev)
echo -e  "\nRoot path is: ${path}\n"

# Giving permissions
echo -e "Giving permissions to folder ${p} recursively\n"
chmod -R 774 ${path}

# Making project folders
echo -e "Creating folders:\n"
#mkdir -p ${path}/data/${n}/
mkdir -p ${path}/results/${n}${date}/summary
mkdir -p ${path}/doc/${n}
echo -e "\nCreated project folders.\n"

################################################################################
# RUNNING QC
################################################################################

# Unzip compressed raw data
#tar -zxvf ${path}/${n}/data/raw.tar.gz
# Run foodQCpipeline and collect results in results/${n}/summary
#${path}/src/foodqcpipeline/run_foodqcpipeline.sh -p ${path} -n ${n}${date}      
#${path}/src/foodqcpipeline/collect_foodqcpipeline.py -p ${path} -n ${n}${date}
# Compress raw data
#tar -xcvf raw.tar.gz raw

################################################################################
# RUNNING KMERFINDER 
################################################################################

#${path}/src/kmerfinder/run_kmerfinder.sh -p ${path} -n ${n}${date}
#${path}/src/kmerfinder/collect_kmerfinder.sh -p ${path} -n ${n}${date}

################################################################################
# RUNNING RESFINDER
################################################################################

#${path}/src/resfinder/run_resfinder.sh -p ${path} -n ${n}${date}
#${path}/src/resfinder/collect_resfinder.sh -p ${path} -n ${n}${date}

################################################################################
# RUNNING GENEFINDER
################################################################################

#${path}/src/genefinder/run_genefinder.sh -p ${path} -n ${n}${date}
#${path}/src/genefinder/collect_genefinder.sh -p ${path} -n ${n}${date}

################################################################################
# GOODBYE
################################################################################

echo -e "Dairy pipeline completed. Results saved in ${n}${date}"


