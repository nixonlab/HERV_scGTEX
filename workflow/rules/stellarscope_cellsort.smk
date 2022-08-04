#! /usr/bin/env python
# -*- coding utf-8 -*-

rule stellarscope_cellsort:
    conda:
        "../envs/stellarscope.yaml"
    output:
        sorted_bam = "results/starsolo_alignment/{s}/{s}.Aligned.sortedByCB.bam"
    input:
        alignment_bam=rules.starsolo_alignment.output[0],
        filtered_barcodes=rules.starsolo_alignment.output[1]
    benchmark:
        "benchmarks/stellarscope_cellsort/{s}_stellarscope_cellsort.tsv"
    log:
        "results/stellarscope_cellsort/{s}/stellarscope_cellsort.log"
    threads:
        config['stellarscope_cellsort_threads']
    shell:
        '''
stellarscope cellsort --ncpu {threads} --outfile {output.sorted_bam} {input.alignment_bam} {input.filtered_barcodes}

	'''
