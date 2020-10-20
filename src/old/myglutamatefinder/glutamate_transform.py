#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from os import listdir
import sys

filein = '/home/projects/cge/people/cathom/results/glutamatefinder/glutamate_results.txt'
fileout = '/home/projects/cge/people/cathom/results/glutamatefinder/glutamate_results_transformed.txt'

#Genes
genes = ['gdhA', 'glmS','glnA','glsA','glsB','gltA','gltB','gltD']
#Samples
mypath = '/home/projects/cge/people/cathom/results/glutamatefinder/'
samples = [f for f in listdir(mypath)]
#samples = ['EFB1C4ZNK7', 'EFB1C4ZNL3', 'EFB1C4ZNLW']

#Do something
#results = dict{samples{[0]*len(genes)}}
d = dict()
for sample in samples:
    d[sample]=[0]*len(genes)

    

with open(filein, 'r') as f:
    next(f)
    for line in f:
        sample = line.split('\t')[0]
        gene = line.split('\t')[1].split('.')[0]
        index = genes.index(gene)
        d[sample][index]+=1

        
try:
        outfile = open(fileout, 'w')
        joined_genes =' '.join(genes)
        header = ' '.join(['Samples',joined_genes])
        outfile.write(header+'\n')
        for key in d:
            joined_values = ' '.join(str(integer) for integer in d[key])
            outtext = ' '.join([key,joined_values])
            outfile.write(outtext+'\n')
        outfile.close()
except IOError as error:
        sys.exit("Cant write to file: {}".format(error)) 
