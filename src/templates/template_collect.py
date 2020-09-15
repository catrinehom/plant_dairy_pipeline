#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: XXXToolCollectTemplate
Description: This program collect the results from all samples made from XXXtool
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## XXXToolCollectTemplate [-p <path to dairy pipeline>] [-n <name of project>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)

# Output:
    ## XXXOutputfile 1
    ## XXXOutputfile 2

# This pipeline consists of 1 steps:
    ## STEP 1:  Collect results
    ## STEP 2:  Transform results (only for mydbfinder)
"""

# Import libraries
from os import listdir
import sys

###########################################################################
# GET INPUT
###########################################################################

if __name__ == '__main__':
    # Parse input from command line
    parser = ArgumentParser()
    parser.add_argument("-p", dest="p", help="path_to_main")
    parser.add_argument("-n", dest="n", help="name of project")
    args = parser.parse_args()

    # Define input as variables
    main_path = args.p
    project_name = args.n

###########################################################################
# STEP 1:  COLLECT RESULTS
###########################################################################

    # Define variables
    samples = [f for f in listdir(main_path + '/data/' + project_name + '/foodqcpipeline')]
    raw_results_outfile = main_path + '/results/' + project_name + '/summary/XXXtool_results.txt'
    lines = list()
    header_made = False

    # Loop through samples
    print('Start collecting results in one common file for all samples...')
    for sample in samples:
            # Define path for each sample
            sample_result = main_path + '/data/' + project_name + '/folder/resultsfile'
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
        raw_results_file.close()
    except IOError as error:
            sys.exit("Can't write to file: {}".format(error))

    print("Results can be found in: {}.".format(raw_results_outfile))


###########################################################################
# STEP 2:  TRANSFORM RESULTS (only for mydbfinder)
###########################################################################
    print("Starting transformation of results..."

    transformed_results_file = main_path + 'results/summary/XXXtool_results_transformed.txt'

    # Find all genes in file
    genes = set()
    for line in file:
        genes.add(line.split()[1].split('.')[0])

    # Make matrix of genes
    genes_matrix = dict()
    for sample in samples:
        genes_matrix[sample] = [0] * len(genes)

    # Find gene hits for each sample
    with open(raw_results_outfile, 'r') as f:
        next(f)
        for line in f:
            sample = line.split('\t')[0]
            gene = line.split('\t')[1].split('.')[0]
            index = genes.index(gene)
            genes_matrix[sample][index] += 1

    print("Done.")

    # Write transformed result file
    try:
            outfile = open(fileout, 'w')
            joined_genes =' '.join(genes)
            header = ' '.join(['Samples',joined_genes])
            outfile.write(header+'\n')
            for key in genes_matrix:
                joined_values = ' '.join(str(integer) for integer in genes_matrix[key])
                outtext = ' '.join([key,joined_values])
                outfile.write(outtext+'\n')
            outfile.close()
    except IOError as error:
            sys.exit("Cant write to file: {}".format(error))

    print("Transformed results can be found in: {}.".format(fileout))

