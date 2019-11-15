# Code created by Viola Glenn for R-Ladies San Diego
# aRt with R talk July 2019
# @violadoesdata
# Shamelessly standing on the shoulders of other great data folks:
# http://giorasimchoni.com/2017/07/09/2017-07-09-read-my-face/

###################################
###          SET UP             ###
###                             ###    
###################################

# Load our packages-----------------------------------------

library(tidyverse)
library(stringr)
library(imager)
library(abind)
library(grid)

# Set your working directory for easier config--------------
# You should also drop any long text (.txt) or photos (.jpg) 
# you want to use in here

setwd('/Users/violaglenn/Documents/RLadies')

# Load image------------------------------------------------

img <- load.image("gab.jpg") %>%
  resize(500, 700) #Resizing will just get us all on the same page for later
plot(img)

# Load Text-------------------------------------------------
# I'm grabbing the R-Ladies mission statement from our website. 
# Let's also take a moment to soak this in and remember what
# we're doing here!

mission <- 'R-LADIES IS A WORLDWIDE ORGANIZATION WHOSE MISSION IS TO 
PROMOTE GENDER DIVERSITY IN THE R COMMUNITY.The R community suffers 
from an underrepresentation of minority genders (including but not 
limited to cis/trans women, trans men, non-binary, genderqueer, agender) 
in every role and area of participation, whether as leaders, package 
developers, conference speakers, conference participants, educators, or users.
As a diversity initiative, the mission of R-Ladies is to achieve proportionate
representation by encouraging, inspiring, and empowering people of genders 
currently underrepresented in the R community. R-Ladies’ primary focus, 
therefore, is on supporting minority gender R enthusiasts to achieve their 
programming potential, by building a collaborative global network of R leaders, 
mentors, learners, and developers to facilitate individual and
collective progress worldwide.'

mission <- tolower(mission) 

###################################
###       THE BASICS            ###
###                             ###    
###################################

# Prep the image------------------------------------------------

# Let's first start with a grayscale version of this image
# to make it clear what we're up to. We'll add color later.

img <- grayscale(img)

# Convert to a matrix where the value in each cell = saturation
# Cell values will be from 0 to 1, representing how dark the color is
sat_grid <- img %>% 
  as.matrix() %>% 
  t()

dim(sat_grid) #Remember how we resized to 700 by 500? That's the size of our matrix now!

plot(as.cimg(sat_grid))

# What if we just plot where saturation is 0.5 or higher?
plot(as.cimg(sat_grid > 0.5))

# Prep the text------------------------------------------------

# Start easy w/ 1 letter per pixel, so break the mission statement into 
# letters. We could do some extra cleaning and get rid of white space and
# characters now, or we could just figure that out later.
text <- str_split(mission, "")[[1]]
text

# Fill the grid (imager) with the letters--------------------------
# And learn about for loops!

grid.newpage() #Never forget this step, else you'll just be overwriting 
               #the existing plot

counter <- 0

for (i in seq(1, nrow(sat_grid), 13)) { #Rows, it took some trial and error to get the 13 and 5
  for (j in seq(1, ncol(sat_grid), 5)) {  #Columns
    
    #For each cell of the image matrix [i, j]:
    if (sat_grid[i, j] < 0.5) { #Only fill in areas that are saturated
      counter <- ifelse(counter < length(text), counter + 1, 1) #If we run out of characters, start over
      grid.text(text[counter], #Take the right letter
                x = j / ncol(sat_grid), #Convert to ratios that grid.text likes instead of pixels
                y = 1 - i / nrow(sat_grid), #Same w/ ratios
                gp = gpar(fontsize = 10),
                just = "left")
    }
  }
}

# Adapt the filling to account for letter size----------------------

# This is a bit crowded where letters like m and w are wide.
# Let's make more space for big letters & less for small letters.

fatChars <- c(LETTERS[-which(LETTERS == "I")], "m", "w", "@")
skinnyChars <- c("l", "I", "i", "t", "'", "f", ",")

# We'll just adapt the loops above to handle different types of letters

grid.newpage()

counter <- 0

for (i in seq(1, nrow(sat_grid), 15)) {
  for (j in seq(1, ncol(sat_grid), 10)) {
    
    if (sat_grid[i, j] < 0.5) { #Only fill in areas that are saturated, same as before
      counter <- ifelse(counter < length(text), counter + 1, 1) #If we run out of characters, start over, same as before
      
      #Spacing should be related not only to the current letter, but also the letters
      #before and after the current letter, so let's store those
      char <- text[counter]
      lastChar <- ifelse(counter > 1, char, " ")
      beforeLastChar <- ifelse(counter > 2, lastChar, " ") 
      
      grid.text(char,
                x = j/ncol(sat_grid) +
                 + 0.004 * (lastChar %in% fatChars) -
                 - 0.003 * (lastChar %in% skinnyChars) +
                 + 0.003 * (beforeLastChar %in% fatChars) -
                 - 0.002 * (beforeLastChar %in% skinnyChars),
                y = 1 - i / nrow(sat_grid),
                gp = gpar(fontsize = 10),
                just = "left")
    }
  }
}

###################################
###           COLOR!            ###
###         FUNCTIONS!          ###    
###################################

# For the sake of time, I'm collapsing a few different things into this section.
# 1) Wrapping things up in a function
# 2) Adding color
# 3) Integrating some of the functionality from above (fontSize, resize)
#    into function parameters

# Parameters-------------------------

#img = image
#text = text
#thresh = The saturation value we previous set to 0.5. 
#         Any value between 0 and 1 that will dictate
#         which cells to place letters w/in.
# color = T/F, if the image contains color
# fontSize = font size of letters
# resize = T/F, resize to 700 by 500 pixels

# Define function-------------------------

drawImageWithText <- function(img, 
                              text, 
                              thresh, 
                              color = FALSE, #adding an argument here sets it as the default
                              fontSize = 10, 
                              resize = TRUE) {
  
  #Format the text, exactly as before, but now within the function
  text <- paste(text, collapse = " ")
  text <- str_replace_all(text, "\n+", " ")
  text <- str_replace_all(text, " +", " ")
  text <- str_split(text, "")[[1]]
  
  #Customize character spacing, exactly as before, but now within the function
  fatChars <- c(LETTERS[-which(LETTERS == "I")], "m", "w", "@")
  skinnyChars <- c("l", "I", "i", "t", "'", "f", ",")
  
  #Resize if specified -- This is new
  if (resize) img <- resize(img, 700, 500)
  
  #Convert to matrix for b/w images, exactly as before
  imgGSMat <- img %>% grayscale %>% as.matrix %>% t()
  
  #Create an additional matrix for color images -o tell algo
  #which color to place in each cell
  imgMat <- img %>%  as.array() %>% adrop(3) %>% aperm(c(2, 1, 3))
  
  #Prep to graph
  grid.newpage()
  counter <- 0
  
  #Loop through cells, as before but with some extra features and cleanups
  for (i in seq(1, nrow(imgGSMat) - fontSize, fontSize + 1)) { #New Feature 1, rows and cols are now dynamic
    for (j in seq(1, ncol(imgGSMat) - fontSize, fontSize)) {
      if (imgGSMat[i, j] < thresh) {
        counter <- ifelse(counter < length(text), counter + 1, 1)
        beforeLastChar <- ifelse(counter > 2, lastChar, " ")
        lastChar <- ifelse(counter > 1, char, " ")
        char <- text[counter]
        grid.text(char,
                  x = 0.01 + j/ncol(imgGSMat) #New Feature 2: Cleaned up spacing
                    +  0.004 * (lastChar %in% fatChars) 
                    -  0.003 * (lastChar %in% skinnyChars) 
                    +  0.003 * (beforeLastChar %in% fatChars) 
                    -  0.002 * (beforeLastChar %in% skinnyChars),
                  y = 1 - i / nrow(imgGSMat) - 0.01,
                  gp = gpar(fontsize = fontSize, col = ifelse(!color, #New feature 3: Add color if not black and white!
                                                              "black",
                                                              rgb(imgMat[i, j, 1],
                                                                  imgMat[i, j, 2],
                                                                  imgMat[i, j, 3]))),
                  just = "left")
      }
    }
  }
}



###################################
###       FAST, EFFORTLESS      ###
###        CUSTOMIZATION!       ###
###################################

# Now we unleash the true power of functions and we quickly
# interate through parameters on new images and text
# to create really beautiful things.

img <- load.image("gab.jpg")
mission <- 'R-LADIES IS A WORLDWIDE ORGANIZATION WHOSE MISSION IS TO 
PROMOTE GENDER DIVERSITY IN THE R COMMUNITY.The R community suffers 
from an underrepresentation of minority genders (including but not 
limited to cis/trans women, trans men, non-binary, genderqueer, agender) 
in every role and area of participation, whether as leaders, package 
developers, conference speakers, conference participants, educators, or users.
As a diversity initiative, the mission of R-Ladies is to achieve proportionate
representation by encouraging, inspiring, and empowering people of genders 
currently underrepresented in the R community. R-Ladies’ primary focus, 
therefore, is on supporting minority gender R enthusiasts to achieve their 
programming potential, by building a collaborative global network of R leaders, 
mentors, learners, and developers to facilitate individual and
collective progress worldwide.'

drawImageWithText(img, mission, thresh = 0.95, color = TRUE, fontSize = 10)

# Not bad, but what if we tweak some of our parameters?
drawImageWithText(img, text, thresh = 0.95, color = TRUE, fontSize = 8)
drawImageWithText(img, text, thresh = 0.85, color = TRUE, fontSize = 5)

# And now the sky is the limit
# How about tapping into recent US Womens' World Cup mania?
img <- load.image("rapinoe.jpg")
plot(img)
text <- 'i deserve this' #A famous and favorite recent quote
drawImageWithText(img, text, thresh = 1.5, color = TRUE, fontSize = 6)

# Lyrics and lead singer from one of my favorite bands...
img <- load.image('hanna8.jpg')
plot(img)
lyrics <- readChar('letigre.txt', file.info('letigre.txt')$size)
lyrics
lyrics <- gsub('[^0-9A-Za-z ]','', lyrics) #a little extra cleaning b/c I brought in very dirty text
lyrics
drawImageWithText(img, lyrics, thresh = 1.1, color = TRUE, fontSize = 6)

# How about reusing that R-Ladies mission text on our logo?
img <- load.image("rladies.jpg")
plot(img)
drawImageWithText(img, mission, thresh = 1, color = TRUE, fontSize = 6)
