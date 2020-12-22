#
# This is a Shiny web application to analyze the number of COVID cases/deaths
# in the correctional facilities of the United States.
#
# Authors: Jakob Orel, Danielle Amonica, Kenna Ebert, Jonathan Shilyansky
# Cornell College, Mt.Vernon, IA
# Date: 12/22/2020
# 
# All Source Code: https://github.com/jakoborel/COVID-in-Prisons

library(shiny)
library(shinydashboard)
#library(maps)
library(dplyr)
library(stringr)
library(ggplot2)

# Data is from 12/02/2020
# UCLA COVID-19 Behind Bars Project
adult_counts <- read.csv("data/Jail_Prison_Confirmed_Cases_and_Deaths.csv")
adult_counts$CasesPer1k <- (adult_counts$Residents.Confirmed / adult_counts$Residents.Population) * 1000
adult_counts$ID[is.na(adult_counts$ID)] <- 0
adult_counts <- adult_counts[which(adult_counts$ID != 1198),]
individual_adult_counts <- adult_counts[which(adult_counts$Name != "STATEWIDE"),]

# The COVID Tracking Project- Atlantic Monthly - 12/2
general_counts <- read.csv("data/all-states-12:2.csv")
# U.S. Census Bureau - 2019
general_population <- read.csv("data/nst-est2019-alldata.csv")
# Bureau of Justice Statistics - 2019
state_prison_population <- read.csv("data/State-Prison-Pop.csv")
state_prison_population$Prison_pop <- as.integer(str_replace_all(state_prison_population$Prison_pop, ",", ""))
state_prison_population$Private_prison_pop <- as.integer(str_replace_all(state_prison_population$Private_prison_pop, ",", ""))
state_prison_population$population <- state_prison_population$Prison_pop + state_prison_population$Private_prison_pop
state_counts <- inner_join(adult_counts, state_prison_population, by="State")

# Make sure we only have State Prisons
state_counts <- state_counts[which(state_counts$jurisdiction == "state"),]

# Change the variable names to be more user friendly
names(adult_counts)[7:10] <- c("Resident Cases", "Staff Cases", "Resident Deaths", "Staff Deaths")
names(general_counts)[c(22,5)] <- c("Cases", "Deaths")
names(state_counts)[7:10] <- c("Resident Cases", "Staff Cases", "Resident Deaths", "Staff Deaths")

# Define Map regions
west <- c("Washington", "Oregon", "California", "Nevada", "Idaho", "Utah", "Colorado", "Montana", "Wyoming", "Alaska", "Hawaii")
northeast <- c("Pennsylvania", "New York", "Delaware", "Maryland", "New Jersey", "Connecticut", "Rhode Island", "Massachusetts", "New Hampshire", "Vermont", "Maine")
southeast <- c("West Virginia", "Virginia", "North Carolina", "South Carolina", "Kentucky", "Florida", "Tennessee", "Arkansas", "Louisiana", "Alabama", "Mississippi", "Georgia")
midwest <- c("North Dakota", "South Dakota", "Nebraska", "Kansas", "Iowa", "Missouri", "Minnesota", "Wisconsin", "Michigan", "Illinois", "Indiana", "Ohio")
southwest <- c("Arizona", "New Mexico", "Texas", "Oklahoma")

# Define UI for application that draws the visualizations
ui <- dashboardPage(skin = "blue",
    dashboardHeader(title = "COVID-19"),
    dashboardSidebar(
        # Create sidebar tabs for each viz.
        sidebarMenu(
            menuItem("Correctional Facility Heatmaps", tabName = "correctionalFacilities"),
            menuItem("State Prison Heatmaps", tabName= "statePrisons"),
            menuItem("Comparing Types of Prisons", tabName = "boxplots"),
            menuItem("Correctional Facility U.S. Map", tabName="facilityMap")
            
        )
    ),              

    dashboardBody(
        tabItems(
            tabItem("correctionalFacilities",
                    fluidPage(
                        
                        # Application title
                        titlePanel("COVID in Correctional Facilities"),
                        
                        # Sidebar with a select input for choosing variable 
                        sidebarLayout(
                            sidebarPanel(
                                # Select variable
                                selectInput("choice",
                                            "Correctional Facilities Variable: ",
                                            choices = colnames(adult_counts[,c(7:10)])),
                                # Select genpop variable (cases/deaths)
                                selectInput("genpopChoice",
                                            "General Population Variable: ",
                                            choices = colnames(general_counts[,c(22,5)])),
                                # Select metric
                                radioButtons("metric",
                                             "Metric:",
                                             choices = c("Total", "Per 100k")),
                                # Select region
                                radioButtons("region",
                                             "Region:",
                                             choices = c("West", "Southwest", "Midwest", "Northeast", "Southeast", "Nationwide"),
                                             selected = "Nationwide"),
                                # Show text boxes
                                textOutput("text1"),
                                textOutput("text2"),
                                textOutput("text3")
                            ),
                            
                            # Show heatmaps
                            mainPanel(
                                plotOutput("heatMap"),
                                plotOutput("genpopHeatMap")
                            )
                        )
                    )
            ),
            tabItem("statePrisons",
                    fluidPage(
                        
                        # Application title
                        titlePanel("COVID in State Prisons"),
                        
                        # Sidebar with a select input for choosing variable 
                        sidebarLayout(
                            sidebarPanel(
                                # Select variable
                                selectInput("statePrisonchoice",
                                            "State Prison Variable: ",
                                            choices = colnames(adult_counts[,c(7:10)])),
                                # Select genpop variable
                                selectInput("statePrisongenpopChoice",
                                            "General Population Variable: ",
                                            choices = colnames(general_counts[,c(22,5)])),
                                # Select metric
                                radioButtons("statePrisonmetric",
                                             "Metric:",
                                             choices = c("Total", "Per 100k")),
                                # Select region
                                radioButtons("statePrisonregion",
                                             "Region:",
                                             choices = c("West", "Southwest", "Midwest", "Northeast", "Southeast", "Nationwide"),
                                             selected = "Nationwide"),
                                # Show text boxes
                                textOutput("text4"),
                                textOutput("text5"),
                                textOutput("text6")
                            ),
                            
                            # Show heatmaps
                            mainPanel(
                                plotOutput("statePrisonheatMap"),
                                plotOutput("statePrisongenpopHeatMap")
                            )
                        )
                    )
            ),
            tabItem("boxplots",
                    fluidPage(
                        
                        # Application title
                        titlePanel("Comparing Types of Prisons"),
                        
                        # Sidebar with inputs for variables to compare
                        sidebarLayout(
                            sidebarPanel(
                                selectInput("variable",
                                            "Variable:",
                                            choices = c("Facility Jurisdiction", "Private vs Public")),
                                checkboxGroupInput("state",
                                                   "States:",
                                                   choices = c("Texas", "Florida", "Arizona", "California", "Nationwide")),
                                selectInput("boxplotMetric",
                                            "Metric:",
                                            choices= c("Total Cases", "Cases Per 1,000")),
                                textOutput("text7"),
                                textOutput("text8"),
                                textOutput("text9")
                            ),
                            
                            # Show the boxplots
                            # I wanted these boxplots to be responsive and wrap the page.
                            # I tried fluidPage and fluidRow but plotOutput creates a designated spot for each viz.
                            # I also tried only plotting one output but then it only shows the last one rendered in the server function
                            mainPanel( 
                                plotOutput("texasPlot"),
                                plotOutput("floridaPlot"),
                                plotOutput("arizonaPlot"),
                                plotOutput("californiaPlot"),
                                plotOutput("nationwidePlot")
                            )
                        )
                        #sidebarLayout
                    )
                    #fluidPage
            ),
            #tabItem
            tabItem("facilityMap",
                    fluidPage(
                        titlePanel("Correctional Facilities across the Mainland U.S."),
                        
                        sidebarLayout(
                            sidebarPanel(
                                # Select the map variable
                                selectInput("facilityMapSelect",
                                            "Select a variable:",
                                            choices = colnames(adult_counts[,c(7:10)])),
                                # Select region
                                radioButtons("facilityMapregion",
                                             "Region:",
                                             choices = c("West", "Southwest", "Midwest", "Northeast", "Southeast", "Nationwide"),
                                             selected = "Nationwide"),
                                # Show text boxes
                                textOutput("text10"),
                                textOutput("text11")
                            ),
                            
                            mainPanel(
                                plotOutput("facilityMapPlot")
                            )
                        )
                    )
            )
        
        )
        #tabItems
    )
    #dashboardBody
)
#dashboardPage
# Define server logic required to draw a histogram
server <- function(input, output) {
    
    # Render the text for the textboxes on the app pages
    output$text1 <- renderText("Updated:  12/2/2020")
    output$text2 <- renderText("Sources: UCLA COVID-19 Behind Bars Project, The COVID Tracking Project- Atlantic Monthly, U.S. Census Bureau 2019")
    output$text3 <- renderText("*Correctional Facilities (top) heatmap does not show population based rates when 'Per 100k' is selected")
    output$text4 <- renderText("Updated:  12/2/2020")
    output$text5 <- renderText("Sources: UCLA COVID-19 Behind Bars Project, The COVID Tracking Project- Atlantic Monthly, U.S. Census Bureau 2019, Bureau of Justice Statistics 2019")
    output$text6 <- renderText("*The 'Per 100k' rate is based on the 2019 state prison populations in each state and the general population estimate from 2019")
    output$text7 <- renderText("Updated: 12/2/2020")
    output$text8 <- renderText("*'Cases Per 1,000' is missing large amounts of data about each facilities population. Missing boxplots indicate lack of data.")
    output$text9 <- renderText("*Nationwide only shows comparison of jurisdiction because of lack of public/private data nationwide")
    output$text10 <- renderText ("Updated: 12/2/2020")
    output$text11 <- renderText("Source: UCLA COVID-19 Behind Bars Project")
    
    
    # Correctional Facilities
    # Heat map for prisons and jails cases/deaths
    output$heatMap <- renderPlot({
        # This one is not affected by the metric input because we have very limited data on population of facilities.
        # To remedy this, we found data for state prison populations in each state and made that comparison on the next tab of the dashboard.
        
        # We originally used map_data to get the basemap data, but this did not work when publishing the Shiny app.
        # Instead, we wrote the dataframe as a csv and load it that way.
        MainStates <- read.csv("data/MainStates.csv")
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
            labs(title=paste("Correctional Facilities COVID-19", input$choice,sep=" "), x= "", y="") +
            theme_bw() +
            theme(axis.line = element_blank(),
                  axis.ticks = element_blank(),
                  axis.text.x = element_blank(),
                  axis.text.y = element_blank())
        stateMap
    })
    
    # Heat map for total cases/deaths and cases/deaths per 100k
    output$genpopHeatMap <- renderPlot({
        MainStates <- read.csv("data/MainStates.csv")
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
                labs(title=paste("General Population COVID-19", input$genpopChoice, sep=" "), x= "", y="") + 
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
            choiceVar <- ifelse(input$genpopChoice == "Cases", "casesPer100k", "deathsPer100k")
            
            # Merge main state data to include the number value for each state
            mergedStates<- inner_join(MainStates, general_states, by= c("region" = "name"))
            
            stateMap <- ggplot() + geom_polygon(data=mergedStates, aes(x=long, y=lat, group=group, fill=!! rlang::sym(choiceVar)), color="black", size=.1) + 
                scale_fill_continuous(name=input$genpopChoice, low = "lightblue", 
                                      high = "darkblue",
                                      #limits = c(0,30000), breaks=c(5000,10000,15000,20000,25000), 
                                      na.value = "grey50"
                ) +
                labs(title=paste("General Population COVID-19", input$genpopChoice, sep=" ") , x= "", y="") + 
                theme_bw() +
                theme(axis.line = element_blank(),
                      axis.ticks = element_blank(),
                      axis.text.x = element_blank(),
                      axis.text.y = element_blank())
            stateMap
        }
        
        
    })
    
    # State Prisons
    # Heat map for prisons and jails cases/deaths
    output$statePrisonheatMap <- renderPlot({
        MainStates <- read.csv("data/MainStates.csv")
        # Build map with specific region
        if(input$statePrisonregion == "West"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(west)),]
        } else if(input$statePrisonregion == "Southwest"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(southwest)),]
        } else if(input$statePrisonregion == "Midwest"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(midwest)),]
        } else if(input$statePrisonregion == "Northeast"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(northeast)),]
        } else if(input$statePrisonregion == "Southeast"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(southeast)),]
        } 
        
        # Sum the variable by each state and lowercase state names
        states_values <- state_counts %>% group_by(State) %>% summarise(SumValue = sum(!! rlang::sym(input$statePrisonchoice), na.rm= TRUE))
        states_values$State <- tolower(states_values$State)
        state_counts$State <- tolower(state_counts$State)
        # Add this variable to the dataframe with statePrisons and populations
        state_counts <- inner_join(state_counts, states_values, by=c("State"))
        
        # Add variable for population rates
        state_counts$residentCasesPer100k <- as.integer((state_counts[,37]/state_counts[,36]) * 100000)
        state_counts$residentDeathsPer100k <- as.integer((state_counts[,37]/state_counts[,36]) * 100000)
        # Does it make sense to do staff cases/deaths / prison population? Not sure of staff population
        state_counts$staffCasesPer100k <- as.integer((state_counts[,37]/state_counts[,36]) * 100000)
        state_counts$staffDeathsPer100k <- as.integer((state_counts[,37]/state_counts[,36]) * 100000)
        
        # if choice is cases, do casesPer100k, else do deathsPer100k
        choiceVar <- if(input$statePrisonchoice == "Resident Cases"){
            "residentCasesPer100k"
        } else if(input$statePrisonchoice == "Staff Cases"){
            "staffCasesPer100k"
        } else if(input$statePrisonchoice == "Resident Deaths"){
            "residentDeathsPer100k"
        } else{
            "staffDeathsPer100k"
        }
        
        # if metric == total do total sum values
        if(input$statePrisonmetric == "Total"){
            # Merge main state data to include the number value for each state
            mergedStates<- inner_join(MainStates, states_values, by= c("region" = "State"))
            stateMap <- ggplot() + geom_polygon(data=mergedStates, aes(x=long, y=lat, group=group, fill=SumValue), color="black", size=.1) + 
                scale_fill_continuous(name=input$statePrisonchoice, low = "lightblue", 
                                      high = "darkblue",
                                      #limits = c(0,30000), breaks=c(5000,10000,15000,20000,25000), 
                                      na.value = "grey50"
                ) +
                labs(title=paste("State Prisons COVID-19", input$statePrisonchoice,sep=" "), x= "", y="") +
                theme_bw() +
                theme(axis.line = element_blank(),
                    axis.ticks = element_blank(),
                    axis.text.x = element_blank(),
                    axis.text.y = element_blank())
            stateMap
        }
        # If not total, do cases/deaths per 100k
        else{
            # Merge main state data to include the values for the population based rates for each state
            mergedStates<- inner_join(MainStates, state_counts, by= c("region" = "State"))
            stateMap <- ggplot() + geom_polygon(data=mergedStates, aes(x=long, y=lat, group=group, fill=!! rlang::sym(choiceVar)), color="black", size=.1) + 
                scale_fill_continuous(name=input$statePrisonchoice, low = "lightblue", 
                                      high = "darkblue",
                                      #limits = c(0,30000), breaks=c(5000,10000,15000,20000,25000), 
                                      na.value = "grey50"
                ) +
                labs(title=paste("State Prisons COVID-19", input$statePrisonchoice,sep=" "), x= "", y="") +
                theme_bw() +
                theme(axis.line = element_blank(),
                      axis.ticks = element_blank(),
                      axis.text.x = element_blank(),
                      axis.text.y = element_blank())
            stateMap
        }
    })
    
    # Heat map for total cases/deaths and cases/deaths per 100k
    output$statePrisongenpopHeatMap <- renderPlot({
        MainStates <- read.csv("data/MainStates.csv")
        # Build map with specific region
        if(input$statePrisonregion == "West"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(west)),]
        } else if(input$statePrisonregion == "Southwest"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(southwest)),]
        } else if(input$statePrisonregion == "Midwest"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(midwest)),]
        } else if(input$statePrisonregion == "Northeast"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(northeast)),]
        } else if(input$statePrisonregion == "Southeast"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(southeast)),]
        } 
        
        # Lowercase state names
        general_counts$name <- tolower(general_counts$name)
        
        # If the metric is total cases/deaths
        if(input$statePrisonmetric == "Total"){
            # Merge main state data to include the number value for each state
            mergedStates<- inner_join(MainStates, general_counts, by= c("region" = "name"))
            
            stateMap <- ggplot() + geom_polygon(data=mergedStates, aes(x=long, y=lat, group=group, fill=!! rlang::sym(input$statePrisongenpopChoice)), color="black", size=.1) + 
                scale_fill_continuous(name=input$statePrisongenpopChoice, low = "lightblue", 
                                      high = "darkblue",
                                      #limits = c(0,30000), breaks=c(5000,10000,15000,20000,25000), 
                                      na.value = "grey50"
                ) +
                labs(title=paste("General Population COVID-19", input$statePrisongenpopChoice, sep=" "), x= "", y="") + 
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
            choiceVar <- ifelse(input$statePrisongenpopChoice == "Cases", "casesPer100k", "deathsPer100k")
            
            # Merge main state data to include the number value for each state
            mergedStates<- inner_join(MainStates, general_states, by= c("region" = "name"))
            
            stateMap <- ggplot() + geom_polygon(data=mergedStates, aes(x=long, y=lat, group=group, fill=!! rlang::sym(choiceVar)), color="black", size=.1) + 
                scale_fill_continuous(name=input$statePrisongenpopChoice, low = "lightblue", 
                                      high = "darkblue",
                                      #limits = c(0,30000), breaks=c(5000,10000,15000,20000,25000), 
                                      na.value = "grey50"
                ) +
                labs(title=paste("General Population COVID-19", input$statePrisongenpopChoice, sep=" ") , x= "", y="") + 
                theme_bw() +
                theme(axis.line = element_blank(),
                      axis.ticks = element_blank(),
                      axis.text.x = element_blank(),
                      axis.text.y = element_blank())
            stateMap
        }
        
        
    })
    
    # Boxplots tab outputs
    # Render texasPlot if selected with designated variable and metric
    output$texasPlot <- renderPlot({
        variableChoice <- ifelse(input$variable == "Facility Jurisdiction", "jurisdiction", "Private_Public")
        metricChoice <- ifelse(input$boxplotMetric == "Total Cases", "Residents.Confirmed", "CasesPer1k")
        if("Texas" %in% input$state){
            # Look at Texas Prisons
            texasCounts <- individual_adult_counts[which(individual_adult_counts$State == "Texas"),]
            texasPrisons <- texasCounts[which(texasCounts$jurisdiction != "county"),]
            texasPrisons <- texasPrisons[which(texasPrisons$Private_Public == "Public" | texasPrisons$Private_Public == "Private"),]
            
            ggplot(texasPrisons, aes(x=!! rlang::sym(variableChoice), y=!! rlang::sym(metricChoice))) + geom_boxplot(fill="lightblue") +
                labs(title=paste(input$boxplotMetric, "in Texas by", input$variable, sep=" "), x="Jurisdiction", y="# of Resident Cases")
        }
    })
    
    # Render floridaPlot if selected with designated variable and metric
    output$floridaPlot <- renderPlot({
        variableChoice <- ifelse(input$variable == "Facility Jurisdiction", "jurisdiction", "Private_Public")
        metricChoice <- ifelse(input$boxplotMetric == "Total Cases", "Residents.Confirmed", "CasesPer1k")
        if("Florida" %in% input$state){
            # Look at Florida Prisons
            floridaCounts <- individual_adult_counts[which(individual_adult_counts$State == "Florida"),]
            floridaPrisons <- floridaCounts[which(floridaCounts$jurisdiction != "county"),]
            floridaPrisons <- floridaPrisons[which(floridaPrisons$Private_Public == "Public" | floridaPrisons$Private_Public == "Private"),]
            
            ggplot(floridaPrisons, aes(x=!! rlang::sym(variableChoice), y=!! rlang::sym(metricChoice))) + geom_boxplot(fill="lightblue") +
                labs(title=paste(input$boxplotMetric, "in Florida by", input$variable, sep=" "), x="Jurisdiction", y="# of Resident Cases")
        }
    })
    
    # Render arizonaPlot if selected with designated variable and metric
    output$arizonaPlot <- renderPlot({
        variableChoice <- ifelse(input$variable == "Facility Jurisdiction", "jurisdiction", "Private_Public")
        metricChoice <- ifelse(input$boxplotMetric == "Total Cases", "Residents.Confirmed", "CasesPer1k")
        if("Arizona" %in% input$state){
            # Look at Arizona Prisons
            arizonaCounts <- individual_adult_counts[which(individual_adult_counts$State == "Arizona"),]
            arizonaPrisons <- arizonaCounts[which(arizonaCounts$jurisdiction != "county"),]
            arizonaPrisons <- arizonaPrisons[which(arizonaPrisons$Private_Public == "Public" | arizonaPrisons$Private_Public == "Private"),]
            
            ggplot(arizonaPrisons, aes(x=!! rlang::sym(variableChoice), y=!! rlang::sym(metricChoice))) + geom_boxplot(fill="lightblue") +
                labs(title=paste(input$boxplotMetric, "in Arizona by", input$variable, sep=" "), x="Jurisdiction", y="# of Resident Cases")
        }
    })
    
    # Render californiaPlot if selected with designated variable and metric
    output$californiaPlot <- renderPlot({
        variableChoice <- ifelse(input$variable == "Facility Jurisdiction", "jurisdiction", "Private_Public")
        metricChoice <- ifelse(input$boxplotMetric == "Total Cases", "Residents.Confirmed", "CasesPer1k")
        if("California" %in% input$state){
            # Look at California Prisons
            californiaCounts <- individual_adult_counts[which(individual_adult_counts$State == "California"),]
            californiaPrisons <- californiaCounts[which(californiaCounts$jurisdiction != "county"),]
            californiaPrisons <- californiaPrisons[which(californiaPrisons$Private_Public == "Public" | californiaPrisons$Private_Public == "Private"),]
            
            ggplot(californiaPrisons, aes(x=!! rlang::sym(variableChoice), y=!! rlang::sym(metricChoice))) + geom_boxplot(fill="lightblue") +
                labs(title=paste(input$boxplotMetric, "in California by", input$variable, sep=" "), x="Jurisdiction", y="# of Resident Cases")
        }
    })
    
    # Nationwide boxplot for federal vs state
    output$nationwidePlot <- renderPlot({
        metricChoice <- ifelse(input$boxplotMetric == "Total Cases", "Residents.Confirmed", "CasesPer1k")
        if("Nationwide" %in% input$state){
            # Look at Nationwide Prisons
            allPrisons <- individual_adult_counts[which(individual_adult_counts$jurisdiction != "county"),]
            # Only shows the jurisdiction comparison as we are missing all the private/public data
            ggplot(allPrisons, aes(x=jurisdiction, y=!! rlang::sym(metricChoice))) + geom_boxplot(fill="lightblue") +
                labs(title=paste(input$boxplotMetric, "Nationwide by Jurisdiction",  sep=" "), x="Jurisdiction", y="# of Resident Cases")
        }
    })
    
    # Graph all correctional facilities across U.S.
    output$facilityMapPlot <- renderPlot({
        MainStates <- read.csv("data/MainStates.csv")
        # Build map with specific region
        if(input$facilityMapregion == "West"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(west)),]
        } else if(input$facilityMapregion == "Southwest"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(southwest)),]
        } else if(input$facilityMapregion == "Midwest"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(midwest)),]
        } else if(input$facilityMapregion == "Northeast"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(northeast)),]
        } else if(input$facilityMapregion == "Southeast"){
            MainStates <- MainStates[which(MainStates$region %in% tolower(southeast)),]
        } 
        
        # Create a base map of the Mainland United States
        baseMap <- ggplot() + geom_polygon(data=MainStates, aes(x=long, y=lat, group=group), fill="lightblue", color="black", size=.1)
        baseMap
        
        # Filter for only Mainland facilities to make the map easier to read
        mainlandFacilities <- adult_counts %>% filter(!is.na(Longitude) & Longitude >= -130)
        if(input$facilityMapregion == "West"){
            mainlandFacilities <- mainlandFacilities[which(mainlandFacilities$State %in% west),]
        } else if(input$facilityMapregion == "Southwest"){
            mainlandFacilities <- mainlandFacilities[which(mainlandFacilities$State %in% southwest),]
        } else if(input$facilityMapregion == "Midwest"){
            mainlandFacilities <- mainlandFacilities[which(mainlandFacilities$State %in% midwest),]
        } else if(input$facilityMapregion == "Northeast"){
            mainlandFacilities <- mainlandFacilities[which(mainlandFacilities$State %in% northeast),]
        } else if(input$facilityMapregion == "Southeast"){
            mainlandFacilities <- mainlandFacilities[which(mainlandFacilities$State %in% southeast),]
        } 
        
        # Add the points for each facility with size as the number of Resident.Confirmed cases
        facilityDotMap <- baseMap + geom_point(data = mainlandFacilities, aes(x=Longitude, y=Latitude,
                                                                              size=!! rlang::sym(input$facilityMapSelect), 
                                                                              color=factor(jurisdiction)), alpha=0.5) +
            labs(title=paste(input$facilityMapSelect, "in Correctional Facilities across the U.S.", sep=" "), x= "", y="", color = "Jurisdiction") +
            theme_bw() +
            theme(axis.line = element_blank(),
                  axis.ticks = element_blank(),
                  axis.text.x = element_blank(),
                  axis.text.y = element_blank())
        facilityDotMap
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
