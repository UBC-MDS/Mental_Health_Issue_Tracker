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

df <- read.csv("data/mental-heath-in-tech.csv", stringsAsFactors = FALSE)

countries <- as.list(unique(df$work_country))

# Define UI for application that draws a histogram
ui <- fluidPage(
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
                             splitLayout(cellWidths = c("50%", "50%"), plotOutput("help"),
                                         plotOutput("scary"))
                                           
                           )
                  ),
                           #wordcloud2Output("wordplot"), plotOutput("help"), plotOutput("scary")),
                  tabPanel("Details",
                           #plotOutput("MHID"), 
                           #plotOutput("diagnosis"),
                           fluidRow(
                             splitLayout(cellWidths = c("50%", "50%"), plotOutput("MHID"), 
                                         plotOutput("diagnosis"))
                           ),
                           fluidRow(
                           splitLayout(cellWidths = c("50%", "50%"), plotOutput("working_impact1"), 
                                       plotOutput("working_impact2"))
                           )
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
  
  
  plot1_filtered  <-reactive(df %>%      
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
    wordcloud2(size = 0.4, minRotation = 0, maxRotation = 0, 
               shape = "diamond",fontWeight = "Bold" ,fontFamily = "CMU Sans Serif",color="random-dark",widgetsize=52))
  
  output$help <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = options_for_seeking_help)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "#99e8ff") +
#      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "",
           y = "Quantity") +
      theme_bw() +
      ggtitle("Awareness of options for seeking help") +
      theme(plot.title = element_text(hjust = 0.5))
  )
  
  output$scary <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = scared_of_discussing_with_employer)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "#99e8ff") +
#      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "",
           y = "Quantity") +
      theme_bw() +
      ggtitle("Fear of discussing mental health disorder w/ employer") +
      theme(plot.title = element_text(hjust = 0.5))
    )

# Details' charts  
  output$MHID <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = MHD, fill = sought_treatment_by_professional)) +
      geom_bar(stat = "count") +
      guides(fill = guide_legend(reverse = TRUE)) +
      scale_fill_brewer(palette = "Pastel1") +
      labs(x = "History of mental health disorder",
           y = "Quantity") +
      theme_bw() +
      ggtitle("Number of people who sought professional help for mental health") +
      theme(plot.title = element_text(hjust = 0.5))
    )
  
  output$diagnosis <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = MHD, fill = diagnosed_by_practitioner)) +
      geom_bar(stat = "count") +
      guides(fill = guide_legend(reverse = TRUE)) +
      scale_fill_brewer(palette = "Pastel1") +
      labs(x = "History of mental health disorder",
           y = "Quantity") +
      theme_bw() +
      ggtitle("Number of people who were professionaly diagnosed with a mental health disorder") +
      theme(plot.title = element_text(hjust = 0.5))
    )
  
  output$working_impact1 <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = wrk_interference_when_treated)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "#51db98") +
      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "",
           y = "Quantity") +
      theme_bw() +
      ggtitle("Working interference when treated") +
      theme(plot.title = element_text(hjust = 0.5))
    )
  
  output$working_impact2 <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = wrk_interference_No_treatement)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "#ffd48c") +
      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "",
           y = "Quantity") +
      theme_bw() +
      ggtitle("Working interference when not treated") +
      theme(plot.title = element_text(hjust = 0.5))
     ) 

  
}

# Run the application
shinyApp(ui = ui, server = server)