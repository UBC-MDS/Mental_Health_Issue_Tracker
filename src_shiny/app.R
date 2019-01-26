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

df <- read.csv("data/mental-heath-in-tech.csv", stringsAsFactors = FALSE)

countries <- as.list(unique(arrange(df, work_country)$work_country))


# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("lumen"),
  titlePanel("Mental Health Issue Tracker"),
  sidebarLayout(
    sidebarPanel(width = 3,
                tags$head(tags$style("#textOutput{color: red;
                             font-size: 20px;
                                      font-style: italic;
                                      }"
                     )
                 ),
      sliderInput("age", "Age",
                  min = 10, max = 100, value = c(20, 35)
      ),
      selectInput("countryInput", label = "Country",
                  choices = c('All', countries),
                  selected = 'All')
      
    ),
    mainPanel(width = 8,
      tabsetPanel(type="tabs",
                  tabPanel("Usage",align="left",tags$hr(),
                           h3("Motivation", 
                           style ="font-weight:bold; color:grey"),
                           p('This app is built for tech employers to understand how much the employees are aware of benefits given to them for mental health issues. It enables the visualization of survey data which helps the employer make decision about what enhancements should be made to benefits provided, awareness methods and changes in company policies in regards to mental health issues.'),tags$hr(),
                           h3("Overview", 
                              style ="font-weight:bold; color:grey"),
                           p('This tab shows the most prevalent mental health conditions diagnosed among employees. Also it shows how many employees are aware of mental health benefits provided by the company. This can be filtered with respect to Age and Country.'),tags$hr(),
                           h3("Analysis", 
                              style ="font-weight:bold; color:grey"),
                           p('This tab shows mental history and current state of health with respect to treatment sought from professionals and how many employees are diagnosed by professionals. This tab also enables employers to notice how much health issues are affecting their employees\' performance when treated, compared to when they do not receive any treatment. All information can be filtered by Age and Country of work.'),tags$hr(),                            
                          h3("Data", 
                              style ="font-weight:bold; color:grey"),
                           p('Overview of the raw data with respect to the filters applied.'),tags$hr()
                           
                  ),
                  tabPanel("Overview",align="center",h3("The most prevalent conditions diagnosed were...", 
                                                        style ="font-weight:bold; color:grey"),
                           wordcloud2Output("wordcloud", width = "80%", height = "300px"),
                           tags$hr(),
                           fluidRow(
                             splitLayout(#cellWidths = c("50%", "50%"),
                                         #plotOutput("scary",width = "100%",height = "360px"),
                                         plotOutput("help",width = "70%",height = "360px")
                                         
                                         )
                                           
                           )
                  ),
                           
                  tabPanel("Analysis",
                           fluidRow(
                             splitLayout(cellWidths = c("50%", "50%"), 
                                         plotOutput("MHID",width = "100%",height = "360px"), 
                                         plotOutput("diagnosis",width = "100%",height = "360px"))
                           ),
                           tags$hr(),
                           fluidRow(
                           splitLayout(cellWidths = c("50%", "50%"), 
                                       plotOutput("working_impact1",width = "75%",height = "375px"), 
                                       plotOutput("working_impact2",width = "75%",height = "375px"))
                           )
                  ),
                  tabPanel("Data",
                           #tableOutput("table")
                           DT::dataTableOutput("mytable")
                             
                           
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
                                   input$countryInput == 'All' | work_country==input$countryInput))
  

  word_cloud <- reactive(main_conditions %>% 
    filter(between(Age, input$age[1], input$age[2]), input$countryInput == 'All' | work_country==input$countryInput) %>% 
    count(Condition) %>%
    setNames(c("word", "freq")) %>%
    mutate(freq = log(freq + 1)) %>% 
    arrange(desc(freq))
  )
  
  output$wordcloud <- renderWordcloud2(
    word_cloud() %>%
    wordcloud2(size = 0.32, minRotation = 0, maxRotation = 0, 
               shape = "circle", fontWeight = "normal", fontFamily = "CMU Sans Serif", color="random-dark"))
  
  output$help <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = options_for_seeking_help)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "lightsteelblue3") +
      geom_text(stat = "count", aes(label = ..count..), position = position_stack(0.5), colour = "black") +
      labs(x = "", y = "Count") +
      theme_bw()+
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
      ggtitle("Awareness of options for seeking help") +
      theme(plot.title = element_text(size = 17, face = "bold", hjust = 0.5)) +
      theme(axis.text = element_text(size = 13),
            axis.title = element_text(size = 15)) + 
      theme(legend.text=element_text(size = 12))
  )

# Details' charts  
  output$MHID <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = MHD, fill = Treatment_sought)) +
      geom_bar(stat = "count") +
      geom_text(stat = "count", aes(label = ..count..), position = position_stack(0.5) , colour = "black") +
      guides(fill = guide_legend(reverse = TRUE)) +
      scale_fill_manual(values = alpha(c("lightblue","steelblue4")))+
      labs(x = "(History of mental health disorder)",
           y = "Count",
           fill = "Sought Help") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+     
      ggtitle("Sought professional help for mental health") +
      theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5)) +
      theme(axis.text.x = element_text(size = 13, angle = 30, margin = margin(20, 0, -20, 0)),
            axis.text.y = element_text(size = 13),
            axis.title = element_text(size = 14)) + 
      theme(legend.text = element_text(size = 12)) 
    )
  
  output$diagnosis <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = MHD, fill = Clinically_diagnosed)) +
      geom_bar(stat = "count") +
      geom_text(stat = "count", aes(label = ..count..), position = position_stack(0.5), colour = "black") +
      guides(fill = guide_legend(reverse = TRUE)) +
      scale_fill_manual(values = alpha(c("lightblue","steelblue4")))+
      labs(x = "(History of mental health disorder)",
           y = "Count",
           fill = "Clinically Diagnosed") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+     #Removed grid
      ggtitle("Clinically diagnosed with a mental health disorder") +
      theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5)) +
      theme(axis.text.x = element_text(size = 13, angle = 30, margin = margin(20, 0, -20, 0)),
            axis.text.y = element_text(size = 13),
            axis.title = element_text(size = 14)) + 
      theme(legend.text = element_text(size = 12))
    )
  
  output$working_impact1 <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = wrk_interference_when_treated)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "lightsteelblue3") +
      geom_text(stat = "count", aes(label = ..count..), position = position_stack(0.5), colour = "black") +
      labs(x = "",
           y = "Count") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
      ggtitle("Working interference when treated") +
      theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5)) +
      theme(axis.text.x = element_text(size = 13, angle = 45, margin = margin(20, 0, -20, 0)),
            axis.text.y = element_text(size = 13),
            axis.title = element_text(size = 14))
    )
  
  output$working_impact2 <- renderPlot(
    plot1_filtered()%>%
    ggplot(aes(x = wrk_interference_No_treatement)) +
      geom_bar(stat = "count", position = position_dodge(), fill = "lightsteelblue3") +
      geom_text(stat = "count", aes(label = ..count..), position = position_stack(0.5), colour = "black") +
      labs(x = "",
           y = "Count") +
      ggtitle("Working interference when not treated") +
      theme_bw() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
      theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5)) +
      theme(axis.text.x = element_text(size = 13, angle = 45, margin = margin(20, 0, -20, 0)),
            axis.text.y = element_text(size = 13),
            axis.title = element_text(size = 14))
     ) 
  
  output$table <- renderTable(plot1_filtered() #Data
                                )
  output$mytable = DT::renderDataTable({
    plot1_filtered()
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)