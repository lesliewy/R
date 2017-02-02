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
library(plotrix)
library(DT)

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("诗人数、诗词数统计"),
  tabsetPanel(type = "tabs",
              tabPanel("诗人数 & 诗词数", plotOutput("authorsAndsPoemPlot")),
              tabPanel("诗人数",  DT::dataTableOutput("authorsTable")),
              tabPanel("诗词数",  DT::dataTableOutput("poemsTable"))
  ),
  hr(),
  titlePanel("诗人的诗词数统计"),
  fluidRow(
    selectInput('incategories', '选择年代', category.name, multiple=TRUE, selectize=TRUE, selected='唐朝')
  ),
  tabsetPanel(type = "tabs",
              tabPanel("图", plotOutput("authorPoemsPlot")),
              tabPanel("表格",  DT::dataTableOutput("authorPoemsTable"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  incategories <- reactive({
    input$incategories
  })
  
  authorPoemsData <- reactive({
    authorPoemsByCate(incategories())
  })
  
  categoryAuthorsData <- reactive({
    categoryAuthorsQuery()
  })
  
  categoryPoemsData <- reactive({
    categoryPoemsQuery()
  })
  
  output$authorsAndsPoemPlot <- renderPlot({
    authorsdata <- categoryAuthorsData()
    poemsdata <- categoryPoemsData()
    
    categories <- as.vector(authorsdata$categoryname)
    totalauthors <- as.vector(authorsdata$totalauthors)
    poems <- as.vector(poemsdata$totalpoems)
    
    # c("先秦", "汉朝", "魏晋", "南北朝", "隋朝", "唐朝", "宋朝", "金朝", "辽朝","元朝", "明朝", "清朝", "近当代")
    categories1 <- c("XQ", "Han", "WJ", "NB", "Sui", "Tang", "Song")
    title <- "Authors of Category"
    #title <- "按朝代统计诗人数、诗词数"
    # colors <- rainbow(length(totalauthors))
    
    # 不适宜用饼图，数据差异太大
    # pie3D(totalauthors,labels=categories1, radius = 3, explode=0.1, main="Authors of Category")
    # pie(totalauthors,labels=categories1, radius = 1.2, main=title)
    # legend("topright", categories1, cex=0.8, fill=colors)
    
    # 单系列横向柱图
    #barplot(totalauthors, names.arg = categories1, xlim=c(0, max(totalauthors) * 1.3), space=2, main=title, col=colors, 
    #        font=2, offset=5, axis.lty=1, horiz=TRUE)
    
    # 多系列横向柱图, 数据必须是矩阵, beside=TRUE 表示诗人数和诗词数并列,而不是在一个柱子上
    colors <-  terrain.colors(2)
    datavector <- c(totalauthors, poems/10)
    multidata <- matrix(datavector, nrow=2, ncol=7, byrow=TRUE)
    par(cex.axis=1,col.axis="red", las=1, fin=c(12, 5.5))
    barplot(multidata, xlim=c(0, max(datavector) * 1.2), main=title, col=colors, axis.lty=1, offset=10, beside=TRUE,
            horiz=TRUE, names.arg = categories1, legend.text = c("authors", "poems"), args.legend = list(x="topright"))
    box()
  })
  
  output$authorsTable <-  DT::renderDataTable(DT::datatable({
    data <- categoryAuthorsData()
  }))

  output$poemsTable <-  DT::renderDataTable(DT::datatable({
    data <- categoryPoemsData()
  }))
  
  output$authorPoemsPlot <- renderPlot({
    data <- authorPoemsData()
    numofpoems <- as.vector(data$numofpoems)
    authornames <- as.vector(data$authorname)
    title <- "Authors Poems"
    # # 单系列竖向柱图
    colors <- rainbow(20)
    barplot(numofpoems[1:20], names.arg = authornames[1:20], ylim=c(0, max(numofpoems) * 1.3), space=1, main=title, col=colors,
           font=2, offset=5, axis.lty=1, horiz=FALSE)
    box()
  })
  
  output$authorPoemsTable <-  DT::renderDataTable(DT::datatable({
    data <- authorPoemsData()
  }))
}

# Run the application 
shinyApp(ui = ui, server = server)

