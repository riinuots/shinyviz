
library(shiny)
library(ggplot2)
library(tidyr)
library(dplyr)
library(forcats)
library(magrittr)
library(scales)

alldata = diamonds

alldata$aaa.onepanel = "ALL" #dummy variable to plot everything on one "panel", i.e. just one plot

#creating categrocal variables by cutting contunuous values into groups
alldata = alldata %>% 
  mutate(carat.quartiles = cut(carat,
                               breaks = quantile(carat),
                               include.lowest=TRUE,
                               labels = c("Small", "Medium", "Large", "Very large")),
         depth.quartiles = cut(depth,
                               breaks = quantile(depth),
                               include.lowest=TRUE,
                               labels = c("Small", "Medium", "Large", "Very large")),
         price.quartiles = cut(price,
                               breaks = quantile(price),
                               include.lowest=TRUE,
                               labels = c("Expensive", "More expensive", "Very expensive", "Ridiculously expensive"))
  )


#there's a logical for this in the ui
barplot_type = "stack" #'fill' or 'stack'


shinyServer(function(input, output) {
  
  # subset data --------------------------
  data_subset         <- reactive({     
    # for convenience
    expl1 = input$explanatory1
    expl2 = input$explanatory2
    outcome = input$outcome
    
    #if testing set input values here
    #expl1 = 'aaa.onepanel'
    #expl2 = 'aaa.onepanel'
    #outcome = 'price.quartiles'


    # Subsetting, variable name "cut" currently hardcoded here...
    alldata = alldata %>% 
      filter(cut %in% input$subset1)
    

    subdata = alldata[, c(expl1, expl2, outcome)]
    colnames(subdata) = c('expl1', 'expl2', 'outcome')
    
    #reverse factor levels
    if (input$rev_expl1){
      subdata$expl1 %<>%   fct_rev()
    }
    if (input$rev_expl2){
      subdata$expl2 %<>%   fct_rev()
    }
    if (input$rev_outcome){
      subdata$outcome %<>%  fct_rev()
    }

    # shift outcome levels
    subdata$outcome %<>%  fct_shift(input$fct_shift)
    
    subdata
    
  })
  
  create_summary = reactive({
    
    subdata = data_subset()
    
    expl1 = input$explanatory1
    expl2 = input$explanatory2
    outcome = input$outcome
    
    
    #count instances
    subdata %>% 
      count(expl1, expl2, outcome) ->
      count_outcomes
    
    #sum instances for totals
    count_outcomes %>% 
      group_by(expl1, expl2) %>% 
      summarise(total = sum(n)) ->
      total_numbers
    
    summary_table = full_join(count_outcomes, total_numbers, by=c('expl1', 'expl2'))
    
    summary_table$relative = 100*summary_table$n/summary_table$total
    
    summary_table$relative %>% 
      signif(2) %>% #round to 2 significant figrues
      formatC(digits=2, format='fg') %>% #format to 2 significant figures
      paste0('%') ->
      summary_table$relative_label
    
    
    
    summary_table
    
  })
  
  # create plot
  myplot_p = reactive({
    
    summary_table = create_summary()
    
    expl1 = input$explanatory1
    expl2 = input$explanatory2
    outcome = input$outcome
    
    
    if (input$axis_relative){
      barplot_type = 'fill' 
    }
    if (input$reverse_colours){
      colour_order = -1
    }else{
      colour_order = 1
    }
    
    #as.numeric as necessary as the input passes on our numbers as characters
    my_ncol = as.numeric(input$legend_columns)
    
    my_breaks = 0:10/10
    
    p = ggplot(summary_table, aes(x=expl1, fill = outcome, y=n))+
      geom_bar(position=barplot_type, stat='identity') +
      facet_wrap(~expl2, ncol=1)+
      coord_flip() +
      theme(
        strip.background = element_rect(fill = "white", colour = "grey50", size = 0.2),
        panel.background = element_rect(fill = "white", colour = NA), 
        panel.border = element_rect(fill=NA, linetype = 'solid', colour = "grey50"),
        #panel.margin = unit(2, "lines"),
        plot.margin = unit(c(2, 2, 2, 2), 'lines'),
        panel.grid.major.x = element_line(colour = "grey90", size = 0.2),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        strip.text.x = element_text(size=12),
        axis.text.x = element_text(size=12, vjust=0.7, colour='black'),
        axis.text.y = element_text(size=12, colour='black'),
        axis.title = element_text(size=14),
        #axis.title.y = element_blank(),
        legend.justification=c(1,0),
        legend.position='top',
        legend.title=element_text(size=12),
        legend.text=element_text(size=12)
      )+
      ylab('Diamonds')+
      scale_fill_brewer(palette=input$my_palette, name = names(outcome), direction=colour_order)+
      guides(fill=guide_legend(ncol=my_ncol)) +
      xlab(names(expl1))
    
    summary_table$outcome = fct_drop(summary_table$outcome)
    first_outcome = levels(summary_table$outcome)[1]
    
    summary_table %>%
      filter(outcome==first_outcome) ->
      first_only
    
    if (input$axis_relative){
      p = p+scale_y_continuous(expand = c(0, 0), label=percent, breaks=my_breaks)
      
    }else{
      p = p+ scale_y_continuous(expand = c(0, 0))
    }
    
    if (input$perc_label){
      p = p+geom_text(data = first_only, aes(label=relative_label), y=0.01, size=7, hjust=0,
                      colour=input$black_white)
    }
    
    
    p
    
  })
  
  
  # render plot ----------------------------
  
  output$myplot = renderPlot({
    
    p = myplot_p()
    p
    
  })
  
  output$plot.ui <- renderUI({
    plotOutput("myplot", width = paste0(input$width, "%"), height = input$height)
  })
  
  
  
  
  
  # create and render output table -------------------------
  output$table = renderTable({
    
    subdata = data_subset()
    
    expl1 = input$explanatory1
    expl2 = input$explanatory2
    outcome = input$outcome
    
    colnames(subdata) = c('expl1', 'expl2', 'outcome')
    
    
    subdata %>% 
      count(expl1, expl2, outcome) %>% 
      spread(outcome, 'n', fill=0, convert = TRUE) ->
      summary_table
    
    # adding percentage columns
    number_colnames = colnames(summary_table[, 3:ncol(summary_table) ])
    
    summary_table$total = as.integer(rowSums(summary_table[, number_colnames]))
    
    rel_colnames = paste0(number_colnames, '_%')
    
    summary_table[, rel_colnames] = 100*summary_table[, number_colnames]/summary_table$total
    
    summary_table  = summary_table %>% rename_('Explan.' = 'expl1', 'Split' = 'expl2')
    
    summary_table
    
  })


  
  
  
  
  
  
})