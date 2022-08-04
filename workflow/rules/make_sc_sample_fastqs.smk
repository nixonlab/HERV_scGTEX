#! /usr/bin/env python

def get_sample_files_barcodes(wildcards):
    files = sc_subsamples[sc_subsamples['sample_name'] == wildcards.s]['read1'].tolist()
    return(files)

def get_sample_files_cdna(wildcards):
    files = sc_subsamples[sc_subsamples['sample_name'] == wildcards.s]['read2'].tolist()
    return(files)

localrules: make_sc_sample_fastqs
rule make_sc_sample_fastqs:
    input:
        barcodes = get_sample_files_barcodes,
        cdna = get_sample_files_cdna
    output:
        "samples/single_cell_merged/{s}.bc.fastq.gz",
        "samples/single_cell_merged/{s}.cdna.fastq.gz"
    shell:
        '''
	cat {input.barcodes} > {output[0]}
	cat {input.cdna} > {output[1]}
	'''
          
