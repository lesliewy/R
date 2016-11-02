#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

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
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
     
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

