#
#
# This is a Shiny web application to compare different variables of COVID in the prisons.
# Authors: Jakob Orel, Danielle Amonica, Kenna Ebert, Jonathan Shilyansky
# Cornell College, Mt.Vernon, IA
#

library(shiny)
library(maps)
library(dplyr)
# UCLA COVID-19 Behind Bars Project
adult_counts <- read.csv("data/Jail_Prison_Confirmed_Cases_and_Deaths.csv")
adult_counts$CasesPer1k <- (adult_counts$Residents.Confirmed / adult_counts$Residents.Population) * 1000
adult_counts <- adult_counts[which(adult_counts$ID != 1198),]
individual_adult_counts <- adult_counts[which(adult_counts$Name != "STATEWIDE"),]

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Comparing Types of Correctional Facilities"),

    # Sidebar with inputs for variables to compare
    sidebarLayout(
        sidebarPanel(
            selectInput("variable",
                        "Variable:",
                        choices = c("Facility Jurisdiction", "Private vs Public")),
            checkboxGroupInput("state",
                               "States:",
                               choices = c("Texas", "Florida", "Arizona", "California")),
            selectInput("metric",
                        "Metric:",
                        choices= c("Total Cases", "Cases Per 1,000"))
            
        ),

        # Show the boxplots
        mainPanel( 
           plotOutput("texasPlot"),
           plotOutput("floridaPlot"),
           plotOutput("arizonaPlot"),
           plotOutput("californiaPlot")
        )
    )
)

# Define server logic required to draw boxplots
server <- function(input, output) {
    
    # Render texasPlot if selected with designated variable and metric
    output$texasPlot <- renderPlot({
        variableChoice <- ifelse(input$variable == "Facility Jurisdiction", "jurisdiction", "Private_Public")
        metricChoice <- ifelse(input$metric == "Total Cases", "Residents.Confirmed", "CasesPer1k")
        if("Texas" %in% input$state){
            # Look at Texas Prisons
            texasCounts <- individual_adult_counts[which(individual_adult_counts$State == "Texas"),]
            texasPrisons <- texasCounts[which(texasCounts$jurisdiction != "county"),]
            texasPrisons <- texasPrisons[which(texasPrisons$Private_Public == "Public" | texasPrisons$Private_Public == "Private"),]
            
            ggplot(texasPrisons, aes(x=!! rlang::sym(variableChoice), y=!! rlang::sym(metricChoice))) + geom_boxplot(fill="lightblue") +
                labs(title="Number of Resident Cases in Texas", x="Jurisdiction", y="# of Resident Cases")
        }
    })
    
    # Render floridaPlot if selected with designated variable and metric
    output$floridaPlot <- renderPlot({
        variableChoice <- ifelse(input$variable == "Facility Jurisdiction", "jurisdiction", "Private_Public")
        metricChoice <- ifelse(input$metric == "Total Cases", "Residents.Confirmed", "CasesPer1k")
        if("Florida" %in% input$state){
            # Look at Florida Prisons
            floridaCounts <- individual_adult_counts[which(individual_adult_counts$State == "Florida"),]
            floridaPrisons <- floridaCounts[which(floridaCounts$jurisdiction != "county"),]
            floridaPrisons <- floridaPrisons[which(floridaPrisons$Private_Public == "Public" | floridaPrisons$Private_Public == "Private"),]
            
            ggplot(floridaPrisons, aes(x=!! rlang::sym(variableChoice), y=!! rlang::sym(metricChoice))) + geom_boxplot(fill="lightblue") +
                labs(title="Number of Resident Cases in Florida", x="Jurisdiction", y="# of Resident Cases")
        }
    })
    
    # Render arizonaPlot if selected with designated variable and metric
    output$arizonaPlot <- renderPlot({
        variableChoice <- ifelse(input$variable == "Facility Jurisdiction", "jurisdiction", "Private_Public")
        metricChoice <- ifelse(input$metric == "Total Cases", "Residents.Confirmed", "CasesPer1k")
        if("Arizona" %in% input$state){
            # Look at Arizona Prisons
            arizonaCounts <- individual_adult_counts[which(individual_adult_counts$State == "Arizona"),]
            arizonaPrisons <- arizonaCounts[which(arizonaCounts$jurisdiction != "county"),]
            arizonaPrisons <- arizonaPrisons[which(arizonaPrisons$Private_Public == "Public" | arizonaPrisons$Private_Public == "Private"),]
            
            ggplot(arizonaPrisons, aes(x=!! rlang::sym(variableChoice), y=!! rlang::sym(metricChoice))) + geom_boxplot(fill="lightblue") +
                labs(title="Number of Resident Cases in Arizona", x="Jurisdiction", y="# of Resident Cases")
        }
    })
    
    # Render californiaPlot if selected with designated variable and metric
    output$californiaPlot <- renderPlot({
        variableChoice <- ifelse(input$variable == "Facility Jurisdiction", "jurisdiction", "Private_Public")
        metricChoice <- ifelse(input$metric == "Total Cases", "Residents.Confirmed", "CasesPer1k")
        if("California" %in% input$state){
            # Look at Arizona Prisons
            californiaCounts <- individual_adult_counts[which(individual_adult_counts$State == "California"),]
            californiaPrisons <- californiaCounts[which(californiaCounts$jurisdiction != "county"),]
            californiaPrisons <- californiaPrisons[which(californiaPrisons$Private_Public == "Public" | californiaPrisons$Private_Public == "Private"),]
            
            ggplot(californiaPrisons, aes(x=!! rlang::sym(variableChoice), y=!! rlang::sym(metricChoice))) + geom_boxplot(fill="lightblue") +
                labs(title="Number of Resident Cases in California", x="Jurisdiction", y="# of Resident Cases")
        }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
