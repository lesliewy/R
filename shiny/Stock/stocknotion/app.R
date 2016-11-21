#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
source("db.R")
library(shiny)
library(xts)
library(DT)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("股票与行业、概念相关性分析"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        textInput("code", "股票代码:", "399006"),
        
        dateRangeInput("daterange", "时间范围:",
                       start = "2016-01-01",
                       end   = "2016-1-11"),
        
        submitButton("开始分析")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         #plotOutput("distPlot"),
         #tableOutput("tablePlot")
        DT::dataTableOutput("table")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   code <- reactive({
     input$code
   })
   begindate <- reactive({
     input$daterange[1]
   })   
   enddate <- reactive({
     input$daterange[2]
   })
  
   corrdata <- reactive({
     corrNotionData(code(), begindate(), enddate())
   })
   
   output$distPlot <- renderPlot({
     print(paste("code:", code(), "begindate:", begindate(), "enddate:",enddate()))
     data <- corrdata()
     tradeDate <- data$TRADE_DATE
     changePct <- data$CHANGE_PCT
     x1 <- as.xts(changePct, as.Date(tradeDate))
     plot(x1)
   })
   
   output$table <-  DT::renderDataTable(DT::datatable({
     print("this is in output$table")
     data <- corrNotionData(code(), begindate(), enddate())
   }))
}

corrNotionData <- function(code, begindate, enddate){
  dfIndex <- indexQuery(code, begindate, enddate)
  dfNotions <- notionQuery(begindate, enddate)
  # 对数组框按照factor分组. 把TRADE_DATE的factor去掉，不需要
  dfNotions$TRADE_DATE <- as.character(dfNotions$TRADE_DATE)
  groupNotions <- split(dfNotions, dfNotions$NOTION_NAME)
  
  cordata = lapply(groupNotions, calOneCor, dfIndex)
  print(cordata)
  print(class(cordata))
  return(cordata)
}

calOneCor <- function(dfNotion, dfIndex){
  # 大盘和板块的日期必须一致
  intersectdates <- intersect(dfNotion$TRADE_DATE, dfIndex$TRADE_DATE)
  
  dfnotion1 <- dfNotion[which(dfNotion$TRADE_DATE %in% intersectdates), ]
  dfIndex1 <- dfIndex[which(dfIndex$TRADE_DATE %in% intersectdates),]
  cordata <- cor.test(dfnotion1$CHANGE_PCT, dfIndex1$CHANGE_PCT,method="pearson")
  data <- data.frame(notionName=c(as.character(dfNotion$NOTION_NAME)[1]), p.value=round(c(cordata$p.value), 10), cor=round(c(cordata$estimate), 10), 
              t=round(c(cordata$statistic), 10), alternative=c(cordata$alternative), method=c(cordata$method))
  return(data)
}

# Run the application 
shinyApp(ui = ui, server = server)

