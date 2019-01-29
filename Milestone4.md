# Milestone 4

Contributors:
- [Marcelle Chiriboga](https://github.com/mchiriboga)
- [Sayanti Ghosh](https://github.com/Sayanti86)

#### What changes did you decide to implement given the time limit, and why do you think this is the best thing to focus on?

#### If you were to make the app again from scratch (or some other app in general), what would you do differently?

If we have to make an app from scratch we will first wrangle the data by re-usable R scripts .  
We will make the design simpler and try to convey the information with less number of simple plots . Also we would like to incorporate geographical information by using interactive maps. We are very intrigued by Shinny Dashboard , which we think is visually and functionally appealing , so implanting dashboard is one of our items in Wishlist . Also we will like to make either a table or plot which is taking live data and the changes are visible during run time , however , this depends on what data we are working with .  

#### What were the greatest challenges you faced in creating the final product?

The greatest challenges we faced while creating the final product : 

**Wrangling the data .**  
Our data had huge number of variables , as this was an survey data we had to clean up the answers , as for the same answer people replied in different way but meant same. So we had to clean all of them to make sure we have proper data while making plots. Also we need to analyze lot due to number of variables which sometimes gave similar information but with slight difference . We had to wrangle those variables in a way so that we have one set of relevant variables.

**Making the word-cloud interactive.**  
Word cloud works with frequency of words , but we wanted to add filter of Age, Country and Gender. So when we wrangled our data with these filters and then calculated the frequency of words , we were loosing the columns Age, Country and Gender due to the frequency calculation. It was the most challenging part as we need to make the wrangling along with filter and store it directly in reactive variable. It took us time to figure out that we can do all these inside the reactive variable.

**Rescaling the plot sizes with respect to Window size .**  
When we tried to measure the Window size and pass that as input for width and height of each plot , it did not work . We were not able to get the height . Then we tried to give “auto” for both width and height , which again did not give expected result . Finally , after lot of Google search we realize the height has some issue in Shiny App .So we fixed the plot height = 360Px but made the width =”auto”  , which is working fine . 

**Making dynamic filters for specific Tabs.**  
We did not want to have our filters in “Usage” tab . So to hide the filters we could not control it with Shiny library. We needed to add shinyjs to enable toggle filter . It took some research and time to figure out . 

**Library dplyr , created issue in Word cloud .**  
For our “Data” tab , we wanted to show the column names in  more readable format . However , we added library(dplyr) to use the renaming of column from code but not by changing directly from excel. This made our Word cloud crash . It was a tricky issue to resolve as everything was working fine . 
