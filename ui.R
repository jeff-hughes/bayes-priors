
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com

library(shiny)

shinyUI(fluidPage(

    # Application title
    titlePanel('Bayesian Priors'),
    
    sidebarLayout(
        
        # Sidebar
        sidebarPanel(
        ),
        
        # Main panel
        mainPanel(
            verbatimTextOutput('traditional_t'),
            verbatimTextOutput('bayes_t'),
            plotOutput('posterior_plot')
        )
    )
))
