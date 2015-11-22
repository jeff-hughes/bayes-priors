
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com

library(shiny)

shinyUI(fluidPage(

    # Application title
    titlePanel('Bayes Factors for T-Tests'),
    
    sidebarLayout(
        
        # Sidebar
        sidebarPanel(
            h4('Test information', style='margin-top: 0'),
            selectInput('tType', label=HTML('Type of <i>t</i>-test'), choices=list(
                'One sample' = 'onesamp',
                'Independent samples' = 'indep',
                'Related samples' = 'related'
            ), selected='indep'),
            
            textInput('t', label=HTML('<i>t</i>-value:'), value='2.5'),
            
            textInput('df', label='Degrees of freedom:', value='25'),
            
            checkboxInput('onetail', label='One-tailed?'),
            
            h4('Set prior', style='margin-top: 2em'),
            selectInput('prior', label='Select a prior:', choices=list(
                'small (.2)' = 'small',
                'medium (.5)' = 'medium',
                'large (.8)' = 'large',
                'social (.36)' = 'social',
                'determine from N' = 'N'
            )),
            
            textInput('priorText',
                label=HTML('<em>OR</em>, input a specific prior width scale:')),
            
            conditionalPanel(
                condition = 'input.prior == "N"',
                textInput('power',
                    label=HTML('If determining prior from <i>N</i>, input power here:'),
                    value='.8')
            ),
            
            helpText('The prior is set to a Cauchy distribution with a scaling',
                'width equal to the expected effect size. You can either select',
                'a preset effect size, input your own, or infer the expected',
                'effect size based on the power of the test.'),
            
            p('For a more complete explanation of how to use this app, see',
                a('Will Gervais\' blog post.',
                    href='http://willgervais.com/blog/2015/11/20/playing-with-bayes-factors'))
        ),
        
        # Main panel
        mainPanel(
            htmlOutput('freq_t'),
            br(),
            htmlOutput('bayes_t'),
            plotOutput('prior_plot')
        )
    ),
        
    # Footer
    fluidRow(
        p(
            a(
                img(alt='Creative Commons License',
                    src='https://i.creativecommons.org/l/by/4.0/80x15.png',
                    style='vertical-align: middle'),
                rel='license',
                href='http://creativecommons.org/licenses/by/4.0/'
                ),
            'This work is licensed under a',
            a(
                'Creative Commons Attribution 4.0 International License.',
                rel='license',
                href='http://creativecommons.org/licenses/by/4.0/'
                )
        ),
        p('This app is based in part on code by',
            a('Will Gervais.',
                href='http://willgervais.com/blog/2015/11/20/playing-with-bayes-factors')
        ),
        align='center'
    )
))
