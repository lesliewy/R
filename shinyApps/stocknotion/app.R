#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
source("db.R")
source("utils.R")
library(shiny)
library(xts)
library(DT)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("大盘与行业、概念相关性分析"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        selectInput("code", "选择大盘指数:",
                    choices = indexes),
        
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
  
   output$distPlot <- renderPlot({
     print(paste("code:", code(), "begindate:", begindate(), "enddate:",enddate()))
     #data <- corrdata()
     #tradeDate <- data$TRADE_DATE
     #changePct <- data$CHANGE_PCT
     #x1 <- as.xts(changePct, as.Date(tradeDate))
     #plot(x1)
   })
   
   output$table <-  DT::renderDataTable(DT::datatable({
     print("this is in output$table")
     data <- corrNotionData(code(), begindate(), enddate())
   }))
}

# Run the application 
shinyApp(ui = ui, server = server)

