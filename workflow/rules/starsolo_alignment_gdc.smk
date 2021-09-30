######################################################
## Analyze droplet single-cell RNA sequencing data
## with STARsolo
######################################################
## to do:
## input as function for cDNA and barcodes
## a scheme to name output directories
## see if I can integrate PEP here

rule starsolo_alignment:
	"""
	Align sequencing reads from a 10x V3 single-cell RNA-seq experiment using STARsolo
	"""
	input:
		cDNA_L1 = "data/{dataset}/{sample}_S1_L001_R2_001.fastq.gz",
		cDNA_L2 = "data/{dataset}/{sample}_S1_L002_R2_001.fastq.gz",
		barcode_L1 = "data/{dataset}/{sample}_S1_L001_R1_001.fastq.gz",
		barcode_L2 = "data/{dataset}/{sample}_S1_L002_R1_001.fastq.gz",
		genome = "databases/star_index_GDCHG38_gencode38",
		whitelist = "resources/whitelist/3M-february-2018.txt"
	output:
		"results/{dataset}/{sample}_GDC38.Aligned.out.bam",
		"results/{dataset}/{sample}_GDC38.Aligned.sortedByCoord.out.bam"
	params:
		out_prefix="results/{dataset}/{sample}_GDC38.",
		cb_start=config["cellbarcode_start"],
		cb_length=config["cellbarcode_length"],
		umi_start=config["umi_start"],
		umi_length=config["umi_length"],
		max_multimap=config["max_multimap"]
	conda:
		"../envs/star.yaml"
	threads: 18
	shell:
		'''
		#--- STARsolo (turned on by --soloType CB_UMI_Simple)
		STAR\
			--runThreadN {threads}\
			--genomeDir {input.genome}\
			--readFilesIn {input.cDNA_L1},{input.cDNA_L2} {input.barcode_L1},{input.barcode_L2}\
			--readFilesCommand gunzip -c\
			--soloType CB_UMI_Simple\
			--soloCBwhitelist {input.whitelist}\
			--soloCBstart {params.cb_start}\
			--soloCBlen {params.cb_length}\
			--soloUMIstart {params.umi_start}\
			--soloUMIlen {params.umi_length}\
			--outFilterMultimapNmax {params.max_multimap}\
			--outSAMattributes NH HI nM AS CR UR CB UB GX GN sS sQ sM\
			--outSAMtype BAM Unsorted SortedByCoordinate\
			--outFileNamePrefix {params.out_prefix}
		'''
