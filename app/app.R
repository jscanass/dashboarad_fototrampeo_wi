# Written by J. Ahumada 2020 (c) Conservation International
# Shared under Creative Commons License CC0

library(shiny)
library(shinydashboard)
library(slickR)
library(dashboardthemes)
#library(iNEXT)
library(shinymanager)

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
            column(1, align = "left", tags$img(height = 952*0.1, src = "Logo_Humboldt_negro.png")),
            column(8, align = "center", tags$br(), tags$br(), tags$h1(textOutput("project_name"))),
            column(1, align = "center", tags$img(width = 1734*0.08, height = 1099*0.08, src = "logo REDCOL FOTOTRAMPEO negro.png")),
            column(2, align = "right", tags$img(width = 1970*0.08, height = 1046*0.08, src = "LOGO DIAS DE CAMARATRAMPA negro.png"))
            
        )
    ),
    box(width = 3, height = "80px",
        selectInput("project", "Seleccione un proyecto:", choices = unique(tableSites$project_short_name))
        ),
    box(width = 5, height = "80px",
        tags$b("Datos colectados por:"), tags$br(), tags$br(), tags$h4(textOutput("collector"))
        ),
    box(width = 4, height = "80px",
        tags$b("Fechas:"), tags$br(), tags$br(), tags$h4(textOutput("dateRange"))
        ),
    box(width = 3, height = "420px",
        plotOutput("InfoBoxes")
        ),
    box(width = 5, height = "460px",
        plotOutput("numberofImagesperSpecies"), title = "Número de imágenes por especie"
        ),
    box(width = 4, height = "460px",
        plotOutput("deployments"), title = "Instalaciones - eficiencia"
        ),
    box(width = 3,  height = "420px",
        plotOutput("speciesRichness"), title = "Riqueza de especies"
        ),
    box(width = 5, height = "420px", align = "center", title = "Imágenes favoritas", tags$br(), tags$br(),
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

    
    #output$speciesRichness <- renderPlot({
    #    makeSpeciesPanel(subTableData())
    #})
    
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
        path_to_images <- paste0("www/favorites/", subTableData()$project_short_name, "/")
        imgs <- list.files(path_to_images, full.names = TRUE)
        slickR(imgs) + settings(autoplay = FALSE, adaptiveHeight = TRUE,pauseOnHover = TRUE)
    })
    
    output$map <- renderLeaflet({
        makeMapLeaflet(tableSites, subTableData(), nsites, bounds)
    })
    
    output$collector <- renderText({
        paste0(subTableData()$collector)
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
