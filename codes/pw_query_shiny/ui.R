fluidPage(
    
    # Application title
    titlePanel("Keyserver's Password Query"),
    
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