library(shiny)
library(shinythemes)

shinyUI(fluidPage(theme = shinytheme("united"),
  
  # Application title
  titlePanel("Immune Cell Gene Expression Data"),
  
  sidebarLayout(
    sidebarPanel(
      shiny::selectizeInput("ingene", "Choose a gene:", choices = names(lookup), selected = "A1BG"),
      helpText(h4("Data source:")),
      helpText("Linsley PS, Speake C, Whalen E, Chaussabel D.", em("Copy number loss of the interferon gene cluster in                     melanomas is linked to reduced T cell infiltrate and poor patient prognosis."), 
               "PLoS One 2014 Oct 14;9(10):e109760."),
      a(href = "https://www.ncbi.nlm.nih.gov/pubmed/25314013", "On PubMed"), br(),
      a(href = "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE60424", "On GEO")
    ),  
    mainPanel(
       plotOutput("theplot"),
       helpText("Expression values were normalized using the TMM (trimmed mean of m-value) method.",
                "This means that counts have been normalized by library size but not gene length.")
    )
  )
))
