#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: collect_all_prokka.py
Description: This program collect the results from all samples made from PROKKA
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## collect_prokka.py [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str or int)

# Output:
    ## One common file with summary of all results from samples
"""

# Import libraries
import sys
import os
import pandas as pd
from argparse import ArgumentParser

################################################################################
# GET INPUT
################################################################################

if __name__ ==  "__main__":
    # Parse input from command line
    parser = ArgumentParser()
    parser.add_argument("-p", dest="p", help="path to main folder", required=True, type=str)
    parser.add_argument("-n", dest="n", help="name of project", required=True, type=str)
    parser.add_argument("-d", dest="d", help="date of run", required=True)
    args = parser.parse_args()

    # Define input as variables
    main_path = args.p
    project_name = args.n
    date = str(args.d)

################################################################################
# STEP 1:  COLLECT RESULTS
################################################################################

# Define variables
samples = [f for f in os.listdir(main_path + "/results/" + project_name + "_" + date + "/prokka/")]
summary_outfolder = main_path + "/results/" + project_name + "_" + date + "/summary/"
raw_results_outfile = summary_outfolder + "prokka_all_results.txt"
lines = list()
all_unique_genes = set()
all_samples = dict()

# Make header
#lines.append("Sample_name\tcontigs\tbases\tCRISPR\tCDS\trRNA\ttRNA\ttmRNA\n")

# Create outputfolder if it doesn't exist
if not os.path.exists(summary_outfolder):
    os.makedirs(summary_outfolder)

# Loop through samples
print("Start collecting results...")
for sample in samples:
    # Define path for each sample
    sample_path = main_path + "/results/" + project_name + "_" + date + "/prokka/" + sample + "/"

    # Find file in path
    tool_files = [f for f in os.listdir(sample_path) if os.path.isfile(os.path.join(sample_path, f))]

    # Collect results
    for file in tool_files:
        sample_name = file.split(".")[0]
        if file.endswith(".tsv"):
            sample_unique_genes = dict()
            sample_result = sample_path + file

            # Open file
            with open(sample_result, "r") as f:

                # Skip header
                f.readline()

                for line in f:
                    if line.split("\t")[1].strip() == "CDS":
                        gene = line.split("\t")[3].strip()

                        if gene in sample_unique_genes:
                            sample_unique_genes[gene] += 1
                        else:
                            sample_unique_genes[gene] = 1

                        # Add to pan genome
                        all_unique_genes.add(gene)

            all_samples[sample_name] = sample_unique_genes


df = pd.DataFrame.from_dict(all_samples, orient='index')
df = df.fillna(0)

# Write raw results to file
df.to_csv(raw_results_outfile, sep = '\t')

print("Results can be found in: {}".format(raw_results_outfile))

