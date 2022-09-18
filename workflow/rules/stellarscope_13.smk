#! /usr/bin/env python
# -*- coding utf-8 -*-

# while using camel case "getStrandCmd" is not incorrect, python style (PEP8) says we
# should name functions with lowercase letters separated by underscores
# https://peps.python.org/pep-0008/#function-and-variable-names
def get_strand_cmd(wc):
    # input functions are passed a single parameter, wildcards
    # wildcards is a namespace so refer to the variable with a "."
    if wc.smode == "U": # handle the unstranded case
        return ""
    # all other options (R, F, RF, and FR) will just be passed as-is
    return f'--stranded_mode {wc.smode}' # this is a python f-string

rule stellarscope_assign:
    conda: "../envs/stellarscope_13.yaml"
    wildcard_constraints:
        s_method = "pseudobulk|individual"
    output:
        "results/stellarscope_{s_method}/{s}_rep{repnum}_{smode}/{s}_{s_method}_{smode}-TE_counts.mtx"
    input:
        bam = rules.stellarscope_cellsort.output,
        annotation = rules.telescope_annotation.output,
        barcodes = rules.starsolo_alignment.output[1]
    benchmark:
        "benchmarks/stellarscope_{s_method}/{s}_stellarscope_{s_method}_{smode}_rep{repnum}.tsv"
    log:
        "results/stellarscope_{s_method}/{s}_rep{repnum}_{smode}/stellarscope.log"
    threads:
        config['telescope_threads']
    wildcard_constraints:
        repnum="\d+",
        # Q: where to define that repnum = 1-2?
        # A: In the rule we do not need to do this. It will figure this out by the targets you request, see below
        # Q: do we need wildcard constrants for smode?
        # A: not needed, but if not, you can pass an invalid value here that would cause
        #    stellarscope to fail
        smode="U|R|F|RF|FR"
    params:
        tmpdir = config['local_tmp'],
        out = "results/stellarscope_{s_method}/{s}_rep{repnum}_{smode}",
        exp_tag = "{s}_{s_method}_{smode}",
	pooling_reads = "--pooling_mode {s_method}",
        stranded_mode = get_strand_cmd # the function name. this is a "callable" object that takes 1 argument, wildcards.
    shell:
        '''
	stellarscope assign\
	--updated_sam\
	--exp_tag {params.exp_tag}\
	--outdir {params.out}\
	{params.pooling_reads}\
	{params.stranded_mode}\
	--whitelist {input.barcodes}\
	{input.bam}\
	{input.annotation}\
	2>&1 | tee {log[0]}
	'''

# when you request targets then you can specify the reps or stranded mode in the filename
# Below will launch 5 runs of stellarscope. Three runs will use no argument for stranded
# mode and two will use --stranded_mode F. The outputs will all be to different
# directories so we can compare.

rule stellarscope_complete:
    output:
        touch("results/completed/{s}_sc_{s_method}_rep{repnum}_{smode}_completed.txt")
    input:
        rules.stellarscope_assign.output

