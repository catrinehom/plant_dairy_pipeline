#!/bin/sh
### First use the download_genes.py script from /misc locally
cd /home/projects/cge/people/cathom/data/glutamatefinder_db/

### Make database ###
genes=$(ls /home/projects/cge/people/cathom/data/glutamatefinder_db)

for gene in /home/projects/cge/people/cathom/data/glutamatefinder_db/$genes; do sed "s/>/>$gene/g" $gene > with_gene_name_${gene} ; echo "finished with $gene"; done

cat with_gene_name_*.fasta > glutamate_database_spaces.fsa

sed 's/ /_/g' glutamate_database_spaces.fsa > glutamate_database.fsa 

module load tools
module load anaconda3/4.4.0 
module load anaconda2/2.2.0  
module load kma/1.2.11 

python /home/projects/cge/people/cathom/tools/mydbfinder/curate_database.py -i /home/projects/cge/people/cathom/data/glutamatefinder_db/glutamate_database.fsa -o /home/projects/cge/people/cathom/data/glutamatefinder_db/

gzip glutamate_database.fsa

kma index -i /home/projects/cge/people/cathom/data/glutamatefinder_db/glutamate_database.fsa.gz -o glutamatefinder_database
