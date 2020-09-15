#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul  8 12:35:18 2020

@author: catrinehom
"""

# import libraries
from os import listdir
import sys
import glob

mypath = '/home/projects/cge/people/cathom/results/SpeciesFinder'
dirs = [f for f in listdir(mypath)]
outfile = '/home/projects/cge/people/cathom/results/SpeciesFinder_results.txt'
lines = list()
run_zero = 1


for name in dirs:
	path = mypath+'/'+name+'/'+name+'_16srna.spa'
	for filename in glob.glob(path):
		with open(filename, 'r') as f:
			if run_zero == 1:
				lines.append('Sample name\t'+f.readline())
				run_zero = 0
			next(f)
			for line in f:
				lines.append(name+'\t')
				lines.append(line)
					

try:
	outfile = open(outfile, 'w')
	for line in lines:
		outfile.write(line)
	outfile.close()
except IOError as error:
	sys.exit("Cant write to file: {}".format(error))  

