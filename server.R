library(shiny)
library(Quandl)
library(data.table)
library(ggplot2)

token<-"YQGJR_JsB38T-YxGVb3i"

Quandl.api_key(token)


rdQcurr <- function(curr){
    # Construct Quandl code for first currency
    codes <- paste("BNP/USD",curr,sep="")
    for(i in 1:length(curr)){
        if (i == 1){
            # Select the date from the first currency
            d <- Quandl(codes[1],start_date="2010-01-01",end_date=Sys.Date() )[,1]
            A <- array(0,dim=c(length(d),length(codes)))
            # Get the rate fom the first curency
            A[,1] <- Quandl(codes[1],start_date="2010-01-01",end_date=Sys.Date() )[,2]
        }
        else{
            # Just get the rates for the remaining currencies
            A[,i] <- Quandl(codes[i],start_date="2010-01-01",end_date=Sys.Date() )[,2]
        }
    }
    df <- data.frame(d,A)
    names(df) <- c("DATE",curr)
    return(df)
}

trump<-read.csv("https://raw.githubusercontent.com/bpb27/political_twitter_archive/master/realdonaldtrump/realdonaldtrump.csv")
trumpdates<-as.Date(trump$created_at, format = '%a %b %d %H:%M:%S +0000 %Y')



function(input, output) {
    
    datasetInput <- reactive({
        input$dataset
        })
    
    dates <- reactive({
      input$dateRange
    })
    
    currencyd<-reactive({subset(rdQcurr(datasetInput()), DATE %between% c(as.character(dates())[1],as.character(dates())[2]))})
    trumpd<-reactive({unique(as.character(trumpdates[trumpdates %between% c(as.character(dates())[1],as.character(dates())[2])]))})
    
    output$currencydata <- renderDataTable({
      currencyd()
    })

    output$trumptweets <- renderTable({
      trumpd()
    })
    
    currencytweets<-reactive({
      currencytweetsdata<-subset(currencyd(), DATE %in% as.Date(trumpd()))
      currencytweetsdata$DATE <-as.character(currencytweetsdata$DATE)
      currencytweetsdata$ratio<- as.numeric(currencytweetsdata[,2]/as.numeric(currencytweetsdata[nrow(currencytweetsdata),2]))
      currencytweetsdata
    })
    
    output$currencytweets <- renderTable({
      currencytweets()
    },
    digits = 6, 
    width = 500
    )
    
    currencytweets<-reactive({
      currencytweetsdata<-subset(currencyd(), DATE %in% as.Date(trumpd()))
      #currencytweetsdata$DATE <-as.character(currencytweetsdata$DATE)
      currencytweetsdata$ratio<- as.numeric(currencytweetsdata[,2]/as.numeric(currencytweetsdata[nrow(currencytweetsdata),2]))
      currencytweetsdata
    })
    
    
    output$plot<-renderPlot({
        g<-ggplot(currencyd(), aes_string(colnames(currencyd())[1], colnames(currencyd())[2]))+geom_line()
        g+geom_point(data = currencytweets(), aes_string(colnames(currencytweets())[1], colnames(currencytweets())[2]), colour = "blue")
    })
    
    output$profit<-renderPrint({
      input$capital*currencytweets()[1,3]
    })
    
}