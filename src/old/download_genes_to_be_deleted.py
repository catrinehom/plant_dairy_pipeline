#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 11 15:43:45 2020

@author: catrinehom
"""

# Import libraries
from Bio import Entrez
import re

########################## TO CHANGE ##########################
# Gene list to search for
gene_list = ['cobD', 
'cbiA',
'cbiB', 
'cbiC', 
'cbiD', 
'cbiE', 
'cbiT', 
'cbiF', 
'cbiG', 
'cbiH', 
'cbiJ', 
'cobA', 
'hemD', 
'cbiK',
'cbiL',
'cbiM',
'cbiN',
'cbiQ',
'cbiO',
'cbiP',
'sirA',
'hemA',
'hemC',
'hemB',
'hemL',
'cobU',
'cobS',
'cobC', 
'hemD',
'cobT']

gene_list = ['gltA','glmS']

# Search term after gene for on NCBI (can be "").
search_info = "[gene name] AND (Fungi[Organism] OR Bacteria[Organism]) AND (alive[prop] OR replaced[Properties] OR discontinued[Properties]) "

# Your personal email
email = "s143813@student.dtu.dk"

# Directory to output to (relative path to script or absolute path)
outdir = '/home/projects/cge/people/cathom/scripts/myglutamasefinder/ncbi'

# Max number of entries to retrieve
retmax = 5000
###############################################################

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
    print('All done.\n')
