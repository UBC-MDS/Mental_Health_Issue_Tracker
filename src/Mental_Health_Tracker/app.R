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



df <- read.csv("mental-heath-in-tech_working_copy.csv", stringsAsFactors = FALSE)
countries <- as.list(unique(df$work_country))

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("Mntal Health Issue Tracker"),
  sidebarLayout(
    sidebarPanel(
                 sliderInput("age", "Age",
                             min = 10, max = 100, value = c(15, 30)
                             ),
                 selectInput("countryInput", label = "Country",
                             choices = countries,
                             selected = 1)
                
    ),
    mainPanel(
      tabsetPanel(type="tabs",
                  tabPanel("Overview",wordcloud2Output("wordplot")),
                  tabPanel("Details",plotOutput("MHID"))
      )
              
    )
  )
)


# Define server logic required to draw a plot
server <- function(input, output) {
  
  main_conditions <- df %>% 
    select(Condition) %>% 
    mutate(Condition = as.character(Condition)) %>% 
    mutate(Condition = tolower(Condition)) %>%
    mutate(Condition = gsub("\\s*\\([^\\)]+\\)", "", Condition)) %>%
    mutate(Condition = gsub("\\s+-.*", "", Condition)) %>%
    mutate(Condition = strsplit(Condition, "|", fixed = TRUE)) %>%
    unnest(Condition) %>%
    count(Condition) %>% 
    setNames(c("word", "freq")) %>%
    mutate(freq = log(freq)) %>% 
    arrange(desc(freq))
  
  View(main_conditions)
  
  plot1_filtered  <-reactive(df %>%      
  filter(between(Age, input$age[1], input$age[2]),
         work_country==input$countryInput))
  
  #cloud <- reactive(main_conditions %>%
                      #filter(between(Age, input$age[1], input$age[2]),
                             #work_country==input$countryInput))
  
   output$wordplot <- renderWordcloud2(
    main_conditions %>%
    #cloud()%>%
    wordcloud2(size = 0.5, minRotation = 0, maxRotation = 0,color = "random-dark"))
  
   
   output$MHID <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = MHD, fill = sought_treatment_by_professional)) +
                              geom_bar(stat = "count") +
                              guides(fill = guide_legend(reverse = TRUE)) +
                              scale_fill_brewer(palette = "Pastel1") +
                              theme_bw()
    
  )
 # )
    
   
}

# Run the application 
shinyApp(ui = ui, server = server)

