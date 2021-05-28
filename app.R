# load dependencies
library(readr)
library(dplyr)
library(DT)
library(shiny)
library(Cairo)
library(ggplot2)
library(RColorBrewer)
options(shiny.usecairo = TRUE)

# source external scripts
source('build_functions.R', local = TRUE)
source('build_theme.R', local = TRUE)

# define UI
ui <- fluidPage(
  tags$head(tags$style(HTML('* {font-family: "Roboto"};')),
            HTML("<title>Pitcher Summary Report</title>")),
  br(),
  fluidRow(
    column(3),
    column(9, style = "border-left: 1px solid #1D3F5F;",
           titlePanel(h1(textOutput('pidText'), align = "center", style = "color: #1D3F5F;")))),
  fluidRow(
    column(3,
      selectInput("pitcherid",
                  label = h4("Pitcher ID", style = "color: #1D3F5F;"),
                  choices = as.list(sort(unique(pitch_data$PITCHER_ID)))),
      helpText("You can search for a pitcher by selecting the dropdown, pressing backspace, then typing"),
      br(),
      radioButtons("bhand",
                   label = h4("vs. Batter Handedness", style = "color: #1D3F5F;"),
                   choices = c("Both", "Left", "Right"),
                   selected = "Both",
                   inline = TRUE),
      br(),
      radioButtons("kzoneplot",
                   label = h4("Strike Zone Plot", style = "color: #1D3F5F;"),
                   choices = c("All Pitches", "By Pitch Type"),
                   selected = "All Pitches",
                   inline = TRUE),
      br(),
      sliderInput("gameids",
                  label = h4("Game ID Range", style = "color: #1D3F5F;"),
                  min = min(pitch_data$GAME_ID), 
                  max = max(pitch_data$GAME_ID),
                  value = c(1, 416))),
    column(9, style = "border-left: 1px solid #1D3F5F;",
      fluidRow(
        column(6, plotOutput("veloPlot")),
        column(6, plotOutput("relPlot"))),
      br(),
      fluidRow(
        column(6, plotOutput("usgPlot")),
        column(6, plotOutput("kzonePlot"))),
      br(),
      fluidRow(
        column(12, dataTableOutput("summaryData")))
    )
  )
)
          
          
server <- function(input, output, session) {
  
  # update slider range to match games for pitcher id
  observe({
    minGame <- pitch_data %>% 
      filter(PITCHER_ID == input$pitcherid) %>% 
      select(GAME_ID) %>% 
      min()
    maxGame <- pitch_data %>% 
      filter(PITCHER_ID == input$pitcherid) %>% 
      select(GAME_ID) %>% 
      max()
    nGames <- pitch_data %>% 
      filter(PITCHER_ID == input$pitcherid) %>% 
      select(GAME_ID) %>% 
      unique() %>% 
      nrow()
    updateSliderInput(session, "gameids",
                      min = minGame,
                      max = maxGame,
                      value = c(minGame, maxGame))
  })
  
  
  # update dataset based on ID, slider range, batter hand
  pitcherData <- reactive({
    if(input$bhand == "Both") {
      pitch_data %>% 
        filter(PITCHER_ID == input$pitcherid) %>% 
        filter(between(GAME_ID, input$gameids[1], input$gameids[2]))
    } else { pitch_data %>%
        filter(PITCHER_ID == input$pitcherid) %>% 
        filter(between(GAME_ID, input$gameids[1], input$gameids[2])) %>%
        filter(BATTER_SIDE == substring(input$bhand, 1, 1))}
    })
  
  # update text in page title
  output$pidText <- renderText(sprintf("Pitcher ID %s - Summary Report", input$pitcherid))
  
  # create plots using functions sourced from script
  output$veloPlot <- renderPlot({velo_plot(pitcherData())})
  output$usgPlot <- renderPlot({usg_plot(pitcherData())})
  output$relPlot <- renderPlot({rel_plot(pitcherData())})
  output$kzonePlot <- renderPlot({
    if (input$kzoneplot == "All Pitches") {
      kzone_plot_all(pitcherData())
    } else {kzone_plot_pt(pitcherData())}
    })
  
  # create summary data table
  output$summaryData <- renderDataTable(
    (data_summary(pitcherData())),
    extension = "FixedColumns",
    options = list(dom = 't',
                   scrollX = TRUE,
                   fixedColumns = list(leftColumns = 1)),
    rownames = FALSE)
}

shinyApp(ui = ui, server = server)