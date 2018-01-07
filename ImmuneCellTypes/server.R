library(shiny)
library(tidyr)
library(dplyr)
library(ggplot2)
library(RSQLite)

conn <- dbConnect(RSQLite::SQLite(), "GSE60424.db")
choosenames <- dbGetQuery(conn, "SELECT symbol
                          FROM identifiers i
                          INNER JOIN expr e
                          ON i.ensId = e.genenames;")
choosenames <- choosenames[[1]]
dbDisconnect(conn)

shinyServer(function(input, output, session) {
  
  updateSelectizeInput(session, "ingene", choices = choosenames, selected = "HBB", server = TRUE)
  
  makeTinyframe <- function(gene, dbpath){
    conn <- dbConnect(RSQLite::SQLite(), dbpath)
    meta <- dbGetQuery(conn, "SELECT * FROM meta;")
    exprquery <- sprintf("SELECT i.symbol, e.*
                         FROM identifiers i
                         JOIN expr e
                         ON i.ensId = e.genenames
                         WHERE i.symbol == %s;", shQuote(gene))
    expr <- dbGetQuery(conn, exprquery)
    dbDisconnect(conn)
    
    rownames(expr) <- expr$genenames
    togene <- expr[,grep("lib", colnames(expr), invert = TRUE)]
    expr <- expr[,grep("lib", colnames(expr))]
    expr <- t(expr)
    
    tinyframe <- merge(meta, expr, by.x = "library", by.y = 0)
    tinyframe <- tinyframe %>% 
                      gather(gene, TPM, starts_with("ENS")) %>%
                      merge(., togene, by.x = "gene", by.y = "genenames") %>%
                      rename(genename = symbol)
    return(tinyframe)
      
  }
  
  makePlot <- function(tinyframe){
    
    printgene <- unique(tinyframe$genename)

    p <- ggplot(tinyframe, aes(x = genename, y = TPM, color = celltype)) + 
      ggtitle(paste0(printgene, " expression by cell type across conditions")) +
      geom_boxplot() +
      theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), axis.title.x = element_blank())
      
    if (length(unique(tinyframe$gene)) > 1) {
      p <- p + facet_grid(variable ~ disease_status, scales = "free_y")
    } else { 
      p <- p + facet_grid(~ disease_status)
    }
    return(p)
  }
  
  inputgene <- reactive({
    validate(
      need(input$ingene != "", "Please select a gene")
    )
    input$ingene
  })
   
  output$theplot <- renderPlot({
    tf <- makeTinyframe(inputgene(), "GSE60424.db")
    makePlot(tf)
  })
  
})
