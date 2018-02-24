#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
source("fnc_Process.R")

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Citi Analytics Password Query"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
          textInput("username", h3("User Name")),
          textInput("passphrase", h3("Passphrase"))
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         tableOutput("pwTable")
      )
   )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
   #  PW <- eventReactive(input$passphrase, {
   #      d1 <- query_passwords(input$username, input$passphrase)
   #  })
   #  
    PW <- reactive({
        d1 <- query_passwords(input$username, input$passphrase)
        return(d1)
    })
    
    output$pwTable <- renderTable({
       PW()
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)

