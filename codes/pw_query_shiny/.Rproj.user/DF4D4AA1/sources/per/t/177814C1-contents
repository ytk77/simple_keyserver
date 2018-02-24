library(shiny)
source("fnc_Process.R")


server <- function(input, output) {
    PW <- reactive({
        d1 <- query_passwords(input$username, input$passphrase)
        print(d1)
        return(d1)
    })
    
    output$pwTable <- renderTable({
        PW()
    })
    
}