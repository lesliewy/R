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
   
   fluidRow(
     column(3,
            selectInput("code", "选择大盘指数:",
                        choices = indexes)
     ),
     column(4, offset = 1,
            dateRangeInput("daterange", "时间范围:",
                           start = "2016-01-01",
                           end   = "2016-1-11")
     )
    # column(4,
    #        submitButton("开始分析")
    # )
   ),
   
   hr(),
   
   # 除非这里有值，才会调用对应的output$table
   tabsetPanel(type = "tabs",
               tabPanel("曲线图", plotOutput("distplot")),
               tabPanel("表格", DT::dataTableOutput("table1"))
   ),
   hr(),
   DT::dataTableOutput("table2")
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
   
   # 程序中多次调用dfIndex(), 但indexQuery()只会执行一次
   # 而且是延迟加载，也就是说等到后边需要使用dfIndex的属性时才会执行indexQeury(), 这里直到 dfIndex$TRADE_DATE
   dfIndex <- reactive({
     indexQuery(code(), begindate(), enddate())
   })
   
   dfNotions <- reactive({
     notionQuery(begindate(), enddate())
   })
  
   output$distplot <- renderPlot({
     print("this is in output$distplot")
     indexdata <- dfIndex()
     data <- corrNotionData(dfIndex(), dfNotions(), "pearson")
     groupdata <- groupNotionData(dfNotions())
     notionname1 <- as.character(data$notionName[1])
     notionname2 <- as.character(data$notionName[2])
     
     notionname3 <- as.character(data$notionName[160])
     notionname4 <- as.character(data$notionName[161])
     notiondata1 <- groupdata[notionname1]
     notiondata2 <- groupdata[notionname2]
     notiondata3 <- groupdata[notionname3]
     notiondata4 <- groupdata[notionname4]
     # 不把list 的tag添加到前面
     notiondata1 <- as.data.frame(notiondata1, col.names = NULL)
     notiondata2 <- as.data.frame(notiondata2, col.names = NULL)
     notiondata3 <- as.data.frame(notiondata3, col.names = NULL)
     notiondata4 <- as.data.frame(notiondata4, col.names = NULL)
     
     indexname <- indexdata$INDEX_NAME[1]
     indexxts <- as.xts(indexdata$CHANGE_PCT, as.Date(indexdata$TRADE_DATE))
     notionxts1 <- as.xts(notiondata1$CHANGE_PCT, as.Date(notiondata1$TRADE_DATE))
     notionxts2 <- as.xts(notiondata2$CHANGE_PCT, as.Date(notiondata2$TRADE_DATE))
     notionxts3 <- as.xts(notiondata3$CHANGE_PCT, as.Date(notiondata3$TRADE_DATE))
     notionxts4 <- as.xts(notiondata4$CHANGE_PCT, as.Date(notiondata4$TRADE_DATE))
     
     print(indexname)
     print(notionname1)
     print(notiondata1)
     print(notionname2)
     print(notiondata2)
     print(notionname3)
     print(notiondata3)
     print(notionname4)
     print(notiondata4)
     
     # shiny plot 图形里不支持中文，还不知道为什么. 也不支持设置线的颜色 col, 这里用不同线型来区分
     plot(indexxts, y=NULL, xlab="Date",ylab="Change Percent(%)", ylim=c(-11, 11), lty=1, col.axis="red", type="l", cex=1.5, main="大盘及与其相似度较高板块走势")
     lines(notionxts1, type="l", lty=2, cex=1.5)
     lines(notionxts2, type="l", lty=3, cex=1.5)
     lines(notionxts3, type="l", lty=4)
     lines(notionxts4, type="l", lty=6)
     legend(x="topright", legend=c("SH.", "other1", "other2", "other3", "other4"), lty=c(1,2,3,4,6))
   })
   
   output$table1 <-  DT::renderDataTable(DT::datatable({
     print("this is in output$table1")
     data <- corrNotionData(dfIndex(), dfNotions(), "pearson")
   }))
   
   output$table2 <-  DT::renderDataTable(DT::datatable({
     print("this is in output$table2")
     data <- corrNotionData(dfIndex(), dfNotions(), "spearman")
   }))
}

# Run the application 
shinyApp(ui = ui, server = server)

