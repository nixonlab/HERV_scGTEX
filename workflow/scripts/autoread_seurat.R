
#!/usr/bin/R
########################################################################
## autoread_seurat.R
##
## hreyes 2022
########################################################################
# Use scopetools to read in a seurat object with coding and te transcripts 
########################################################################
# Import libraries and set options
#
library(scopetools)
#
#### function to QC 
stellarscope_cell_qc <- function(the.seurat) {
  fmeta <- the.seurat[['RNA']]@meta.features
  mt_feats <- grepl('^MT-', fmeta$symbol)
  the.seurat[['percent.mt']] <- Seurat::PercentageFeatureSet(the.seurat, features=fmeta[mt_feats, 'id'])
  herv_feats <- !is.na(fmeta$te_class) & fmeta$te_class == 'LTR'
  the.seurat[['percent.HERV']] <- Seurat::PercentageFeatureSet(the.seurat, features=fmeta[herv_feats, 'id'])
  l1_feats <- !is.na(fmeta$te_class) & fmeta$te_class == 'LINE'
  the.seurat[['percent.L1']] <- Seurat::PercentageFeatureSet(the.seurat, features=fmeta[l1_feats, 'id'])
  te_feats <- fmeta$feattype == 'TE'
  the.seurat[['percent.TE']] <- Seurat::PercentageFeatureSet(the.seurat, features=fmeta[te_feats, 'id'])
  
  qc.ncount_rna <- scater::isOutlier(the.seurat$nCount_RNA, log = TRUE, type = "both")
  qc.nfeature_rna <- scater::isOutlier(the.seurat$nFeature_RNA, log = TRUE, type = "both")
  qc.percent_mt <- scater::isOutlier(the.seurat$percent.mt,  type="higher")
  
  thresh <- data.frame(ncount = attr(qc.ncount_rna, "thresholds"),
                       nfeature = attr(qc.nfeature_rna, "thresholds"),
                       mt = attr(qc.percent_mt, "thresholds"))
  
  the.seurat <- subset(the.seurat, subset = nCount_RNA > thresh["lower", "ncount"] &
                         nCount_RNA < thresh["higher", "ncount"] &
                         nFeature_RNA >  thresh["lower", "nfeature"] & 
                         nFeature_RNA < thresh["higher", "nfeature"] & 
                         percent.mt < thresh["higher", "mt"])
  the.seurat
}


########################## read in data ###################################
s.object <- scopetools::load_stellarscope_seurat(stellarscope_dir = snakemake@input[["transposable_elements_dir"]], TE_count_file = snakemake@input[["transposable_elements_mat"]], starsolo_dir = snakemake@input[["protein_coding_dir"]])

# I should really add some before and after violin plots

##### apply QC
s.object.qc <- stellarscope_cell_qc(s.object)

########################## save object ########################## 
# save object
#saveRDS(object = PC.TE.mat, file = paste0(output_merged_matrix, sample_name, "_matrix.Rds"))
saveRDS(object = s.object.qc, file = snakemake@output[["seurat_qc"]])
#

