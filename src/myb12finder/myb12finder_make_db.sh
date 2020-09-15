### First use the download_genes.py script from /misc locally

### Make b12 database ###
genes=$(ls /Users/catrinehom/Dropbox/Speciale/data/b12_db)

for gene in $genes; do sed "s/>/>$gene/g" $gene > with_gene_name_${gene} ; echo "finished with $gene"; done

cat with_gene_name_*.fasta > b12_database_spaces.fsa

sed 's/ /_/g' b12_database_spaces.fsa > b12_database.fsa 

scp /Users/catrinehom/Dropbox/Speciale/data/b12_db/b12_database.fsa cathom@ssh.computerome.dk:/home/projects/cge/people/plantgurt/data/myb12finder_db/b12_database.fsa

module load tools
module load anaconda3/4.4.0 
module load anaconda2/2.2.0  
module load kma/1.2.11 

python /home/projects/cge/people/plantgurt/tools/mydbfinder/curate_database.py -i /home/projects/cge/people/plantgurt/data/myb12finder_db/b12_database.fsa -o /home/projects/cge/people/plantgurt/data/myb12finder_db/

gzip b12_database.fsa

kma index -i /home/projects/cge/people/plantgurt/data/myb12finder_db/b12_database.fsa.gz -o b12_database

