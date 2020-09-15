#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: download_genes.py
Description: This program download genes from NCBI based on a file with names of genes (one gene per line in a .txt)
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## download_genes.py [-f <file>] [-n <name>] [-e <email>]
    ## -f, file with gene names (str)
    ## -n, name of pathway/genes, e.g. b12 (str)
    ## -e, your personal email, for NCBI (str)

# Output:
    ## Multifasta files with all search results for each gene

# This pipeline consists of 1 steps:
    ## STEP 1:  Download genes
"""


# Import libraries
from Bio import Entrez
import re

###########################################################################
# GET INPUT
###########################################################################

if __name__ == '__main__':
    # Parse input from command line
    parser = ArgumentParser()
    parser.add_argument("-f", dest="f", help="file with gene names")
    parser.add_argument("-n", dest="n", help="name of pathway/genes")
    parser.add_argument("-e", dest="e", help="your personal email")
    args = parser.parse_args()

    # Define input as variables
    gene_file = args.f
    pathway_name = args.n
    email = args.e

    # Directory to output to (relative path to script or absolute path)
    outdir = '../data/{}_db'.format(pathway_name)

    # Search term after gene for on NCBI (can be "").
    search_info = "[gene name] AND (Fungi[Organism] OR Bacteria[Organism]) AND (alive[prop] OR replaced[Properties] OR discontinued[Properties]) "

    # Max number of entries to retrieve
    retmax = 5000

    # Extract genes from file
    genes = list()
    f = open(gene_file, "r")
    for line in gene_file:
        genes.add(line.strip())
    gene_file.close()


###########################################################################
# DOWNLOAD GENES
###########################################################################

    # For all genes in gene_list
    for gene in gene_list:
        # Collect full search term:
        search_term = gene + search_info

        ### Search on NCBI for gene
        print('Searching on NCBI for: {}'.format(search_term))
        Entrez.email = email  # Always tell NCBI who you are
        search_handle = Entrez.esearch(db="gene",
                                       term=search_term,
                                       idtype="gene", retmax = retmax)
        search_results = Entrez.read(search_handle)
        search_handle.close()


        # Find basic statistics
        acc_list = search_results["IdList"]
        count = int(search_results["Count"])
        retrieved = len(acc_list)
        all_records = count == retrieved


        # Print basic statistics
        print('No. of records found: {}'.format(count))
        print('No. of records retreived: {}'.format(retrieved))
        print('All records retreived?: {}'.format(all_records))
        print('(Maximum no. of records set to retrieve is: {})\n'.format(retmax))


        # Change here, if you only want a subset of the results (mainly for testing)
        idlist = ",".join(search_results["IdList"][:])
        #print(idlist) # subset of IDs


        ### Find gene information
        print('Downloading gene information...')
        handle = Entrez.efetch(db="gene", id=idlist, rettype="fasta", retmode="text")
        records = str(handle.read())
        splitrecord=(re.split('\n\d*\.\ ', records))
        print('Done.')


        # Find patterns
        print('Finding accesion number and start/stop in genome...')

        # Define vartiables
        acc_pattern = '([A-Za-z_0-9]*\.?[0-9]*) \(([0-9]*)\.\.([0-9]*)'
        info = list()

        # Find accession number, start and stop.
        info = []
        for record in splitrecord:
            pat_res = re.search(acc_pattern,record)
            if pat_res != None:
                info.append([pat_res.group(1),pat_res.group(2),pat_res.group(3)])
        print('Done.')

        # Did everything got downloaded as fasta?
        to_downloaded = len(info)
        all_to_download = retrieved == len(info)

        print('No. of records to download: {}'.format(to_downloaded))
        print('All records that was retrieved is ready to download?: {}\n'.format(all_to_download))


        ### Download and write result to file
        print('Downloading records and writing to file...')

        # Open output file
        out_handle = open("{}/{}.fasta".format(outdir,gene.split(' ')[0]), "w")

        # Define variable
        fastas = str()

        # Download fasta file from information found, and write to file
        for i in range(len(info)):
            handle = Entrez.efetch(db="nucleotide", id=info[i][0], rettype="fasta",
                                   retmode="text", seq_start=info[i][1], seq_stop=info[i][2],
                                   validate=False)
            out_handle.write(handle.read()[:-1])

        out_handle.close()
        print('All done.\n')

