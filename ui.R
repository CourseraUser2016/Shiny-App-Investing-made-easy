library(shiny)
currencies <- c("ARS","AUD","BRL","CAD","CHF",
                "CNY","DKK","EUR","GBP","IDR",
                "ILS","INR","JPY","MXN","MYR",
                "NOK","NZD","PHP","RUB","SEK",
                "THB","TRY")
fluidPage(
    

    titlePanel("The Treasure in Trump's Tweets"),
    
    sidebarLayout(
        sidebarPanel(
            selectInput("dataset", "Choose a currency to be plot against the USD:", 
                        choices = currencies),
            sliderInput("capital", "Choose capital",0,1000000,1000),
            dateRangeInput('dateRange',
              label = paste('Enter date range (yyyy-mm-dd)'),
              start = "2010-01-01", end = "2016-04-18",
              min = "2010-01-01", max = "2016-04-18",
              separator = " to ", format = "yyyy-mm-dd",
              startview = 'year', weekstart = 1
            )
        ),
        
        mainPanel(
            h3("How much would I make from Trump's Tweets?"),
            tabsetPanel(
                tabPanel(
                    "Profit plot",
                    plotOutput("plot"), 
                    textOutput("profit")
                ),
                tabPanel(
                    "Raw data",
                    tabsetPanel(
                      tabPanel(
                        "Currency data",
                        dataTableOutput("currencydata")
                      ),
                      tabPanel(
                        "Trump Tweet data",
                        tableOutput("trumptweets")
                      ),
                      tabPanel(
                        "Profit ratio at a particular tweet",
                        tableOutput("currencytweets")
                      )
                    )
                ),
                tabPanel(
                    "Documentation",
                    includeMarkdown("documentation.md")
                )
            )
        )
    )
)