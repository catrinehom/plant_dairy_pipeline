#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: collect_mydbfinder.py
Description: This program collect the results from all samples made from MyDbFinder
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## collect_mydbfinder.py [-p <path to dairy pipeline>] [-n <name of project>]  [-d <date of run>] [-b <database name (common name for pathway/gene-set with "_db", e.g. "b12_db")>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run
    ## -b, database name (common name for pathway/gene-set with "_db", e.g. "b12_db") (str)

# Output:
    ## XXXOutputfile 1
    ## XXXOutputfile 2

# This pipeline consists of 1 steps:
    ## STEP 1:  Collect results
    ## STEP 2:  Transform results
"""

# Import libraries
import sys
import os
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
    parser.add_argument("-b", dest="b", help="database name (common name for pathway/gene-set with '_db', e.g. 'b12_db')", required=True, type=str)
    args = parser.parse_args()

    # Define input as variables
    main_path = args.p
    project_name = args.n
    date = str(args.d)
    database_name = args.b


################################################################################
# STEP 1:  COLLECT RESULTS
################################################################################

    # Define variables
    samples = [f for f in os.listdir(main_path + "/results/" + project_name + date + "/foodqcpipeline")]
    raw_results_outfolder = main_path + "/results/" + project_name + date + "/summary/"
    raw_results_outfile = raw_results_outfolder + database_name + "_results.txt"
    raw_results_lines = list()
    header_made = False

    # Create outputfolder if it doesn't exist
    if not os.path.exists(raw_results_outfolder):
        os.makedirs(raw_results_outfolder)

    # Loop through samples
    print("Start collecting results in one common file for all samples...")
    for sample in samples:
            # Define path for each sample
            sample_path = main_path + "/results/" + project_name + date  + "/mydbfinder/" + database_name + "/" + sample + "/"

            # Find file in path
            tool_files = [f for f in os.listdir(sample_path) if os.path.isfile(os.path.join(sample_path, f))]

            # Collect results
            for file in tool_files:
                if file.endswith(".res"):
                    sample_result = sample_path + file

                    # Open file
                    with open(sample_result, "r") as f:

                        # If this is the first sample, we want to create a header
                        if header_made == False:
                                raw_results_lines.append("Sample_name\t"+f.readline())
                                header_made = True

                                # Collect results in first sample
                                for line in f:
                                        raw_results_lines.append(sample+"\t"+line)
                        else:
                            # Skip header in rest of the samples
                            next(f)
                            # Collect results
                            for line in f:
                                    raw_results_lines.append(sample+"\t"+line)

    print("Result collection is done")

    # Write raw results to file
    try:
        outfile = open(raw_results_outfile, "w")
        for line in raw_results_lines:
                outfile.write(line)
        outfile.close()
    except IOError as error:
            sys.exit("Can't write to file: {}".format(error))

    print("Raw results can be found in: {}.".format(raw_results_outfile))


################################################################################
# STEP 2:  TRANSFORM RESULTS (only for mydbfinder)
################################################################################
    print("Starting transformation of results...")

    transformed_results_outfile = raw_results_outfolder + "/" + database_name + "_results_transformed.txt"

    # Find all genes in raw results (but skip header with [1:])
    genes = set()
    for line in raw_results_lines[1:]:
        # Skip header
        genes.add(line.split()[1].split(".")[0])

    # Make genes to list, so it keeps on order (for indexing)
    genes = list(genes)

    # Make matrix of genes
    genes_matrix = dict()
    for sample in samples:
        genes_matrix[sample] = [0] * len(genes)

    # Find gene hits for each sample (but skip header with [1:])
    for line in raw_results_lines[1:]:
        sample = line.split("\t")[0]
        gene = line.split("\t")[1].split(".")[0]
        index = genes.index(gene)
        genes_matrix[sample][index] += 1

    print("Transformation is done.")

    # Write transformed result file
    try:
            outfile = open(transformed_results_outfile, "w")
            joined_genes ="\t".join(genes)
            header = "\t".join(["Samples",joined_genes])
            outfile.write(header+"\n")
            for key in genes_matrix:
                joined_values = "\t".join(str(integer) for integer in genes_matrix[key])
                outtext = "\t".join([key,joined_values])
                outfile.write(outtext+"\n")
            outfile.close()
    except IOError as error:
            sys.exit("Can't write to file: {}".format(error))

    print("Transformed results can be found in: {}.".format(transformed_results_outfile))
    print("If a gene is not found in any of the samples, it will not be added as a column to this file.")

