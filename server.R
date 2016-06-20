
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(gplots)
library(ggplot2)

shinyServer(function(input, output) {
  myIdentity <- diag(2)
  dimnames(myIdentity) <- list( c("", ""), c("", ""))
  myData <- data.frame(Name = paste("Person", LETTERS[1:10]),
                       Predicted = c(80, 78, 69, 65, 59, 51, 49, 45, 40, 20),
                       Actual = c("Leave","Leave","Leave","Stay","Leave","Stay","Stay","Leave","Stay","Stay"),
                       stringsAsFactors = FALSE)
  myData$Actual_ <- myData$Actual =="Leave"
  
  formatVector <- function(x){
    paste(seq_along(x), ". ", x, sep = "", collapse = "\n")
  }
  
  predictions <- reactive(myData$Predicted >= input$cutoff)


  output$confusionPlot <- renderPlot({
    currPredictions <- predictions()
    
    # calculate confusion matrix-ish
    countCorrectYes <- myData$Name[currPredictions==myData$Actual_ & currPredictions]
    countCorrectNo <- myData$Name[currPredictions==myData$Actual_ & !currPredictions]
    falsePositives <- myData$Name[currPredictions & !myData$Actual_]
    falseNegatives <- myData$Name[!currPredictions & myData$Actual_]
    
    cellnote <- rbind(c(paste0("PREDICT LEAVE \nBUT STAYED \n", formatVector(falsePositives)),
                   paste0("PREDICT LEAVE \nDID LEAVE \n", formatVector(countCorrectYes))), 
                 c(paste0("PREDICT STAY \nBUT LEFT \n", formatVector(falseNegatives)),
                   paste0("PREDICT STAY \nDID STAY \n", formatVector(countCorrectNo))))

    # now make the plot    
    image(t(matrix(rep(c(1,0), each = 3), byrow = TRUE, nrow =2)), 
          col = c("palegreen", "salmon"), xaxt = "n", yaxt = "n")
    abline(h = c(-0.5, 0.5, 1.5), v = c(-0.25, 1.25), lwd = 2)
    text(x = rep(c(0,1), 2), y = rep(c(0,1), each = 2), labels = c(cellnote))
    
    text(x = c(0.5, 0.5), y = c(0.25, 1.25), labels = c("RIGHT", "WRONG"))
    text(x = c(0.5, 0.5), y = c(0,1), 
         labels = c(paste0(sum(!currPredictions==myData$Actual_)),
                    paste0(sum(currPredictions==myData$Actual_))),
         cex = 4)
    
  })

  output$barchart <- renderPlot({
    
    myBar <- barplot(myData$Predicted, 
            names.arg = myData$Name, 
            col = ifelse(myData$Actual_,"lightblue","blue"),
            xlab = "Consultant",
            ylim = c(0,100),
            ylab = "Chance of Leaving (%)",
            axisnames = FALSE,
            main = "Barplot of the chance of leaving \nand showing how this translates to a predicted outcome")
    axis(1, c(myBar), ifelse(predictions()==myData$Actual_, myData$Name, ""), font = 2)
    axis(1, c(myBar), ifelse(predictions()==myData$Actual_, "", myData$Name))
    legend("topright", c("Has Left", "Has Stayed"), fill = c("lightblue","blue"))
    abline(h = input$cutoff, lwd = 2)
    text(x = 12, y = input$cutoff + 3, "Cut Off")
    
  })
  
  output$correctcount <- renderText({
    
    paste0("Correct Predictions: \n", sum(predictions()==myData$Actual_), "/", length(myData$Actual_))
  
  })
  
  output$falsePositives <- renderText({
    
    predictions <- myData$Predicted >= input$cutoff
    paste0("Of those who have left, ", 
           sum(predictions()==myData$Actual_ & !myData$Actual_)* 100/sum(!myData$Actual_), "% are correct")
    
  })
  
  output$falseNegatives <- renderText({
    
    paste0("Of those who have stayed, ", 
           sum(predictions()==myData$Actual_ & myData$Actual_) * 100 / sum(myData$Actual_), "% are correct")
    
  })
})
