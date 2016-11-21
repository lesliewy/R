#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#source("/home/leslie/MyProject/R/shiny/StoneStory/stoneStoryWordCloud/util.R")
source("util.R")

library(shiny)
library(wordcloud2)
library(DT)

# Define UI for application that draws a histogram
# begin <- seq(1,80)
# end <- seq(begin[1],80)
ui <- fluidPage(
   
   # Application title
   titlePanel("红楼梦词云"),

   sidebarLayout(
     sidebarPanel(
       
       sliderInput("range", "选择文章范围:",
                   min = 1, max = 80, value = c(5,10)),
       
       radioButtons("type", "词语类型:",
                    c("全部" = "all",
                      "仅人物名" = "person")),
       
       selectInput("showwords", "显示词数:",
                   choices = c(50,100,200,300,500)),

       submitButton("生成词云")

     ),
     
     mainPanel(
       tabsetPanel(type = "tabs",
                   tabPanel("词云图", wordcloud2Output("distplot", width = "100%", height = "400px")),
                   # tabPanel("表格", tableOutput("table"))
                   tabPanel("表格", DT::dataTableOutput("table"))
       )
     )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  begininput <- reactive({
    input$range[1]
  })
  
  endinput <- reactive({
    input$range[2]
  })
  
  showwords <- reactive({
    input$showwords
  })
  
  type <- reactive({
    input$type
  })
  
  wordfreq <- reactive({
    GetWords(begininput(), input$range[2], input$showwords, type())
  })
  
   output$distplot <- renderWordcloud2({
     print(wordfreq())
     print(nrow(wordfreq()))
     wordcloud2(wordfreq())
     # 后面不能再有其他表达式
   })
   
   output$table <-  DT::renderDataTable(DT::datatable({
     wordfreq1 <- wordfreq()
     wordfreq1[order(wordfreq1[,2], decreasing=T),]
   }))
   
}

# Run the application 
shinyApp(ui = ui, server = server)

