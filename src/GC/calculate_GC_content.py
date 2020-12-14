#!/usr/bin/env python
import sys
import os

if len(sys.argv) != 4:
    print("Usage: calculate_GC_content.py <input fasta file> <sample name> <output file>");
    sys.exit(1)

# Open input and output file
try:
    infile = open(sys.argv[1], "r")
    outfile = open(sys.argv[3], "a+")
except IOError as err:
    print("Cant open file:", str(err));
    sys.exit(1)

# Define variables
samplename = sys.argv[2]
seqlist = list()
IUPAC = str.maketrans("ACGTMRYKVHDBacgtmrykvhdbxnsw","TGCAKYRMBDHVTGCAKYRMBDHVXNSW")

# Make header for output file if its empty
filesize = os.path.getsize(sys.argv[3])

#if filesize == 0:
#    print("Sample name \t GC content \t N content", file=outfile)


# collect sequence
for line in infile:
    if not line.startswith(">"):
        seqlist.append("".join(line.split()))

# concatenate sequence and translate
seq = "".join(seqlist)[::-1].translate(IUPAC)

a=seq.count("A")
t=seq.count("T")
c=seq.count("C")
g=seq.count("G")
n=seq.count("N")

gc_content=(g+c)/(a+t+c+g+n)
n_content=(n)/(a+t+c+g+n)


print("{}\t{}\t{}".format(samplename,gc_content,n_content), file=outfile)

# close files
infile.close()
outfile.close()

