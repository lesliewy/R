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

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("股票与概念相关性分析"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        textInput("code", "股票代码:", "000001"),
        
        dateRangeInput("daterange", "时间范围:",
                       start = "2016-01-01",
                       end   = "2016-12-31"),
        
        submitButton("开始分析")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   output$distPlot <- renderPlot({
     code <- input$code
     begindate <- input$daterange[1]
     enddate <- input$daterange[2]
     print(paste("code:", code, "begindate:", begindate, "enddate:",enddate))
     StockNotionQuery()
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

