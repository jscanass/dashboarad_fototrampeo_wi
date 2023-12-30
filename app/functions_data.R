# Jorge Ahumada (c) Conservation International
# IaVH dashboard for phototrapping month
# Analysis required for dashboard

require(tidyverse)
require(dplyr)
require(tidyr)
require(readr)
require(readxl)
require(ggplot2)
require(treemapify)
library(lubridate)
library(ggmap)
require(cowplot)
require(png)
require(magick)
library(gridExtra)
library(extrafont) 
library(leaflet)
library(htmltools)

#font_import()
#loadfonts()



  
# FUNCTIONS
drawInfoBoxes <- function(project, indicator){
  if(indicator == "images"){
    ind <- format(project$n, big.mark = ",")
    icon_file <- "logo_images.png"
    title <- "Imágenes"
    pos <- round(project$rank_images,0)
  }
  else if(indicator == "cameras") {
    ind <- format(project$ndepl, big.mark = ",")
    icon_file <- "logo camera.png"
    title <- "Cámaras trampa"
    pos <- round(project$rank_ndepl,0)
  }
  else if(indicator == "effort"){
    ind <- format(project$effort, big.mark = ",")
    icon_file <- "logo calendar.png"
    title <- "Días-cámara"
    pos <- round(project$rank_effort,0)
  }
  else{
    print("Select a valid indicator")
    exit()
  }
  
  
  # Build information boxes
  # boxes for stats
  x <- 470
  y <- 137
  w <- 940
  h <- 274
  font <- "Proxima Nova"
  sizeTitles <- 7
  sizeNumbers <- 13
  sizePos <- 11
  sizeSubTitles <- 6
  hshift <- 0.3
  vshift <- 0.1
  
  df <- data.frame ( x = x/100, y = y/100, h = h/100, w = w/100)
  
  #read in icon files
  icon <- image_read(icon_file)
  #trophy_icon <-image_read("logo trophy.png")
  
  #Setup canvas
  p <- ggplot(df, aes(x, y, height = h, width = w)) + geom_tile(fill="transparent") + theme_void()
  
  # draw icon
  p <- p + draw_image(icon, 0, 0.3, 2.3, 2.3)
  
  #draw titles
  p <- p + geom_text(color = "black", size = sizeTitles, aes(x = 4, y = 2.3, label = title, family = font))
  
  #draw the numbers
  p <- p + geom_text(color = "black", size = sizeNumbers, aes(x = 4 + hshift, y = 1.3 + vshift, label = ind, family = font, fontface = "bold"))
  
  #draw the Position icon
  #p + draw_image(trophy_icon, 8.3, 0.9, 1, 1)
  
} # draw the individual boxes that go into makeInfoPanel()

makeInfoPanel <- function(sub) {
  plot1 <- drawInfoBoxes(sub, "images")
  plot2 <- drawInfoBoxes(sub, "cameras")
  plot3 <- drawInfoBoxes(sub, "effort")
  
  grid.arrange(plot1, plot2, plot3, nrow = 3)
} # make information panel with operational statistics
drawSpeciesDiversityBox <- function(site){
  
  #site <- data %>% filter(site_name == project)
  
  font <- "Proxima Nova"
  title <- c("Especies", "Mamíf.", "Aves")
  sizeTitles <- 7
  sizeNumbers <- 16
  sizePos <- 12
  sizeSubTitles <- 6
  # boxes for stats
  x <- c(470, 235, 705)
  y <- c(411, 137, 137)
  w <- c(940, 470, 470)
  h <- c(274, 274, 274)
  
  diversity_species <-with(site, c(ospTot,ospMamiferos, ospAves))
  ranks <- with(site, c(rank_onsp, rank_onMamiferos, rank_onAves))
  #Load box dimensions
  df <- data.frame ( x = x/100, y = y/100, h = h/100, w = w/100)
  
  #Load images icons into workspace
  species_icon <- image_read("speciesRichness.png")
  #trophy_icon <- image_read("logo trophy.png")
  
  #Setup canvas
  p <- ggplot(df, aes(x, y, height = h, width = w)) + geom_tile(fill="transparent") + theme_void()
  #draw large species icon
  p  <- p + draw_image(species_icon, -0.3, 3, 2.3, 2.3)
  # print Numero de especies
  p <- p + geom_text(color = "black", size = sizeTitles, aes(x = 3.6, y = 5, label = title[1], family = font))
  # print species diversity value + Pos. title
  p <- p + geom_text(color = "black", size = sizeNumbers, aes(x = 3.1, y = 3.9, label = format(diversity_species[1], big.mark = ","), family = font, fontface = "bold"))
  #print position value and draw image trophy
#   p <- p + geom_text(color = "black", size = sizePos, aes(x = 8, y = 3.9, label = ranks[1], family = font))
  #+ draw_image(trophy_icon, 8.4, 3.6, 1, 1)
  
  # Mammal stats
  p <- p + geom_text(color = "black", size = sizeSubTitles, aes(x = 0.6, y = 2, label = title[2], family = font)) + geom_text(color = "black", size = sizeNumbers, aes(x = 0.45, y = 1, label = format(diversity_species[2], big.mark = ","), family = font, fontface = "bold"))
  #draw_image(trophy_icon, 3.5, 0.6, 1, 1)
  
  # shift the bird stats to align with the top position trophy
  shift <- 0.3
  
  #Bird stats
  p + geom_text(color = "black", size = sizeSubTitles, aes(x = 5.5 + shift, y = 2, label = title[3], family = font)) + geom_text(color = "black", size = sizeNumbers, aes(x = 5.4 + shift, y = 1, label = format(diversity_species[3], big.mark = ","), family = font, fontface = "bold"))
} # draw species diversity box for dashboard
makeSpeciesPanel <- function(project) {
  drawSpeciesDiversityBox(project)
#   plot1 <- drawSpeciesDiversityBox(project)
#   plot2 <- makedonutplots(project,"mammals")
#   plot3 <- makedonutplots(project,"birds")
  
#   grid.arrange(plot1, NULL, NULL, layout_matrix = rbind(c(1,1), c(2,3)))
#   grid.arrange(plot1, layout_matrix = rbind(c(1,), c(2,)))
} # Assemble the species panel using drawSpeciedDiversityBox() and makedonutplots()
slotDateinweek <- function(date, week_intervals) {
  index <- sum(date >= week_intervals)
  return(week_intervals[index])
} # group data by weekly intervals

makedonutplots <- function(data, taxa) {
  
  #data <- filter(data, site_name == project)
  
  if(taxa == "birds"){
    df <- data.frame(value = c(data$ospAves/data$nspAves,  data$ospAves/data$nspAvesCol), type = c("regional","national"))
    image_name <- "bird_icon.png"
  }
  else {
    df <- data.frame(value = c(data$ospMamiferos/data$nspMamiferos,  data$ospMamiferos/data$nspMamiferosCol), type = c("regional","national"))
    image_name <- "mammal_icon.png"
  }
  
  #pie_colors <- c("#6FC38C","black")
  v1 <- df$value[1]
  v2 <- df$value[2]
  label_nacional <- paste(round(v2*100,0),"% riqueza nal.", sep = "")
  label_regional <- paste(round(v1*100,0),"% riqueza dept.", sep = "")
  
  bird <- readPNG(image_name)
  
  p <- ggplot(df, aes(x = type, fill = type, y = value)) + geom_col(width = 0.3) + scale_x_discrete(limits = c(" "," "," "," ", " ", "regional","national")) +
    ylim(0,1) + 
    coord_polar("y") + scale_fill_manual(values = c("regional" = "#338992", "national" = "#6FC38C"), guide = guide_legend(title = NULL, title.position = "top", nrow = 2), labels = c(label_nacional, label_regional)) + 
    theme_void() + 
    theme(legend.position = "top", legend.justification = "left", text = element_text(family = "Proxima Nova", size = 15))
  
  p <- ggdraw(p)
  p + draw_image(bird, 0.37, 0.25, 0.32, 0.32)
  
} # make regional and national diversity donuts for dashboard

calculateEffort <- function(start_date, end_date){
  require(lubridate)
  inter <- interval(start_date, end_date)
  sampling_days <- time_length(inter, "days")
  sampling_days <- sampling_days[which(sampling_days > 0)] # only counting deployments with positive # of days
  sum(sampling_days, na.rm = T)
} # calculate effort in camsxdays

makeSpeciesGraph <- function(subset) {
  subset <- subset %>% group_by(sp_binomial,class) %>% summarize(nimages = n()) %>% drop_na() %>% arrange(desc(nimages))

  subset <- head(subset, 15)
  subset$sp_binomial <- factor(subset$sp_binomial, levels = subset$sp_binomial[order(subset$nimages)])

  ggplot(subset, aes(y = sp_binomial, x = nimages, fill = class)) + geom_bar(stat = "identity") + scale_x_log10() + xlab("Número de imágenes") + ylab("Especie") + geom_text(aes(label = nimages), nudge_x = -0.2, colour = "white") + theme_light() + scale_fill_manual(values = c("Aves" = "#338992", "Mammalia" = "#6FC38C", "Unknown" = "#DED78E", "Other" = "black"), guide = guide_legend(title = NULL), labels = c("Aves", "Mamíferos","No identificado", "Otro"))
  
} # species tally

makeDeploymentGuideGraph <- function(subset) {
  
  #subset <- data %>% filter(site_name == project)
  
  #group images by weeks
  subset$photo_datetime <- date(subset$photo_datetime)
  start <- min(subset$photo_datetime)
  end <- max(subset$photo_datetime)
  max_weeks <- ceiling(as.numeric(difftime(end, start, units = "weeks")))
  week_intervals <- start + weeks(0:max_weeks)
  subset <- subset %>% rowwise() %>%  mutate(startWeekDate = slotDateinweek(photo_datetime, week_intervals))
  
  deploysTime <- table(subset$deployment_name,subset$startWeekDate)
  deploysTime <- as.data.frame(deploysTime)
  names(deploysTime) <- c("deployment_ID","startWeekDate","nimages")
  deploysTime$startWeekDate <- ymd(deploysTime$startWeekDate)

  ggplot(deploysTime, aes(x = startWeekDate, y = deployment_ID, fill = nimages)) + geom_tile(colour = "white") + theme_minimal() + xlab("") + ylab("") + scale_fill_gradient(low = "#338992", high = "#DED78E") + guides(fill = guide_legend(title = "# de imágenes", title.position = "bottom")) + scale_x_date(date_labels = "%b %d")
} # Deployment/date graph

makeMapGoogle <- function(project, data, meanlon, meanlat) {
  sub <- data %>% filter(site_name == project)
  
  map1 <- get_googlemap(center = c(lon = meanlon, lat = meanlat), zoom = 6)
  ggmap(map1, extent = "normal") + geom_point(data = data, aes(x = lon, y = lat), color = "black", size = 3) + geom_point(data = subset(data, row == sub$row), aes(x = lon, y = lat), shape = 21, colour = "red", fill = "white", size = 5, stroke = 5) + xlab("") + ylab("") + theme_void()
  
  
} # Map location of the study and highlight

makeMapLeaflet <- function(data, project, nprojects, bounds) {
  color <- rep("black", nprojects)
  size <- rep (6,nprojects)
  color[project$row] <- "red"
  size[project$row] <- 10
  leaflet(data) %>% 
    fitBounds(lng1 = bounds$lon[1], lat1 = bounds$lat[2], lng2 = bounds$lon[3], lat2 = bounds$lat[4]) %>% 
    addTiles() %>% addCircleMarkers(color = color, radius = size) %>% addScaleBar("bottomleft")
} # Map location of the study and highlight (with leaflet pkg)