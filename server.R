
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com

library(shiny)
library(BayesFactor)

data(chickwts)

chickwts <- chickwts[chickwts$feed %in% c('horsebean', 'linseed'), ]
    # Restrict to two groups
chickwts$feed <- factor(chickwts$feed)  # Drop unused factor levels

bf <- ttestBF(formula=weight ~ feed, data=chickwts)

shinyServer(function(input, output) {
    
    output$traditional_t <- renderPrint({
        t.test(weight ~ feed, data=chickwts, var.eq=TRUE)
    })
    
    output$bayes_t <- renderPrint({
        bf
    })
    
    output$posterior_plot <- renderPlot({
        chains <- posterior(bf, iterations=10000)
        plot(chains[, 2])
    })

})
