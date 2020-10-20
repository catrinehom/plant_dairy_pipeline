module load tools
module load anaconda2/4.0.0
module load perl/5.30.2
module load roary/3.13.0


################################################################################
# GET INPUT
################################################################################


p=/home/projects/cge/people/cathom
n=DTU_LAB
d=20200825_110300
o=clustered_proteins_all_species
i1=${p}/results/${n}_${d}/prokka/*/*.gff  #—— KUN DE RIGTIGE SPECIES?? SÅ VI VIL HAVE EN LISTE AF SAMPLES ——
i2=${p}/data/ref/Lactococcus_lactis/data/*/*.gff


################################################################################
# STEP 1: RUN ROARY
################################################################################

### Rename reference .gff file, so they have an unique name

gffsamples=$(ls ${p}/data/ref/Lactococcus_lactis/data/*/*.gff)

for gff in $gffsamples
	do
		path=$(dirname ${gff})
		current_name=$(basename ${gff})
		new_name=$(basename $(dirname $gff)).gff

		mv ${path}/${current_name} ${path}/${new_name}
	done

# Run roary
roary -f ${p}/results/${n}_${d}/roary -o $o $i1


### ERROR MESSAGE for ref
#2020/10/01 10:49:35 Input file contains duplicate gene IDs, attempting to fix by adding a unique suffix, new GFF in the fixed_input_files directory: /home/projects/cge/people/cathom/data/ref/Lactococcus_lactis/data/GCF_902364565.1/GCF_902364565.1.gff
#All input files have been excluded from analysis. Please check you have valid GFF files, with annotation and a FASTA sequence at the end. Better still, reannotate your FASTA file with PROKKA. at /services/tools/roary/3.13.0/lib/site_perl/5.26.2/Bio/Roary/CommandLine/Roary.pm line 273.

## TEST AF REFSEQ
roary GCF_002370415.1/*.gff GCF_003255835.1/*.gff GCF_003433375.1/*.gff GCF_004102585.1/*.gff
roary GCF_002370415.1/*.gff GCF_003255835.1/*.gff GCF_003433375.1/*.gff GCF_004102585.1/*.gff GCF_004103675.1/*.gff GCF_004194375.1/*.gff GCF_007954745.1/*.gff GCF_009913915.1/*.gff GCF_009913935.1/*.gff

## TEST AF samples (Lactococcus_lactis)

roary -r EFB1C4ZNK7/*.gff EFB1C4ZNL9/*.gff EFB1C4ZNLB/*.gff EFB1C4ZNLL/*.gff EFB1C4ZNLZ/*.gff EFB1C4ZNN2/*.gff EFB1C4ZNN3/*.gff EFB1C4ZNR8/*.gff EFB1C4ZNRH/*.gff EFB1C4ZNRJ/*.gff EFB1C4ZNRS/*.gff EFB1C4ZNS1/*.gff EFB1C4ZNS2/*.gff EFB1C4ZNS3/*.gff EFB1C4ZNS4/*.gff EFB1C4ZNS7/*.gff EFB1C4ZNS8/*.gff EFB1C4ZNSG/*.gff EFB1C4ZNSH/*.gff EFB1C4ZNSJ/*.gff EFB1C4ZNSK/*.gff EFB1C4ZNT1/*.gff EFB1C4ZNWD/*.gff EFB1C4ZNWT/*.gff EFB1C4ZNWV/*.gff

FastTree –nt –gtr core_gene_alignment.aln > my_tree.newick

/home/projects/cge/people/cathom/src/misc/roary_plots.py my_tree.newick gene_presence_absence.csv

### Receipe for using Roary
# Lactococcus_lactis
path=../../prokka
roary -e -mafft -p 8 -r ${path}/EFB1C4ZNK7/*.gff ${path}/EFB1C4ZNL9/*.gff ${path}/EFB1C4ZNLB/*.gff ${path}/EFB1C4ZNLL/*.gff ${path}/EFB1C4ZNLZ/*.gff ${path}/EFB1C4ZNN2/*.gff ${path}/EFB1C4ZNN3/*.gff ${path}/EFB1C4ZNR8/*.gff ${path}/EFB1C4ZNRH/*.gff ${path}/EFB1C4ZNRJ/*.gff ${path}/EFB1C4ZNRS/*.gff ${path}/EFB1C4ZNS1/*.gff ${path}/EFB1C4ZNS2/*.gff ${path}/EFB1C4ZNS3/*.gff ${path}/EFB1C4ZNS4/*.gff ${path}/EFB1C4ZNS7/*.gff ${path}/EFB1C4ZNS8/*.gff ${path}/EFB1C4ZNSG/*.gff ${path}/EFB1C4ZNSH/*.gff ${path}/EFB1C4ZNSJ/*.gff ${path}/EFB1C4ZNSK/*.gff ${path}/EFB1C4ZNT1/*.gff ${path}/EFB1C4ZNWD/*.gff ${path}/EFB1C4ZNWT/*.gff ${path}/EFB1C4ZNWV/*.gff

FastTree –nt –gtr core_gene_alignment.aln > my_tree.newick

module load pycharm/2019.3.2

/home/projects/cge/people/cathom/src/misc/roary_plots.py my_tree.newick gene_presence_absence.csv

# What are the pan genes?
query_pan_genome -a union *.gff

# What are the core genes?
query_pan_genome -a intersection *.gff

# Leuconostoc_mesenteroides
path=/home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/prokka

roary -e -mafft -p 28 -r -o Leuconostoc_mesenteroides -f /home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/roary/ /home/projects/cge/people/cathom/data/ref/prokka/Leuconostoc_mesenteroides_genomic.fna/*.gff ${path}/EFB1C4ZNN5/*.gff ${path}/EFB1C4ZNRW/*.gff ${path}/EFB1C4ZNV5/*.gff ${path}/EFB1C4ZNV8/*.gff ${path}/EFB1C4ZNVB/*.gff ${path}/EFB1C4ZNW3/*.gff ${path}/EFB1C4ZNW4/*.gff ${path}/EFB1C4ZNV7/*.gff ${path}/EFB1C4ZNV9/*.gff ${path}/EFB1C4ZNVF/*.gff ${path}/EFB1C4ZNVV/*.gff ${path}/EFB1C4ZNVW/*.gff ${path}/EFB1C4ZNW2/*.gff ${path}/EFB1C4ZNW8/*.gff ${path}/EFB1C4ZNVD/*.gff ${path}/EFB1C4ZNVT/*.gff ${path}/EFB1C4ZNWJ/*.gff ${path}/EFB1C4ZNWK/*.gff ${path}/EFB1C4ZNWL/*.gff ${path}/EFB1C4ZNVN/*.gff ${path}/EFB1C4ZNVM/*.gff ${path}/EFB1C4ZNW9/*.gff ${path}/EFB1C4ZNMZ/*.gff ${path}/EFB1C4ZNR0/*.gff ${path}/EFB1C4ZNRK/*.gff ${path}/EFB1C4ZNSC/*.gff ${path}/EFB1C4ZNT0/*.gff ${path}/EFB1C4ZNVX/*.gff ${path}/EFB1C4ZNMW/*.gff ${path}/EFB1C4ZNMX/*.gff ${path}/EFB1C4ZNRD/*.gff ${path}/EFB1C4ZNS5/*.gff ${path}/EFB1C4ZNSM/*.gff ${path}/EFB1C4ZNVQ/*.gff ${path}/EFB1C4ZNN0/*.gff ${path}/EFB1C4ZNQQ/*.gff ${path}/EFB1C4ZNRL/*.gff ${path}/EFB1C4ZNRM/*.gff ${path}/EFB1C4ZNSB/*.gff ${path}/EFB1C4ZNSL/*.gff ${path}/EFB1C4ZNT7/*.gff ${path}/EFB1C4ZNN1/*.gff ${path}/EFB1C4ZNSD/*.gff ${path}/EFB1C4ZNTD/*.gff ${path}/EFB1C4ZNTT/*.gff ${path}/EFB1C4ZNW7/*.gff ${path}/EFB1C4ZNVZ/*.gff ${path}/EFB1C4ZNQT/*.gff ${path}/EFB1C4ZNT6/*.gff ${path}/EFB1C4ZNTH/*.gff ${path}/EFB1C4ZNVS/*.gff ${path}/EFB1C4ZNPM/*.gff ${path}/EFB1C4ZNQR/*.gff ${path}/EFB1C4ZNTB/*.gff ${path}/EFB1C4ZNT4/*.gff ${path}/EFB1C4ZNQV/*.gff ${path}/EFB1C4ZNVL/*.gff ${path}/EFB1C4ZNPX/*.gff ${path}/EFB1C4ZNTS/*.gff ${path}/EFB1C4ZNQ3/*.gff ${path}/EFB1C4ZNRC/*.gff ${path}/EFB1C4ZNTC/*.gff ${path}/EFB1C4ZNW0/*.gff ${path}/EFB1C4ZNNF/*.gff ${path}/EFB1C4ZNT9/*.gff ${path}/EFB1C4ZNPN/*.gff ${path}/EFB1C4ZNPS/*.gff ${path}/EFB1C4ZNQL/*.gff ${path}/EFB1C4ZNQN/*.gff ${path}/EFB1C4ZNNB/*.gff ${path}/EFB1C4ZNPK/*.gff ${path}/EFB1C4ZNV0/*.gff ${path}/EFB1C4ZNTP/*.gff ${path}/EFB1C4ZNT3/*.gff ${path}/EFB1C4ZNN8/*.gff ${path}/EFB1C4ZNT2/*.gff ${path}/EFB1C4ZNKV/*.gff ${path}/EFB1C4ZNQM/*.gff ${path}/EFB1C4ZNRR/*.gff ${path}/EFB1C4ZNPT/*.gff ${path}/EFB1C4ZNN9/*.gff ${path}/EFB1C4ZNW1/*.gff ${path}/EFB1C4ZNS6/*.gff ${path}/EFB1C4ZNVJ/*.gff ${path}/EFB1C4ZNWH/*.gff ${path}/EFB1C4ZNPG/*.gff ${path}/EFB1C4ZNP9/*.gff ${path}/EFB1C4ZNVR/*.gff ${path}/EFB1C4ZNW6/*.gff ${path}/EFB1C4ZNSF/*.gff

