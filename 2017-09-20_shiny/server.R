# Define server logic
shinyServer(function(input, output) {
 
  # Function that Renders Bar Plot
  output$topicPlot <- renderPlot({
    
    # Reordering the factor "levels" in the variable level so we see topics in descending order of votes
    dat_SD_melt_level <- within(dat_SD_melt[level==input$level], # THIS LINE INCORPORATES THE INPUT
                                topic <- factor(topic, 
                                                levels=names(sort(table(topic), 
                                                                  decreasing=TRUE)))) 
    
    # Creating a bar plot to display the number of votes per topic for a given experience level
    p <- ggplot(dat_SD_melt_level,aes(x=topic))+geom_bar(stat="count",colour="black")
    p <- p + r_ladies_theme() # Adding the R ladies theme
    p <- p + theme(axis.text.x = element_text(angle=20,vjust=0.6,size=14)) # Adjusting the theme
    p
    
  })

  ##########  
  ## Function that Renders the Leaflet Map
  
  output$rladiesMap <- renderLeaflet({
    leaflet(data = dat_global) %>% # Add the R ladies global data here
      
      # Peruse other basemaps here: http://leaflet-extras.github.io/leaflet-providers/preview/ 
      # Examples, Thunderforest.SpinalMap, Stamen.Watercolor,Stamen.TonerLite
      
      addProviderTiles(providers$Stamen.TonerLite) %>%
      addMarkers(~lon,~lat ,popup = ~paste0("Chapter Name: ",name,"<br/> Country: ",country))
                 # Labels 
  })
  ##########  
})
