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

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("红楼梦词云"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      # sidebarPanel(
      #    sliderInput("bins",
      #                "Number of bins:",
      #                min = 1,
      #                max = 50,
      #                value = 30)
      # ),
     
      sliderInput("range", "Range:",
                  min = 1, max = 80, value = c(5,40)),
     
      # Show a plot of the generated distribution
      mainPanel(
         # plotOutput("distPlot")
        wordcloud2Output("distPlot", width = "100%", height = "600px")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

   
  # filters <- matrix(c("freq file", ".freq.csv", "All files", "*"),2, 2, byrow = TRUE)
  # fileNames <- tk_choose.files(multi = TRUE, filter = filters)
  # for(name in fileNames) {
  #   wordFreq <- read.table(name, header=TRUE);
  #   wordFreq1 <- wordFreq[nchar(as.vector(wordFreq[[1]])) > 1, ]
  #   wordcloud2(wordFreq1)
  # }
  # 

  
   # output$distPlot <- renderPlot({
   #    # generate bins based on input$bins from ui.R
   # })
   
   output$distPlot <- renderWordcloud2({
     # generate bins based on input$bins from ui.R
     range <- input$range
     begin <- range[1]
     end <- range[2]
     freqName <- paste("../../freq/", grep(paste("^第", begin, "回", sep=""), list.files("../../freq"), value=TRUE), sep="")
     wordFreq <- read.table(freqName, header=TRUE);
     wordFreq1 <- wordFreq[nchar(as.vector(wordFreq[[1]])) > 1, ]
     wordcloud2(wordFreq1)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

