# Written by J. Ahumada 2020 (c) Conservation International
# Shared under Creative Commons License CC0

library(shiny)
library(shinydashboard)
library(slickR)
library(dashboardthemes)
source("functions_data.R")

dir.create('~/.fonts')
file.copy("www/ProximaNova-Reg.ttf", "~/.fonts")
file.copy("www/ProximaNova-Bold.ttf", "~/.fonts")
system('fc-cache -f ~/.fonts')

#Load data
tableSites <- read.csv("sites.csv")
iavhdata <- read.csv("data.csv")
# tableDeployments <- readRDS("deploymentTable.rds")

# Define UI for application 
body <- dashboardBody(tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$style(HTML("body{ overflow-x: hidden !important; padding: 0px 10px !important;}")),
),
    box(width = 12,
        fluidRow(
            column(2, align = "left", tags$img(height = 75*1.3, src = "humboldtLogo.png")),
            column(7, align = "center", tags$br(), tags$br(), tags$h1(textOutput("project_name"))),
            column(3, align = "right", tags$img(width = 220*0.8, height = 110*0.8, src = "logoFT.png"))
            
        )
    ),
    box(width = 3, height = "80px",
        selectInput("project", "Seleccione un proyecto:",  choices = unique(tableSites$project_short_name))
        ),
    box(width = 5, height = "80px",
        tags$b("Datos colectados por:"), tags$br(), tags$br(), tags$h4(textOutput("collector"))
        ),
    box(width = 4, height = "80px",
        tags$b("Fechas:"), tags$br(), tags$br(), tags$h4(textOutput("dateRange"))
        ),
    box(width = 3, 
        plotOutput("speciesRichness"), title = "Riqueza de especies"
        ),
    box(width = 5, 
        plotOutput("numberofImagesperSpecies"), title = "Número de imágenes por especie"
        ),
    box(width = 4, 
        plotOutput("deployments"), title = "Instalaciones - eficiencia"
        ),
    box(width = 3, height = "420px", 
        plotOutput("InfoBoxes")
        ),
    box(width = 5, height = "420px", align = "center", tags$br(), tags$br(), tags$br(), tags$br(),
        slickROutput("cameraTrapImages", height = "420px")
        ),
    box(width = 4, height = "420px", align = "center", 
        leafletOutput("map")
        ),
    fluidRow(
        column(12, align = "right", tags$img(src = "Powered by WI.png", height = 50))
        )
)


# Define server logic
server <- function(input, output) {
    
    nsites <- nrow(tableSites) - 1
    #ndeployments <- nrow(tableDeployments)

    bounds <- data.frame(lat = c(1.683247, 12.665921, 1.248316, -4.322823), lon = c(-79.137686, -71.675299, -66.744664, -69.937127))
    
    # filter data by project

    subRawData <- reactive({
        if(input$project == "Días de cámara trampa - Datos 2023")
        iavhdata
        else
            iavhdata %>% filter(project_short_name == input$project)
    })
    
    subTableData <- reactive({
        tableSites %>% filter(project_short_name == input$project)
    })

    
    output$speciesRichness <- renderPlot({
        makeSpeciesPanel(subTableData())
    })
    
    output$numberofImagesperSpecies <- renderPlot({
        makeSpeciesGraph(subRawData())
    })
    
    output$deployments <- renderPlot ({
        makeDeploymentGuideGraph(subRawData())
    })
    
    output$cameraTrapImages <- renderSlickR({
        imgs <- list.files("www/images/Cajambre 2014/", pattern=".JPG", full.names = TRUE)
        slickR(imgs) + settings(autoplay = TRUE,adaptiveHeight = TRUE,pauseOnHover = TRUE)
    })
    
    output$map <- renderLeaflet({
        makeMapLeaflet(tableSites, subTableData(), nsites, bounds)
    })
    
    output$collector <- renderText({
        paste0(subTableData()$collector,", ",subTableData()$organization_name)
    })
    
    output$dateRange <- renderText({
        paste0(subTableData()$start_date, " - ", subTableData()$end_date)
    })
    
    output$project_name <- renderText({
        paste0("\nProyecto: ", input$project, ", ", subTableData()$departamento)
    })
    
    output$InfoBoxes <- renderPlot({
        makeInfoPanel(subTableData())
    })
        
}

# Run the application 
shinyApp(ui = dashboardPage(dashboardHeader(disable = T),
                            dashboardSidebar(disable = T),
                            body), 
        server = server)
