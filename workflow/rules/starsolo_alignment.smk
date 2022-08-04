rule starsolo_alignment:
    """
    Align sequencing reads from 10x V2 single-cell RNA-seq experiments
    """
    conda:
        "../envs/star.yaml"
    input:
        genome = config['indexes']['star'],
        whitelist = config['whitelist']['v2'],
        CB_reads = 'samples/single_cell_merged/{s}.bc.fastq.gz',
        cDNA_reads = 'samples/single_cell_merged/{s}.cdna.fastq.gz'
    output:
        "results/starsolo_alignment/{s}/{s}.Aligned.sortedByCoord.out.bam",
        "results/starsolo_alignment/{s}/{s}.Solo.out/Gene/filtered/barcodes.tsv"
    params:
        out_prefix = "results/starsolo_alignment/{s}/{s}.",
        cb_start = config['cellbarcode_start'],
        cb_length = config['cellbarcode_length'],
        umi_start = config['umi_start'],
        umi_length = config['umi_length'],
        max_multimap = config['max_multimap']
    benchmark:
        "benchmarks/starsolo_alignment/{s}_starsolo_alignment.tsv"
    threads:
        config['star_alignment_threads']
    shell:
        '''
        #--- STARsolo (turned on by --soloType CB_UMI_Simple)
            STAR\
            --runThreadN {threads}\
            --genomeDir {input.genome}\
            --readFilesIn {input.cDNA_reads} {input.CB_reads}\
            --readFilesCommand gunzip -c\
            --soloType CB_UMI_Simple\
            --soloCBwhitelist {input.whitelist}\
            --soloCBstart {params.cb_start}\
            --soloCBlen {params.cb_length}\
            --soloUMIstart {params.umi_start}\
            --soloUMIlen {params.umi_length}\
            --outFilterMultimapNmax {params.max_multimap}\
            --outSAMattributes NH HI nM AS CR UR CB UB GX GN sS sQ sM\
            --outSAMtype BAM SortedByCoordinate\
            --outFileNamePrefix {params.out_prefix}
        '''

#rule sc_align_all:
#    input:
#        expand("results/starsolo_alignment/{s}/{s}.Aligned.sortedByCoord.out.bam", s=gtex_samples['sn_RNAseq'])

