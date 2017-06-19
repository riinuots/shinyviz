rm(list=ls())

library(shiny)
library(shinythemes)

#load('allvars.rda')
selected_varnames = read.csv('formatted_varnames_forUI.csv', comment.char = '#', header=T)
allvars = as.character(selected_varnames$vars)
names(allvars) = as.character(selected_varnames$var_names)

allvars_grouped = list(
  'General' = allvars[1:which(allvars=='aaa.onepanel')],
  'Size' = allvars[(which(allvars=='aaa.onepanel')+1):which(allvars=='depth.quartiles')],
  'Aesthetics' = allvars[(which(allvars=='depth.quartiles')+1):which(allvars=='color')],
  'Price' = allvars[(which(allvars=='color')+1):length(allvars)]
)

palettes = list(
  'Qualitative' = rev(c('Accent', 'Dark2', 'Paired', 'Pastel1', 'Pastel2', 'Set1', 'Set2', 'Set3')),
  'Sequential'  = rev(c('Blues', 'BuGn', 'BuPu', 'GnBu', 'Greens', 'Greys', 'Oranges'
                        , 'OrRd', 'PuBu', 'PuBuGn', 'PuRd', 'Purples', 'RdPu', 'Reds', 'YlGn', 'YlGnBu', 'YlOrBr', 'YlOrRd')),
  'Diverging'   = rev(c('BrBG', 'PiYG', 'PRGn', 'PuOr', 'RdBu', 'RdGy', 'RdYlBu', 'RdYlGn', 'Spectral'))
)

available_variables = allvars

#load('available_diagnosis.rda')


shinyUI(fluidPage(theme = shinytheme("sandstone"),
                  #shinythemes::themeSelector(),
                  # Application title
                  titlePanel("Example shiny app"),
                  #titlePanel("UNDER MAINTENANCE"),
                  
                  
                  fluidRow(
                    
                    column(4, # A - input panel
                           wellPanel( # begin_A1
                             # A1.1 - explanatory, split, outcome
                             selectInput("explanatory1",
                                         label    = "Explanatory variable:",
                                         selected = c("carat.quartiles"),
                                         choices  = allvars_grouped,
                                         multiple = FALSE),
                             selectInput("explanatory2",
                                         label    = "Split by:",
                                         selected = c("aaa.onepanel"),
                                         choices  = allvars_grouped,
                                         multiple = FALSE),
                             selectInput("outcome",
                                         label    = "Outcome variable:",
                                         selected = c("color"),
                                         choices  = allvars_grouped,
                                         multiple = FALSE),
                             column(12, # A1.2 - relative to total
                                    #this is geom_bar(position = 'fill')
                                    checkboxInput("axis_relative",
                                                  label = "Relative to total (x-axis to %)",
                                                  value = FALSE)
                             ),
                             fluidRow( # A.1.3 - reverse order
                               column(3,
                                      h5('Reverse order:')),
                               column(3,
                                      checkboxInput("rev_expl1",   "Explanat.",   FALSE) ),
                               column(2,
                                      checkboxInput("rev_expl2",   "Split",   FALSE) ),
                               column(4,
                                      checkboxInput("rev_outcome", "Outcome", FALSE) )
                             ),
                             fluidRow( # A1.4 - shift outcome levels
                               # the percentage label is only plotted for the first factor level (otherwise would start overlapping)
                               # this "shifter" is useful if you want another level to be the first one on the barplot
                               # this complements the Reverse order options.
                               sliderInput("fct_shift", "Shift outcome levels:",
                                           min = 0, max = 6, value = 0, step=1,
                                           ticks=TRUE)
                             )
                           ), #end_A1
                           wellPanel( # begin_A2
                             sliderInput("width", "Plot Width (%)", min = 20, max = 100, value = 80, step=10),
                             sliderInput("height", "Plot Height (px)", min = 100, max = 1000, value = 400, step=50)
                           ), # end_A2
                           # begin_A3
                           column(6, #begin_A3.1
                                  wellPanel(
                                    checkboxGroupInput("subset1",
                                                       label     = ("Subsetting: included cuts"),
                                                       #note the spaces after the names (e.g. 'Ideal ')
                                                       #that's because in this syntax, Shiny expects names and values to be different
                                                       #which would be useful if you data for, e.g. 1,2,3,4,5 instead of names
                                                       #without the spaces you get:
                                                       #ERROR: 'selected' must be the values instead of names of 'choices' for the input 'subset1'
                                                       choices   = list('Ideal '       = 'Ideal',
                                                                        'Premium '     = 'Premium',
                                                                        'Very Good '   = 'Very Good',
                                                                        'Good '        = 'Good',
                                                                        'Fair '        = 'Fair')
                                                       ,selected = c('Ideal', 'Premium', 'Very Good', 'Good', 'Fair'))
                                  )
                           ), #end_A3.1
                           column(6, # begin_A3.2
                                  wellPanel(
                                    selectInput("my_palette",
                                                label = "Colour palette:",
                                                selected = c("OrRd"),
                                                choices  = palettes,
                                                multiple = FALSE),
                                    checkboxInput("reverse_colours", "Reverse colours", FALSE),
                                    checkboxInput("legend2", "2-col legend", FALSE),
                                    radioButtons('legend_columns', 'Legend columns',
                                                 choices  = c(1:3),
                                                 selected = 2,
                                                 inline   = TRUE),
                                    checkboxInput("perc_label", "% label:", TRUE),
                                    radioButtons('black_white', label=NULL,
                                                 choices = list(
                                                   'Black' = 'black',
                                                   'White' = 'white'
                                                 ),
                                                 selected = 'white',
                                                 inline=TRUE)
                                  )
                                  
                           ) # end_A3.2
                           
                    ), #end_A
                    
                    
                    
                    column(8, 
                           tabsetPanel(type = "tabs", 
                                       tabPanel("Plot", uiOutput("plot.ui")), 
                                       tabPanel("Table", tableOutput('table')),
                                       tabPanel('Colour palettes', img(src='brewer-pal.png', align = "left")),
                                       tabPanel('Info', h4( a("https://github.com/riinuots/shinyviz", href="https://github.com/riinuots/shinyviz") ))
                           )
                    )
                    
                  )
                  
                  
))