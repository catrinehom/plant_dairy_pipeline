#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: collect_kmerfinder.py
Description: This program collect the results from all samples made from KmerFinder
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## collect_kmerfinder.py [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)

# Output:
    ## XXXOutputfile 1
    ## XXXOutputfile 2

# This pipeline consists of 1 steps:
    ## STEP 1:  Collect results
"""
# Import libraries
import sys
import os
import pandas as pd
import numpy as np
from argparse import ArgumentParser


################################################################################
# GET INPUT
################################################################################

if __name__ == "__main__":
    # Parse input from command line
    parser = ArgumentParser()
    parser.add_argument("-p", dest="p", help="path to main folder", required=True, type=str)
    parser.add_argument("-n", dest="n", help="name of project", required=True, type=str)
    parser.add_argument("-d", dest="d", help="date of run", required=True)
    args = parser.parse_args()

    # Define input as variables
    main_path = args.p
    project_name = args.n
    date = "_" + str(args.d)

################################################################################
# STEP 1:  COLLECT RESULTS
################################################################################

    # Define variables
    samples = [f for f in os.listdir(main_path + "/results/" + project_name + date + "/foodqcpipeline")]
    raw_results_outfolder = main_path + "/results/" + project_name + date + "/summary/"
    raw_results_outfile = raw_results_outfolder + "kmerfinder_results.txt"
    lines = list()
    header_made = False

    # Create outputfolder if it doesn't exist
    if not os.path.exists(raw_results_outfolder):
        os.makedirs(raw_results_outfolder)

    # Loop through samples
    print("Start collecting results in one common file for all samples...")
    for sample in samples:
        # Define path for each sample
        sample_path = main_path + "/results/" + project_name + date + "/kmerfinder/" + sample + "/"

        # Find file in path
        kmerfinder_files = [f for f in os.listdir(sample_path) if os.path.isfile(os.path.join(sample_path, f))]

        # Find kmerfinder result files
        for file in kmerfinder_files:
            if file.endswith("_results.txt"):

                # Define path for each sample
                sample_result = sample_path + file

                # Open file
                with open(sample_result, "r") as f:
                    # If this is the first sample, we want to create a header
                    if header_made == False:
                            header = "Sample_name\t"+f.readline()
                            lines.append(header)
                            header_made = True

                            # Collect results in first sample
                            for line in f:
                                    lines.append(sample+"\t"+line)
                    else:
                        # Skip header in rest of the samples
                        next(f)
                        # Collect results
                        for line in f:
                                lines.append(sample+"\t"+line)
    print("Done")

    # Write raw results to file
    try:
        outfile = open(raw_results_outfile, "w")
        for line in lines:
                outfile.write(line)
        outfile.close()
    except IOError as error:
            sys.exit("Can't write to file: {}".format(error))

    print("Results can be found in: {}.".format(raw_results_outfile))

################################################################################
# STEP 2:  TRANSFORM RESULTS
################################################################################
    print("Starting transformation of results...")

    transformed_results_outfile = raw_results_outfolder + "kmerfinder_results_transformed.txt"

    df = pd.read_csv(raw_results_outfile, sep="\t") # make into pandas
    data = df.values  # make into numpy

    # Get unique list of sample names
    samples = np.unique(data[:,0])

    tophits = list()

    # collect tophit for each sample
    for sample in samples:
        sample_m = data[data[:,0]==sample]

        tophit = sample_m[sample_m[:,3].argsort()[::-1]][0]
        tophits.append(tophit)



    print("Transformation is done.")

    # Write transformed result file
    try:
            outfile = open(transformed_results_outfile, "w")
            outfile.write(header)
            for record in tophits:
                outfile.write('\t'.join([str(elem) for elem in record.tolist()]) + '\n')
            outfile.close()
    except IOError as error:
            sys.exit("Can't write to file: {}".format(error))

    print("Transformed results can be found in: {}.".format(transformed_results_outfile))

