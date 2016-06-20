
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Precision vs Sensitivity"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      box(sliderInput("cutoff","Cut off:",
                      min = 0,max = 100,value = 50)),
      box(
        h1(textOutput("correctcount")))
    ),
    box(plotOutput("barchart")),
    box(h1(textOutput("falseNegatives")),
           h1(textOutput("falsePositives"))),
    
    box(plotOutput("confusionPlot"))
  )
)