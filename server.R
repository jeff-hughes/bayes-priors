
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com

library(shiny)
library(BayesFactor)
library(pwr)

shinyServer(function(input, output) {
    
    n <- reactive({
        (as.numeric(input$df) + 2) / 2  # get the per-condition sample size
    })
    
    r <- reactive({
        if (input$priorText != '') {
            as.numeric(input$priorText)
        } else {
            switch(input$prior,
                small = .2,
                medium = .5,
                large = .8,
                social = .36,
                N = {
                    # figure out the d that the design would have had adequate
                    # power to detect; with option for a one-tailed test
                    if(input$onetail == TRUE) {
                        power.t.test(d=NULL, n=n(),
                            power=as.numeric(input$power),
                            alternative='one.sided')$d
                    } else {
                        power.t.test(d=NULL, n=n(),
                            power=as.numeric(input$power))$d
                    }
                })
        }
    })
    
    bayes_calc <- reactive({
        t <- as.numeric(input$t)
        if (input$onetail == TRUE) {
            if (t >= 0) {
                ttest.tstat(t, n(), n(), rscale=r(), nullInterval=c(0, Inf))
            } else {
                ttest.tstat(t, n(), n(), rscale=r(), nullInterval=c(-Inf, 0))
            }
        } else {
            ttest.tstat(t, n(), n(), rscale=r())
        }
    })
    
    output$bayes_t <- renderUI({
        bf <- bayes_calc()
        HTML(paste0('Bayes Factor: ', strong(signif(bf$bf, 3)), ' (&#177;', signif(bf$properror, 3), ')'))
    })
    
    output$prior_plot <- renderPlot({
        t <- as.numeric(input$t)
        x <- seq(-2, 2, by=.01)
        alt <- dcauchy(x, scale=r())
        
        if (input$onetail == TRUE) {
            if (t >= 0) {
                alt[x < 0] <- 0
            } else {
                alt[x > 0] <- 0
            }
        }
        plot(x, alt, type='l', xlab='Effect size', ylab='Density')  # plot Cauchy alt. prior
        
        abline(v=0, col='red')  # plot null point prior
        
        d <- (t * 2) / sqrt(as.numeric(input$df))  # calculate effect size
        abline(v=d, col='blue')  # draw in observed effect size
        
        legend(
            'topright',
            c('Point null prior', 'Alternative prior', 'Observed effect'),
            lty=c(1, 1, 1),
            col=c('red', 'black', 'blue'))
    })
    
#     output$posterior_plot <- renderPlot({
#         chains <- posterior(bayes_calc(), iterations=10000)
#         plot(chains[, 2])
#     })

})
