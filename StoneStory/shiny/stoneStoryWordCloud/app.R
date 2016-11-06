#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(wordcloud2)
library(hash)

# Define UI for application that draws a histogram
# begin <- seq(1,80)
# end <- seq(begin[1],80)
ui <- fluidPage(
   
   # Application title
   titlePanel("红楼梦词云"),

   sidebarLayout(
     sidebarPanel(
       selectInput("begin", "起始回数:",
                   choices = seq(1,80)),

       selectInput("end", "结束回数:",
                   choices = seq(1,80)),
       
       selectInput("showwords", "显示词数:",
                   choices = c(50,100,200,300,500)),

       submitButton("生成词云")

     ),
     
     mainPanel(
       # textOutput("error"),
       wordcloud2Output("distplot", width = "100%", height = "400px"),
       tableOutput("head")
     )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  begininput <- reactive({
    input$begin
  })
  
  endinput <- reactive({
    input$end
  })
  
  showwords <- reactive({
    input$showwords
  })
  
  # output$error <- renderText({
  #   if(begininput() > endinput()){
  #     print("起始回数不能大于结束回数")
  #   }else{
  #     print("")
  #   }
  # })
  
   output$distplot <- renderWordcloud2({
     # 这种直接赋值的不能放在外面
     begin <- input$begin
     end <- input$end
     # showwords有问题，第一次正常，改变输入后，无法获取了.
     showwords <- showwords()
     print(paste("begin:",begin," end:",end," showwords:", showwords))
     wordfreqall <- NULL
     for(i in begin:end){
       freqname <- paste("../../freq/", grep(paste("^第", i, "回", sep=""), list.files("../../freq"), value=TRUE), sep="")
       # stringsAsFactors 方便后面处理, 否则has.key()那里报错
       wordfreq <- read.table(freqname, header=TRUE, stringsAsFactors=FALSE);
       print(paste(freqname,nrow(wordfreq)))
       wordfreqall <- rbind(wordfreqall, wordfreq)
     }
     print(paste("wordfreqall:", nrow(wordfreqall)))
     
     # 不用了这个方法，没办法再将tapply返回的array转成data.frame
     # wordfreqsum <- tapply(wordfreqall$次数, wordfreqall$词语, sum)
     
     h <- hash()
     for(i in 1:nrow(wordfreqall)){
       k <- wordfreqall[i, 1]
       v <- wordfreqall[i, 2]
       if(has.key(k, h)){
         .set(h, k, values(h, keys=k) + v)
       }else{
         .set(h, k, v)
       }
     }
     words <- keys(h)
     count <- values(h)
     wordfreqsum <- data.frame(words, count)
     
     wordfreq1 <- wordfreqsum[nchar(as.vector(wordfreqsum[[1]])) > 1, ]
     print(paste("wordfreq1:", nrow(wordfreq1)))
     # sort
     wordfreq2 <- head(wordfreq1[order(wordfreq1[,2], decreasing=T),], n = 100)
     print(wordfreq2)
     print(nrow(wordfreq2))
     wordcloud2(wordfreq2)
     # 后面不能再有其他表达式
   })
   
   # 不知道怎么获取wordfreq1
   # output$head <- renderTable({
   #   head(wordfreq1[order(wordfreq1[,2], decreasing=T),], n=20)
   # })
   
}

# Run the application 
shinyApp(ui = ui, server = server)

