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

df <- read.csv("../data/mental-heath-in-tech.csv", stringsAsFactors = FALSE)

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("Mental Health Issue Tracker"),
  sidebarLayout(
    sidebarPanel(
      
    ),
    mainPanel(
      tabsetPanel(type="tabs",
                  tabPanel("Overview",wordcloud2Output("wordplot"), plotOutput("help"), plotOutput("scary")),
                  tabPanel("Details",
                           plotOutput("MHID"), 
                           plotOutput("diagnosis"),
                           fluidRow(
                             splitLayout(cellWidths = c("50%", "50%"), plotOutput("working_impact1"), plotOutput("working_impact2"))
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
  
  word_cloud <- main_conditions %>%
#    filter(Age > input$ageInput[1], Age < input$ageInput[2]) %>% 
#    filter(work_country %in% input$workCountries) %>% 
    count(Condition) %>% 
    setNames(c("word", "freq")) %>%
    mutate(freq = log(freq)) %>% 
    arrange(desc(freq))

  
  #output$wordplot <- renderWordcloud2(
  #  word_cloud %>%
  #  wordcloud2(size = 0.5, minRotation = 0, maxRotation = 0, shape = "circle"),
  
  output$help <- renderPlot(
    ggplot(df, aes(x = options_for_seeking_help)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "#99e8ff") +
#      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "",
           y = "Quantity") +
      theme_bw() +
      ggtitle("Awareness of options for seeking help") +
      theme(plot.title = element_text(hjust = 0.5))
  )
  
  output$scary <- renderPlot(
    ggplot(df, aes(x = scared_of_discussing_with_employer)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "#99e8ff") +
#      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "",
           y = "QTY") +
      theme_bw() +
      ggtitle("Fear of discussing mental health disorder w/ employer") +
      theme(plot.title = element_text(hjust = 0.5))
    )

# Details' charts  
  output$MHID <- renderPlot(
    ggplot(df, aes(x = MHD, fill = sought_treatment_by_professional)) +
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
    ggplot(df, aes(x = MHD, fill = diagnosed_by_practitioner)) +
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
    ggplot(df, aes(x = wrk_interference_when_treated)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "#51db98") +
      geom_text(stat = "count", aes(label = ..count..), vjust = -0.4, colour = "black") +
      labs(x = "",
           y = "Quantity") +
      theme_bw() +
      ggtitle("Working interference when treated") +
      theme(plot.title = element_text(hjust = 0.5))
    )
  
  output$working_impact2 <- renderPlot(
    ggplot(df, aes(x = wrk_interference_No_treatement)) +
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