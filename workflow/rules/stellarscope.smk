#! /usr/bin/env python
# -*- coding utf-8 -*-

rule stellarscope_assign:
    conda:
        "../envs/stellarscope.yaml"
    wildcard_constraints:
        s_method = "pseudobulk|individual"
    output:
        "results/stellarscope_{s_method}/{s}/{s}_{s_method}-TE_counts.mtx",
        expand("results/stellarscope_{{s_method}}/{{s}}/{{s}}_{{s_method}}-TE_counts_{reassignment}.mtx", reassignment=["all", "average", "choose", "conf", "exclude", "unique"])
    input:
        bam = rules.stellarscope_cellsort.output,
	annotation = rules.telescope_annotation.output,
	barcodes = rules.starsolo_alignment.output[1]
    benchmark:
        "benchmarks/stellarscope_{s_method}/{s}_stellarscope_{s_method}.tsv"
    log:
        "results/stellarscope_{s_method}/{s}/stellarscope.log"
    threads:
        config['telescope_threads']
    params:
        tmpdir = config['local_tmp'],
	out = "results/stellarscope_{s_method}/{s}",
	exp_tag = "{s}_{s_method}",
        pooling_reads = "--pooling_mode {s_method}"
    shell:
        '''
	getrss() {{
	    local cmd=$1
	    local param=$2
	    ps -C $cmd -o args= | grep "$param" | awk '{{$1=int(100 * $1/1024/1024)/100"GB";}}{{ print $1;}}' | while read v; do echo "Memory usage (RSS) for $cmd (param: $param): $v"; done
	}}

	while true; do getrss stellarscope {wildcards.s}; sleep 5; done &

	stellarscope assign\
	    --updated_sam\
	    --exp_tag {params.exp_tag}\
	    --outdir {params.out}\
            {params.pooling_reads}\
            --use_every_reassign_mode\
	    {input.bam}\
	    {input.annotation}\
	    --barcodefile {input.barcodes}\
	    2>&1 | tee {log[0]}
	'''

rule sc_complete:
    input:
        rules.stellarscope_assign.output
    output:
        touch("results/completed/{s}_sc_{s_method}_completed.txt")
