#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(wordcloud2)
library(tidytext)
library(plotly)
library(gridExtra)
library(shinythemes)

df <- read.csv("data/mental-heath-in-tech.csv", stringsAsFactors = FALSE)

countries <- as.list(unique(df$work_country))

# Define UI for application that draws a histogram
ui <- fluidPage(theme=shinytheme("lumen"),
  titlePanel("Mental Health Issue Tracker"),
  sidebarLayout(
    sidebarPanel(width = 3,
      sliderInput("age", "Age",
                  min = 10, max = 100, value = c(15, 30)
      ),
      selectInput("countryInput", label = "Country",
                  choices = countries,
                  selected = 1)
      
    ),
    mainPanel(width = 8,
      tabsetPanel(type="tabs",
                  tabPanel("Overview",
                           wordcloud2Output("wordplot", width = "106%", height = "390px"),
                           fluidRow(
                             splitLayout(cellWidths = c("50%", "50%"),
                                         plotOutput("help",width = "100%",height = "360px"),
                                         plotOutput("scary",width = "100%",height = "360px")
                                         )
                                           
                           )
                  ),
                           
                  tabPanel("Details",
                           fluidRow(
                             splitLayout(cellWidths = c("50%", "50%"), 
                                         plotOutput("MHID",width = "100%",height = "360px"), 
                                         plotOutput("diagnosis",width = "100%",height = "360px"))
                           ),
                           fluidRow(
                           splitLayout(cellWidths = c("50%", "50%"), 
                                       plotOutput("working_impact1",width = "75%",height = "375px"), 
                                       plotOutput("working_impact2",width = "75%",height = "375px"))
                           )
                  ),
                  tabPanel("Data",
                           tableOutput("table")
                             
                           
                  )
      )
      
    )
  )
)


# Define server logic required to draw a plot
server <- function(input, output) {

# Overview's charts 
  main_conditions <- df %>% 
    select(Condition, Age, work_country) %>% 
    mutate(Condition = as.character(Condition)) %>% 
    mutate(Condition = tolower(Condition)) %>%
    mutate(Condition = gsub("\\s*\\([^\\)]+\\)", "", Condition)) %>%
    mutate(Condition = gsub("\\s+-.*", "", Condition)) %>%
    mutate(Condition = strsplit(Condition, "|", fixed = TRUE)) %>%
    unnest(Condition)
  
  data<-df %>%
    select(Condition, Age, work_country,options_for_seeking_help,
           scared_of_discussing_with_employer,Treatment_sought,
           Clinically_diagnosed,wrk_interference_when_treated,wrk_interference_No_treatement,MHD)
  
  
  plot1_filtered  <-reactive(data %>%      
                            filter(between(Age, input$age[1], input$age[2]),
                                   work_country==input$countryInput))
  
  
  word_cloud <- main_conditions %>%
#    filter(Age > input$ageInput[1], Age < input$ageInput[2]) %>% 
#    filter(work_country %in% input$workCountries) %>% 
    count(Condition) %>% 
    setNames(c("word", "freq")) %>%
    mutate(freq = log(freq)) %>% 
    arrange(desc(freq))

  
  output$wordplot <- renderWordcloud2(
    word_cloud %>%
    wordcloud2(size = 0.32, minRotation = 0, maxRotation = 0, 
               shape = "diamond",fontWeight = "normal" ,fontFamily = "CMU Sans Serif",color="random-dark"))
  
  output$help <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = options_for_seeking_help)) +
#     geom_bar(stat = "count", position = position_dodge(), fill = "#99e8ff") +
      geom_bar(stat = "count", position = position_dodge(), fill = "skyblue4") +         #chganed the color
#      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "Suervey respose",
           y = "Count") +
      theme_bw()+
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +      #Removed grid
      ggtitle("Awareness of options for seeking help") +
      theme(plot.title = element_text(hjust = 0.5))
  )
  

  
  output$scary <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = scared_of_discussing_with_employer)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "skyblue4") +       #changed color
#      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "Survey response",
           y = "Count") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+     #Removed grid
      ggtitle("Fear of discussing mental health disorder with employer") +
      theme(plot.title = element_text(hjust = 0.5))
    )

# Details' charts  
  output$MHID <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = MHD, fill = Treatment_sought)) +
      geom_bar(stat = "count") +
      guides(fill = guide_legend(reverse = TRUE)) +
 #   scale_fill_brewer(palette = "Pastel1") +
      scale_fill_manual(values = alpha(c("lightblue","steelblue4")))+
      labs(x = "History of mental health disorder",
           y = "Count") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+     #Removed grid
      ggtitle("Sought professional help for mental health") +
      theme(plot.title = element_text(hjust = 0.5))
    )
  
  output$diagnosis <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = MHD, fill = Clinically_diagnosed)) +
      geom_bar(stat = "count") +
      guides(fill = guide_legend(reverse = TRUE)) +
  #   scale_fill_brewer(palette = "Pastel1") +
      scale_fill_manual(values = alpha(c("lightblue","steelblue4")))+
      labs(x = "History of mental health disorder",
           y = "Count") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+     #Removed grid
      ggtitle("Clinically diagnosed with a mental health disorder") +
      theme(plot.title = element_text(hjust = 0.5))
    )
  
  output$working_impact1 <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = wrk_interference_when_treated)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "lightsteelblue3") +
      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "Effect in work",
           y = "Count") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
      ggtitle("Working interference when treated") +
      theme(plot.title = element_text(hjust = 0.5))
    )
  
  output$working_impact2 <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = wrk_interference_No_treatement)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "lightsteelblue3") +
      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "Effect in work",
           y = "Count") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
      ggtitle("Working interference when not treated") +
      theme(plot.title = element_text(hjust = 0.5))
     ) 
  
  output$table <- renderTable(plot1_filtered() #Data
                              
  )

  
}

# Run the application
shinyApp(ui = ui, server = server)