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
library(DT)
library(shinyjs)
library(shinycssloaders)

df <- read.csv("data/mental-heath-in-tech.csv", stringsAsFactors = FALSE)

# Extract country list choices and order them alphabetically
countries <- as.list(unique(arrange(df, Country)$Country))

# Extract gender list choices and order them alphabetically
gender <- as.list(unique(arrange(df, Gender)$Gender))

# Define UI for application
ui <- fluidPage(
  useShinyjs(),
  theme = shinytheme("lumen"),
  titlePanel("Tech Mental Health Issue Tracker"),
  sidebarLayout(
    sidebarPanel(width = 3,
                 tags$head(tags$style("#textOutput{color: red;
                                      font-size: 20px;
                                      font-style: italic;
                                      }"
                     )
                 ),
                 sliderInput("age", "Age",
                             min = 10, max = 100, value = c(20, 45)),
                 
                 selectInput("countryInput", label = "Country",
                             choices = c('All', countries),
                             selected = 'All'),
                 
                 selectInput("genderInput", label = "Gender",
                             choices = c('All', gender),
                             selected = 'All')
                 ),
    
    mainPanel(width = 8,
              tabsetPanel(type="tabs",id="tab",
                          tabPanel("Usage",
                                   align="left",
                                   tags$hr(),
                                   
                                   h3("Motivation", 
                                      style ="font-weight:bold; color:grey"),
                                   p('This app is built for tech employers to understand how much the employees are aware of benefits given to them for mental health issue. This gives the visualisation of survey data which helps employer to decide what should be the enhancement in benefits , awareness methods and changes in company policies in regards of mental health issues.'),tags$hr(),
                                   h3("Overview", 
                                      style ="font-weight:bold; color:grey"),
                                   p('This tab shows the most prevalent mental helath conditions diagnosed among employers. Also it shows how many employers are aware of mental health benefits provided by the company. This can be filtered with respect to Age and Country.'),tags$hr(),
                                   h3("Analysis", 
                                      style ="font-weight:bold; color:grey"),
                                   p('This tab shows mental history and current state of health with respect to treatment sught from professional and how many employees are diagnosed by prefoessionals.This tab enables employers to notice how much the health issue is affecting their performance when treated compared to when they do not receive any treatment.All information could be filetered by Age and Country of their work.'),tags$hr(),                            
                                   h3("Data", 
                                      style ="font-weight:bold; color:grey"),
                                   p('Overview of the raw data with respect to the filter applied.'),tags$hr()
                                   
                          ),
                          
                          tabPanel("Overview",align="center",h3("The most prevalent conditions diagnosed were...", 
                                                                style ="font-weight:bold; color:grey"),
                                   withSpinner(wordcloud2Output("wordplot", width = "80%", height = "300px")),
                                   tags$hr(),
                                   fluidRow(
                                     splitLayout(
                                       withSpinner(plotOutput("help", width = "70%", height = "360px"))
                                       
                                     )
                                     
                                   )
                          ),
                          
                          tabPanel("Analysis",
                                   fluidRow(
                                     splitLayout(cellWidths = c("50%", "50%"), 
                                                 withSpinner(plotOutput("MHID", width = "auto", height = "360px")), 
                                                 withSpinner(plotOutput("diagnosis", width = "auto", height = "360px")))
                                   ),
                                   tags$hr(),
                                   fluidRow(
                                     splitLayout(cellWidths = c("50%", "50%"), 
                                                 withSpinner(plotOutput("working_impact1", width = "75%", height = "375px")), 
                                                 withSpinner(plotOutput("working_impact2", width = "75%", height = "375px")))
                                   )
                          ),
                          tabPanel("Data",
                                   withSpinner(DT::dataTableOutput("mytable"))
                          )
              )
              
    )
    )
  )


# Define server logic required to draw a plot
server <- function(input, output) {
  
  # Wrangle the data to be used to plot a worcloud 
  main_conditions <- df %>% 
    select(Condition, Age, Country, Gender) %>% 
    mutate(Condition = as.character(Condition)) %>% 
    mutate(Condition = tolower(Condition)) %>%
    # Regular expressions below used to extract individual conditions from survey responses
    mutate(Condition = gsub("\\s*\\([^\\)]+\\)", "", Condition)) %>%
    mutate(Condition = gsub("\\s+-.*", "", Condition)) %>%
    mutate(Condition = strsplit(Condition, "|", fixed = TRUE)) %>%
    unnest(Condition)
  
  data <- df %>%
    select(Condition, Age, Country,options_for_seeking_help,
           Treatment_sought,Gender, Clinically_diagnosed,
           wrk_interference_when_treated, wrk_interference_No_treatement, MHD)
  
  # Get the reactive for the data after filtering
  plot1_filtered <- reactive(data %>%      
                               filter(between(Age, input$age[1], input$age[2]),
                                      input$countryInput == 'All' | Country == input$countryInput,
                                      input$genderInput == 'All' | Gender==input$genderInput))
  
  
  word_cloud <- reactive(main_conditions %>% 
                           filter(between(Age, input$age[1], input$age[2]), input$countryInput == 'All' | Country == input$countryInput,input$genderInput == 'All' | Gender==input$genderInput) %>% 
                           count(Condition) %>%
                           setNames(c("word", "freq")) %>%
                           mutate(freq = log(freq + 1)) %>% 
                           arrange(desc(freq))
  )
  
  # Render overview tab plots
  output$wordplot <- renderWordcloud2(
    word_cloud() %>%
      wordcloud2(size = 0.32, minRotation = 0, maxRotation = 0, 
                 shape = "circle", fontWeight = "normal", fontFamily = "CMU Sans Serif", color="random-dark"))
  
  output$help <- renderPlot(
    plot1_filtered()%>%
      ggplot(aes(x = options_for_seeking_help)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "skyblue4") +
      geom_text(stat = "count", aes(label = ..count..), position = position_stack(0.5), colour = "black") +
      labs(x="",
           y = "Count") +
      theme_bw()+
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
      ggtitle("Awareness of options for seeking help") +
      theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
      theme(axis.text = element_text(size = 14),
            axis.title = element_text(size = 14,face="bold")) + 
      theme(legend.text=element_text(size = 12))
  )
  
  # Render analysis tab plots
  output$MHID <- renderPlot(
    plot1_filtered()%>%
      ggplot(aes(x = MHD, fill = Treatment_sought)) +
      geom_bar(stat = "count") +
      geom_text(stat = "count", aes(label = ..count..), position = position_stack(0.5) , colour = "black") +
      guides(fill = guide_legend(reverse = TRUE)) +
      scale_fill_manual(values = alpha(c("lightblue","steelblue4")))+
      labs(x="",
           y = "Count",
           fill = "Sought Help") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+     #Removed grid
      ggtitle("Sought professional help for mental health") +
      theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
      theme(axis.text.x = element_text(size = 11.5, angle = 0, vjust = 1),
            axis.text.y = element_text(size = 14),
            axis.title = element_text(size = 14,face = "bold")) + 
      theme(legend.text = element_text(size = 12)) 
  )
  
  output$diagnosis <- renderPlot(
    plot1_filtered()%>%
      ggplot(aes(x = MHD, fill = Clinically_diagnosed)) +
      geom_bar(stat = "count") +
      geom_text(stat = "count", aes(label = ..count..), position = position_stack(0.5), colour = "black") +
      guides(fill = guide_legend(reverse = TRUE)) +
      scale_fill_manual(values = alpha(c("lightblue","steelblue4")))+
      labs(x="",
           y = "Count",
           fill = "Clinically Diagnosed") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+     #Removed grid
      ggtitle("Clinically diagnosed with a mental health disorder") +
      theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
      theme(axis.text.x = element_text(size = 11.5, angle = 0, vjust = 1),
            axis.text.y = element_text(size = 14),
            axis.title = element_text(size = 14,face="bold")) + 
      theme(legend.text = element_text(size = 12))
  )
  
  output$working_impact1 <- renderPlot(
    plot1_filtered()%>%
      ggplot(aes(x = wrk_interference_when_treated)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "lightsteelblue3") +
      geom_text(stat = "count", aes(label = ..count..), position = position_stack(0.5), colour = "black") +
      labs(x="",
           y = "Count") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
      ggtitle("Working interference when treated") +
      theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
      theme(axis.text.x = element_text(size = 11.5, angle = 0, vjust = 1),
            axis.text.y = element_text(size = 14),
            axis.title = element_text(size = 14,face = "bold")) + 
      theme(legend.text = element_text(size = 12))
  )
  
  output$working_impact2 <- renderPlot(
    plot1_filtered()%>%
      ggplot(aes(x = wrk_interference_No_treatement)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "lightsteelblue3") +
      geom_text(stat = "count", aes(label = ..count..), position = position_stack(0.5), colour = "black") +
      labs(x="",
           y = "Count") +
      ggtitle("Working interference when not treated") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
      theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
      theme(axis.text.x = element_text(size = 11.5, angle = 0, vjust = 1),
            axis.text.y = element_text(size = 14),
            axis.title = element_text(size = 14,face ="bold")) + 
      theme(legend.text = element_text(size = 12))
  ) 
  
  
  # Render data table
  output$mytable = DT::renderDataTable({
    datatable(plot1_filtered(), colnames = c("Awareness of Options for Seeking Help" = "options_for_seeking_help",
                                             "Sought Help" = "Treatment_sought",
                                             "Clinically Diagnosed" = "Clinically_diagnosed",
                                             "Working Interference When Treated" = "wrk_interference_when_treated",
                                             "Working Interference When Not Treated" = "wrk_interference_No_treatement",
                                             "History of Mental Health Disorder" = "MHD"))
    })
  
  observe(toggle(id = "age", condition = ifelse(input$tab == 'Usage', FALSE, TRUE)))
  observe(toggle(id = "countryInput", condition = ifelse(input$tab == 'Usage', FALSE, TRUE)))
  observe(toggle(id = "genderInput", condition = ifelse(input$tab == 'Usage', FALSE, TRUE)))
}

# Run the application
shinyApp(ui = ui, server = server)