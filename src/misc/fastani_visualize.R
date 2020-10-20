#######
# Purpose: Visualize fastANI core-genome comparison
# Usage: Rscript <this_script>  <query sequence in fasta format> <subject sequence> <fastANI visualization output>
# Output: <fastANI visualization output filename>.pdf
# Uses genoPlotR package: http://genoplotr.r-forge.r-project.org

#Parse command line arguments
query_fasta=commandArgs(TRUE)[0]
subject_fasta=commandArgs(TRUE)[1]
fastANI_visual_file=commandArgs(TRUE)[2]

query_fasta="/home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/foodqcpipeline/EFB1C4ZNN5/Assemblies/EFG1C4ZN5L_TRIMMOMATIC_R1_P_trimmed.fa"
subject_fasta="/home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/foodqcpipeline/EFB1C4ZNN1/Assemblies/EFG1C4ZN5G_TRIMMOMATIC_R1_P_trimmed.fa"
fastANI_visual_file="/home/projects/cge/people/cathom/results/DTU_LAB_20200825_110300/fastani/EFB1C4ZNN5_vs_EFB1C4ZNN1.out"

library(genoPlotR)

#Read fastANI output
comparison <- try(read_comparison_from_blast(fastANI_visual_file))

#Read sequences into genoPlotR objects
Query <- try(read_dna_seg_from_file(query_fasta))
Ref <- try(read_dna_seg_from_file(subject_fasta))

plotTitle = paste(query_fasta, subject_fasta, sep=" v/s ")

pdf( paste(fastANI_visual_file,".pdf",sep="") )

plot_gene_map(dna_segs=list(Query, Ref), comparisons=list(comparison), main=plotTitle, scale=FALSE, scale_cex=1, n_scale_ticks=4)

dev.off()

