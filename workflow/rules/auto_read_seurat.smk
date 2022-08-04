rule auto_read_seurat:
    conda:
        "../envs/scopetools_env.yaml"
    output:
        seurat_qc = "results/seurat_qc/{s}/stellarscope_azimuth/{s}_azimuth_seuratqc{reassignment}.Rds"
    input:
        protein_coding_dir = "results/starsolo_alignment/{s}/{s}.Solo.out/Gene/filtered/",
        transposale_elements_dir: "results/stellarscope_azimuth/{s}/"
        transposable_elements_mat = "results/stellarscope_azimuth/{s}/{s}_azimuth_{l}-TE_counts{reassignment}.mtx"
    benchmark:
        "benchmarks/merge_matrices/{s}_azimuth_merge_matrices{reassignment}.tsv"
    script:
        "../scripts/auto_read_seurat.R"

