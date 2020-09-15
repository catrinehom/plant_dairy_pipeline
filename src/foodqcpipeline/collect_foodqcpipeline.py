#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: collect_foodqcpipeline.py
Description: This program collect the results from all samples made from foodqcpipeline
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## collect_foodqcpipeline.py [-p <path>] [-n <name>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)

# Output:
    ## QC_results.txt, summary of QC for all samples

# This pipeline consists of 1 steps:
    ## STEP 1:  Collect results
    ## STEP 2:  Transform results (only for mydbfinder)
"""

# Import libraries
import sys
from argparse import ArgumentParser
from os import listdir
from os.path import isfile, join

################################################################################
# GET INPUT
################################################################################

if __name__ == '__main__':
    # Parse input from command line
    parser = ArgumentParser()
    parser.add_argument("-p", dest="p", help="path to main", required=True)
    parser.add_argument("-n", dest="n", help="name of project", required=True)
    args = parser.parse_args()

    # Define input as variables
    main_path = args.p
    project_name = args.n

################################################################################
# STEP 1:  COLLECT RESULTS
################################################################################

    # Define variables
    samples = [f for f in listdir(main_path + '/data/' + project_name + '/foodqcpipeline')]
    raw_results_outfile = main_path + '/results/' + project_name + '/summary/QC_results.txt'
    lines = list()
    header_made = False

    # Loop through samples
    print('Start collecting results in one common file for all samples...')
    for sample in samples:
            # Define path for each sample
            sample_path = main_path + '/data/' + project_name + '/foodqcpipeline/' + sample + '/QC/'

            # Find files in path
            qc_files = [f for f in listdir(sample_path) if isfile(join(sample_path, f))]

            # Find qc result files
            for file in qc_files:
                if file.endswith('.qc.txt'):
                    sample_result = main_path + '/data/' + project_name + '/foodqcpipeline/' + sample + '/QC/' + file
                else:
                    print("Error: couldnt find qc file for {}.".format(sample))

            # Open file
            with open(sample_result, 'r') as f:
                # If this is the first sample, we want to create a header
                if header_made == False:
                        lines.append('Sample_name\t'+f.readline())
                        header_made = True

                        # Collect results in first sample
                        for line in f:
                                lines.append(sample+'\t'+line)
                else:
                    # Skip header in rest of the samples
                    next(f)
                    # Collect results
                    for line in f:
                            lines.append(sample+'\t'+line)

    print("Done")

    # Write raw results to file
    try:
        outfile = open(raw_results_outfile, 'w')
        for line in lines:
                outfile.write(line)
        outfile.close()
    except IOError as error:
            sys.exit("Can't write to file: {}".format(error))

    print("Results can be found in: {}.".format(raw_results_outfile))

