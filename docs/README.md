# plant_dairy_pipeline #

:warning: **UNDER CONSTRUCTION ** :warning:


## Introduction ##
This pipeline can screen large data-sets of genomic data from e.g. lactic acid bacteria. This will include phylogenic analysis, clustering and identification of genes and pathways of special interest to the food industry with a focus on plant-based dairy products.

This pipeline takes raw reads as input, and will perform QC and assembly of these reads.
Afterwards and analysis of the data will be performed, to determine if any sample could be useful for fermentation plant-based dairy products.

The pipeline is written to be executed on Computerome at DTU. It could be modified to run elsewhere but this would require some work.

**Maintainer:** Line Andresen (linan@dtu.dk) and Catrine Høm (s136574@student.dtu.dk)

## Pipeline overview ##

1. Run QC and assembly (FastQC and SPAdes)
2. Species idenfification (KmerFinder)
3. Phylogeny (...?)
4. Resistance genes (ResFinder)
5. Other genes/pathways (...?)
6. ...?


## Pipeline details ##

### QC and assembly ###

## Output ##

Structure and files


## Run pipeline ##

```
/src/main.sh -n [n]
```

Detailed arguments:

```
  -h, show help message and exits program
  -p, path to dairy pipeline
  -n, name of project
  -d, date of run (optional)
```

