# Species identification as a part of plant_dairy_pipeline #

## Introduction ##

This program run KmerFinder which is a part of the dairy pipeline.
KmerFinder is used for species identification based on whole genome data.
The raw reads (fastq) are aligned to a against a kmer database to find best matches.

**Maintainer:** Line Andresen (linan@dtu.dk) and Catrine Høm (s136574@student.dtu.dk)

## Pipeline overview ##

1. Download and install database (make_db_kmerfinder)
2. Run KmerFinder (run_kmerfinder)
3. Make a collected .txt for all samples (collect_kmerfinder)


## Output ##

Raw output from the tool will be a txt found under your main path -> results -> your project name with a data -> kmerfinder.

A summary for all samples can be seen in your main path -> results -> results -> your project name with a data -> summary -> kmerfinder_results.txt.

The following contains a explanation of all columns of the output:

Template: shows the accession numbers or name of the template sequences\
Assembly: RefSeq assembly accession ID\
Num: is the sequence number of accession entry in the KmerFinder database\
Score: is the total number of matching Kmers between the query and the template\
Expected: is the expected score, i.e.the expected total number of matching Kmers between query and template (randomly selected).\
Template length: is the number of Kmers in the template.\
Query_Coverage [%]: is the percentage of input query Kmers that match the template.\
Template_Coverage [%]: is the template coverage.\
Depth: is the number of matched kmers in the query sequence divided by the total number of Kmers in the template. For read files this estimates the sequencing depth.\
tot_query_Coverage [%]: is calculated based on the ratio of the score and the number of kmers in the query sequence, where the score includes kmers matched before.\
tot_template_Coverage [%]: is calculated based on ratio of the score and the number of unique kmers in the template sequence, where the score includes kmers matched before.\
tot_depth: depth value based on all query kmers that can be found in the template sequence.\
q_value: is the quantile in a standard Pearson Chi-square test, to test whether the current template is a significant hit.\
p_value: is the p-value corresponding to the obtained q_value.\
Accession number: accession number of entry ID in fasta file.\
Description: additional descriptions available in fasta file, or in the case of organism databases the identifier lines of fasta files.\
TAXID: NCBI's TaxID number of the hit.\
Taxonomy: complete taxonomy of the hit.\
TAXID Species: NCBI's species TaxID number of the hit (sometimes bacterial strain or substrain TaxIDs can be given above).\
Species: Species name.\

## Run pipeline ##

```
/src/kmerfinder/make_db_kmerfinder -p [path] -n [n]
/src/kmerfinder/run_kmerfinder.sh -p [path] -n [n] -d [date]
/src/kmerfinder/collect_kmerfinder.py -p [path] -n [n] -d [date]
```

Detailed arguments:

```
  -h, show help message and exits program
  -p, path to dairy pipeline
  -n, name of project
  -d, date of run (optional)
```

