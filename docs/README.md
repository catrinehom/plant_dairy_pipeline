# plant_dairy_pipeline #

<div class="text-red">
  UNDER CONSTRUCTION
</div>


## Introduction ##
This pipeline can screen large data-sets of genomic data from e.g. lactic acid bacteria (LAB). This will include phylogenic analysis, clustering and identification of genes and pathways of special interest to the food industry with a focus on plant-based dairy products. It comes with all 2019 QPS LAB references, which have been prerun through the pipeline.

This pipeline takes raw reads as input, and will perform QC and assembly of these reads.
Afterwards and analysis of the data will be performed, to determine if any sample could be useful for fermentation plant-based dairy products.

The pipeline is written to be executed on Computerome at DTU. It could be modified to run elsewhere but this would require some work.

**Maintainer:** Line Andresen (linan@dtu.dk) and Catrine Høm (s136574@student.dtu.dk)

## Pipeline overview ##

1. QC and assembly (FastQC and SPAdes)
2. GC content calculation (calculate_GC_content)
3. Assembly visualisation (Bandage)
4. Species identification (KmerFinder)
5. Average Nucleotide Identity (FastANI)
6. Resistance genes (ResFinder)
7. Pathways: b12, glutamate, iron transporters, exopolysaccharides (MyDbFinder)
8. GH families (dbcan)
9. Full annotation (PROKKA)
10. Core and pan genome, and Phylogeny (Roary)

## Pipeline details ##

### QC and assembly ###

## Output ##

## Run pipeline ##

```
/src/main.sh -p [path] -n [n]
```

Detailed arguments:

```
  -h, show help message and exits program
  -p, path to dairy pipeline
  -n, name of project
  -d, date of run (optional)
```
