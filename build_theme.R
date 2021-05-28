####### COLOR HISTORY #######
#E8E8E8 -> #EAEAEA -> #F5F5F5
#BFBFBF -> #C6C6C6
#96939B -> #A09DA5
#16324F -> #1F466F
#13293D -> #1D3F5F
#############################

# dependencies
library(extrafont)
library(grDevices)

# load fonts
#loadfonts(device = 'win', quiet = TRUE)


# create plot theme
pitcher_theme <- function() {
  
  theme_classic() +
    
    theme(
      
      # base elements
      line = element_line(color = "#A09DA5", linetype = 1, lineend = "butt"),
      rect = element_rect(fill = "#F5F5F5", color = "#F5F5F5", size = 0.5, linetype = 1),
      text = element_text(family = "JetBrains Mono", face = "plain", color = "#1F466F"),
      
      # title elements
      plot.title = element_text(size = rel(1.5), family = "Roboto", face = "bold", 
                                hjust = 0.5, vjust = 1, color = "#1D3F5F"),
      plot.subtitle = element_text(size = rel(1.25), family = "Roboto", face = "plain", 
                                   hjust = 0, vjust = 0.5, color = "#1F466F"),
      axis.title.x = element_text(size = rel(1.1), family = "JetBrains Mono", face = "bold"),
      axis.title.y = element_text(size = rel(1.1), family = "JetBrains Mono", face = "bold"),
      axis.text = element_text(size = rel(0.90), family = "JetBrains Mono", 
                               face = "plain", color = "#1F466F"),
      
      # legend elements
      legend.title = element_text(size = rel(1.1), family = "JetBrains Mono", face = "plain"),
      legend.text = element_text(size = rel(0.9), family = "JetBrains Mono"),
      legend.background = element_rect(fill = NA),
      
      # panel elements
      axis.ticks = element_line(color = "#1F466F"),
      axis.line = element_line(color = "#1D3F5F"),
      panel.grid.major = element_line(color = "#A09DA5"),
      panel.grid.minor = element_line(color = "#A09DA5"),
      
      # plot elements
      # plot.background = element_rect(fill = "#F5F5F5"),
      # panel.background = element_rect(fill = "#F5F5F5")
      plot.background = element_rect(fill = NA),
      panel.background = element_rect(fill = NA)
    )
  
}