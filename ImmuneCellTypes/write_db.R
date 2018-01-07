library(readr)
library(RSQLite)
library(dplyr)

expr <- read_tsv("../GSE60424_GEOSubmit_FC1to11_normalized_counts.txt")

meta <- read_tsv("../SraRunTable.txt") %>% 
  select("sample" = Sample_Name_s,
         "age" = age_s, "cellcount" = cellcount_s, 
         "celltype" = celltype_s, "disease_status" = diseasestatus_s, 
         "donorid" = donorid_s, "gender" = gender_s, "race" = race_s)
libmap <- read_tsv("../samplemapping.txt", col_names = FALSE)
libmap <- as.data.frame(matrix(libmap[[1]], ncol = 2, byrow = TRUE))
colnames(libmap) <- c("library", "sample")
meta <- merge(meta, libmap)

identifiers <- read_tsv("../mart_export.txt")

conn <- dbConnect(RSQLite::SQLite(), "GSE60424.db")
dbWriteTable(conn, "expr", expr)
dbWriteTable(conn, "meta", meta)
dbWriteTable(conn, "identifiers", identifiers)
dbSendStatement(conn, "CREATE INDEX gene_idx on identifiers (symbol);")
dbSendStatement(conn, "CREATE INDEX ensid_idx on expr (genenames);")
dbDisconnect(conn)
