
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com

library(shiny)
library(BayesFactor)
library(pwr)

`%then%` <- shiny:::`%OR%`

shinyServer(function(input, output) {
    
    t <- reactive({
        validate(
            need(input$t != '', 'Please enter a t-value.') %then%
            need(!is.na(as.numeric(input$t)), 't-value must be numeric.')
        )
        as.numeric(input$t)
    })
    
    df <- reactive({
        validate(
            need(input$df != '', 'Please enter the degrees of freedom for the t-test.') %then%
            need(!is.na(as.numeric(input$df)), 'Degrees of freedom must be numeric.')
        )
        as.numeric(input$df)
    })
    
    # calculate sample size from degrees of freedom
    n <- reactive({
        if (input$tType == 'indep') {
            (df() + 2) / 2  # get the per-condition sample size
        } else {
            df() + 1
        }
    })
    
    # determine proper prior scaling width
    r <- reactive({
        if (input$priorText != '') {
            validate(
                need(!is.na(as.numeric(input$priorText)),
                    'Prior width must be numeric.') %then%
                need(as.numeric(input$priorText) > 0,
                    'Prior width must be positive and non-zero.')
            )
        }
        if (input$prior == 'N') {
            validate(
                need(!is.na(as.numeric(input$power)),
                    'Power must be numeric.') %then%
                need(as.numeric(input$power) > .25,
                    'Power must be positive and non-zero.')
            )
        }
        
        
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
                    type <- switch(input$tType,
                        onesamp='one.sample',
                        indep='two.sample',
                        related='paired')
                    if (input$onetail) {
                        tails <- 'one.sided'
                    } else {
                        tails <- 'two.sided'
                    }
                
                    power.t.test(d=NULL, n=n(), power=as.numeric(input$power),
                        type=type, alternative=tails)$d
                })
        }
    })
    
    # calculate Bayes factor
    bayes_calc <- reactive({
        # set to half-Cauchy if one-tailed test
        if (input$onetail) {
            if (t() >= 0) {
                altInt <- c(0, Inf)
            } else {
                altInt <- c(-Inf, 0)
            }
        } else {
            altInt <- NULL
        }
        
        if (input$tType == 'indep') {
            ttest.tstat(t(), n(), n(), rscale=r(), nullInterval=altInt)
        } else {
            ttest.tstat(t(), n(), rscale=r(), nullInterval=altInt)
        }
    })
    
    output$freq_t <- renderUI({
        # calculate p-value for t-test
        p <- pt(-abs(t()), df=df())
        if (!input$onetail) {
            p <- 2 * p
        }
        
        onetail_output <- ''
        if (input$onetail) {
            onetail_output <- ' (one-tailed)'
        }
        
        HTML(paste0('Frequentist ', tags$i('t'), '-test: ', tags$i('t'), '(',
            df(), ') = ', t(), ', ', tags$i('p'), ' = ', signif(p, 3),
            onetail_output))
    })
    
    output$bayes_t <- renderUI({
        bf <- bayes_calc()
        HTML(paste0('Bayes Factor: ', strong(signif(bf$bf, 3)), ' (&#177;',
            signif(bf$properror, 3), ')'))
    })
    
    output$prior_plot <- renderPlot({
        d <- (t() * 2) / sqrt(df())  # calculate effect size
        
        # handle large effect sizes
        if (abs(d) > 1.8) {
            x <- seq(-(abs(d) + .5), (abs(d) + .5), by=.01)
        } else {
            x <- seq(-2, 2, by=.01)
        }
        alt <- dcauchy(x, scale=r())
        
        if (input$onetail) {
            if (t() >= 0) {
                alt[x < 0] <- 0
            } else {
                alt[x > 0] <- 0
            }
        }
        plot(x, alt, type='l',
            xlab=expression(paste('Effect size (Cohen\'s ', italic(d), ')')),
            ylab='Density')  # plot Cauchy alt. prior
        
        abline(v=0, col='red', lty=5)  # plot null point prior
        
        abline(v=d, col='blue', lty=3)  # draw in observed effect size
        
        legend(
            'topright',
            c('Point null prior', 'Alternative prior', 'Observed effect'),
            lty=c(5, 1, 3),
            col=c('red', 'black', 'blue'))
    })
    
#     output$posterior_plot <- renderPlot({
#         chains <- posterior(bayes_calc(), iterations=10000)
#         plot(chains[, 2])
#     })

})
