rule autoread_seurat:
    conda:
        "../envs/scopetools_env.yaml"
    wildcard_constraints:
        s_method = "pseudobulk|individual|celltype"
    output:
        seurat_qc = "results/seurat_qc/{s}/{reassignment}/{s}.{s_method}.seuratqc.Rds"
    input:
        protein_coding_dir = "results/starsolo_alignment/{s}/{s}.Solo.out/Gene/filtered/",
        transposable_elements_dir = "results/stellarscope_{s_method}/{s}/",
        transposable_elements_mat = "results/stellarscope_{s_method}/{s}/{s}_{s_method}-TE_counts_{reassignment}.mtx"
    benchmark:
        "benchmarks/autoread_seurat/{s}_{s_method}_{reassignment}.tsv"
    script:
        "../scripts/autoread_seurat.R"

rule sc_complete:
    input:
        rules.autoread_seurat.output
    output:
        touch("results/completed/{s}_sc_{s_method}_{reassignment}_completed.txt")

