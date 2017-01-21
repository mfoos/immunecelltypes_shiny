library(shiny)
library(tidyr)
library(dplyr)
library(ggplot2)

shinyServer(function(input, output, session) {
  
  updateSelectizeInput(session, "ingene", choices = choosenames, selected = "HBB", server = TRUE)
  
  makePlot <- function(gene, dat = expr, lookuplist = lookup, meta = metacols){
    ens <- lookuplist[[gene]]
    tinyframe <- dat[,c(ens, meta)]
    tinyframe <- tinyframe %>% gather(variable, value, one_of(ens), -one_of(meta))
    p <- ggplot(tinyframe, aes(x = variable, y = value, color = cellType)) + 
      ggtitle(paste0(gene, " expression by cell type across conditions")) +
      geom_boxplot() +
      theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), axis.title.x = element_blank())
      
    if (length(ens) > 1) {
      p <- p + facet_grid(variable ~ diseaseStatus, scales = "free_y")
    } else { 
      p <- p + facet_grid(~ diseaseStatus)
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
      makePlot(gene = inputgene())
  })
  
})
