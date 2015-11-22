
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
            textInput('t', label=HTML('<i>t</i>-value:'), value='2.5'),
            
            textInput('df', label='Degrees of freedom:', value='23'),
            
            checkboxInput('onetail', label='One-tailed?'),
            
            selectInput('prior', label='Select a prior:', choices=list(
                'small (.2)' = 'small',
                'medium (.5)' = 'medium',
                'large (.8)' = 'large',
                'social (.36)' = 'social',
                'determine from N' = 'N'
            )),
            
            textInput('priorText',
                label=HTML('<em>OR</em>, input a specific prior width scale:')),
            
            textInput('power',
                label=HTML('If determining prior from <i>N</i>, input power here:'),
                value='.8')
        ),
        
        # Main panel
        mainPanel(
            htmlOutput('bayes_t'),
            plotOutput('prior_plot')
        )
    )
))
