library(data.table)

ensid2gene <- data.frame(fread("data/mart_export.txt"), stringsAsFactors = FALSE)
expr <- data.frame(fread("data/expression_matrix_w_metadata.txt"))

ensid2gene <- ensid2gene[ensid2gene$ensId %in% colnames(expr),]
lookup <- unstack(ensid2gene)
choosenames <- names(lookup)

metacols <- grep("^ENSG", colnames(expr), invert = TRUE, value = TRUE)
