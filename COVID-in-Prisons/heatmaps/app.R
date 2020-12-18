#
# This is a Shiny web application to analyze the number of COVID cases/deaths
# compared to the general population.
# Authors: Jakob Orel, Danielle Amonica, Kenna Ebert, Jonathan Shilyansky
# Cornell College, Mt.Vernon, IA
#

library(shiny)
library(maps)
library(dplyr)
# UCLA COVID-19 Behind Bars Project
adult_counts <- read.csv("data/Jail_Prison_Confirmed_Cases_and_Deaths.csv")
# The COVID Tracking Project- Atlantic Monthly
general_counts <- read.csv("data/all-states-12:2.csv")
# U.S. Census Bureau
general_population <- read.csv("data/nst-est2019-alldata.csv")

# Change the variable names to be more user friendly
names(adult_counts)[7:10] <- c("Resident Cases", "Staff Cases", "Resident Deaths", "Staff Deaths")
names(general_counts)[c(22,5)] <- c("Cases", "Deaths")

# Define Map regions
west <- c("Washington", "Oregon", "California", "Nevada", "Idaho", "Utah", "Colorado", "Montana", "Wyoming", "Alaska", "Hawaii")
northeast <- c("Pennsylvania", "New York", "Delaware", "Maryland", "New Jersey", "Connecticut", "Rhode Island", "Massachusetts", "New Hampshire", "Vermont", "Maine")
southeast <- c("West Virginia", "Virginia", "North Carolina", "South Carolina", "Kentucky", "Florida", "Tennessee", "Arkansas", "Louisiana", "Alabama", "Mississippi", "Georgia")
midwest <- c("North Dakota", "South Dakota", "Nebraska", "Kansas", "Iowa", "Missouri", "Minnesota", "Wisconsin", "Michigan", "Illinois", "Indiana", "Ohio")
southwest <- c("Arizona", "New Mexico", "Texas", "Oklahoma")


# Define UI for application that draws the heatmaps
ui <- fluidPage(

    # Application title
    titlePanel("COVID in Prisons"),

    # Sidebar with a select input for choosing variable 
    sidebarLayout(
        sidebarPanel(
            selectInput("choice",
                        "Correctional Facilities Variable: ",
                        choices = colnames(adult_counts[,c(7:10)])),
            selectInput("genpopChoice",
                        "General Population Variable: ",
                        choices = colnames(general_counts[,c(22,5)])),
            radioButtons("metric",
                         "Metric:",
                         choices = c("Total", "Per 100k")),
            radioButtons("region",
                         "Region:",
                         choices = c("West", "Southwest", "Midwest", "Northeast", "Southeast", "Nationwide"),
                         selected = "Nationwide")
        ),

        # Show a heat map
        mainPanel(
           plotOutput("heatMap"),
           plotOutput("genpopHeatMap")
        )
    )
)

# Define server logic required to draw a heat map
server <- function(input, output) {
    
    # Heat map for prisons and jails cases/deaths
    output$heatMap <- renderPlot({
        MainStates <- map_data("state")
        # Build map with specific region
        if(input$region == "West"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(west)),]
        } else if(input$region == "Southwest"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(southwest)),]
        } else if(input$region == "Midwest"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(midwest)),]
        } else if(input$region == "Northeast"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(northeast)),]
        } else if(input$region == "Southeast"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(southeast)),]
        } 
      
        
        # Sum the variable by each state and lowercase state names
        states_values <- adult_counts %>% group_by(State) %>% summarise(SumValue = sum(!! rlang::sym(input$choice), na.rm= TRUE))
        states_values$State <- tolower(states_values$State)
        
        # Merge main state data to include the number value for each state
        mergedStates<- inner_join(MainStates, states_values, by= c("region" = "State"))
        
        stateMap <- ggplot() + geom_polygon(data=mergedStates, aes(x=long, y=lat, group=group, fill=SumValue), color="black", size=.1) + 
            scale_fill_continuous(name=input$choice, low = "lightblue", 
                                  high = "darkblue",
                                  #limits = c(0,30000), breaks=c(5000,10000,15000,20000,25000), 
                                  na.value = "grey50"
                                  ) +
            labs(title="Total in Correctional Facilities Across the U.S.", x= "", y="") +
            theme_bw() +
            theme(axis.line = element_blank(),
                  axis.ticks = element_blank(),
                  axis.text.x = element_blank(),
                  axis.text.y = element_blank())
        stateMap
    })
    
    # Heat map for total cases/deaths and cases/deaths per 100k
    output$genpopHeatMap <- renderPlot({
        MainStates <- map_data("state")
        # Build map with specific region
        if(input$region == "West"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(west)),]
        } else if(input$region == "Southwest"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(southwest)),]
        } else if(input$region == "Midwest"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(midwest)),]
        } else if(input$region == "Northeast"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(northeast)),]
        } else if(input$region == "Southeast"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(southeast)),]
        } 
        
        # Lowercase state names
        general_counts$name <- tolower(general_counts$name)
        
        # If the metric is total cases/deaths
        if(input$metric == "Total"){
            # Merge main state data to include the number value for each state
            mergedStates<- inner_join(MainStates, general_counts, by= c("region" = "name"))
            
            stateMap <- ggplot() + geom_polygon(data=mergedStates, aes(x=long, y=lat, group=group, fill=!! rlang::sym(input$genpopChoice)), color="black", size=.1) + 
                scale_fill_continuous(name=input$genpopChoice, low = "lightblue", 
                                      high = "darkblue",
                                      #limits = c(0,30000), breaks=c(5000,10000,15000,20000,25000), 
                                      na.value = "grey50"
                ) +
                labs(title="Total Across the U.S.", x= "", y="") + 
                theme_bw() +
                theme(axis.line = element_blank(),
                      axis.ticks = element_blank(),
                      axis.text.x = element_blank(),
                      axis.text.y = element_blank())
            stateMap
        }
        # If the metric is cases/deaths per 100k
        else{
            general_population$NAME <- tolower(general_population$NAME)
            general_states <- inner_join(general_counts, general_population, by=c("name" = "NAME"))
            # Do as integer because we do not need precision in a heat map
            general_states$casesPer100k <- as.integer((general_states[,22]/general_states[,59]) * 100000)
            general_states$deathsPer100k <- as.integer((general_states[,5]/general_states[,59]) * 100000)
            
            # if choice is cases, do casesPer100k, else do deathsPer100k
            choiceVar <- ifelse(input$genpopChoice == "positive", "casesPer100k", "deathsPer100k")
            
            # Merge main state data to include the number value for each state
            mergedStates<- inner_join(MainStates, general_states, by= c("region" = "name"))
            
            stateMap <- ggplot() + geom_polygon(data=mergedStates, aes(x=long, y=lat, group=group, fill=!! rlang::sym(choiceVar)), color="black", size=.1) + 
                scale_fill_continuous(name=input$genpopChoice, low = "lightblue", 
                                      high = "darkblue",
                                      #limits = c(0,30000), breaks=c(5000,10000,15000,20000,25000), 
                                      na.value = "grey50"
                ) +
                labs(title="Total Across the U.S.", x= "", y="") + 
                theme_bw() +
                theme(axis.line = element_blank(),
                      axis.ticks = element_blank(),
                      axis.text.x = element_blank(),
                      axis.text.y = element_blank())
            stateMap
        }
        
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
