# dependencies
library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggridges)
library(RColorBrewer)
library(scales)

# load data
pitch_data <- read_csv("data/pitch_data.csv", 
                       col_types = cols(X1 = col_skip()))

# replace UN with NA, test removing rows with no radar data using one column
pitch_data <- pitch_data %>% 
  mutate(PITCH_TYPE = ifelse(PITCH_TYPE %in% c("UN","CS","PO"), NA, PITCH_TYPE)) %>%
  drop_na(PITCH_TYPE, INDUCED_VERTICAL_BREAK)

# replace Undefined pitch results with NA, remove NA rows
pitch_data <- pitch_data %>%
  mutate(PITCH_RESULT = ifelse(PITCH_RESULT == "Undefined", NA, PITCH_RESULT)) %>%
  drop_na(PITCH_RESULT)

# create pitcher summary table
data_summary <- function(data) {
  
  data$BIP <- ifelse(data$PITCH_RESULT == "InPlay", 1, 0)
  data$strike <- ifelse(data$PITCH_RESULT %in% c("StrikeCalled", "StrikeSwinging", "FoulBall", "InPlay"), 1, 0)
  data$whiff <- ifelse(data$PITCH_RESULT == "StrikeSwinging", 1,
                       ifelse(data$PITCH_RESULT %in% c("StrikeSwinging", "FoulBall", "InPlay"), 0, NA))
  
  pSummary <- data %>%
    group_by(PITCH_TYPE) %>%
    summarize(
      `Num Thrown` = n(),
      Velocity = round(mean(PITCH_SPEED, na.rm = TRUE), 1),
      `Spin Rate` = round(mean(SPIN_RATE, na.rm = TRUE), 1),
      `Vertical Break` = round(mean(INDUCED_VERTICAL_BREAK, na.rm = TRUE), 1),
      `Horizontal Break` = round(mean(HORIZONTAL_BREAK, na.rm = TRUE), 1),
      BIP = sum(BIP),
      `Strike%` = round(100 * mean(strike), 1),
      `Whiff%` = round(100 * mean(whiff, na.rm = TRUE), 1))
  
  colnames(pSummary)[1] <- "Pitch Type"
  
  pSummary
}

# velo plot function
velo_plot <- function(data) {
  
  # get pitcher id
  pid <- unique(data$PITCHER_ID)
  
  # calculate avg pitchtype velo by game
  avg_velo <- data %>%
    group_by(PITCHER_ID, GAME_ID, PITCH_TYPE) %>%
    summarise(AVG_VELO = mean(PITCH_SPEED))
  
  ymin <- 5 * floor(min(avg_velo$AVG_VELO) / 5)
  ymax <- 5 * ceiling(max(avg_velo$AVG_VELO) / 5)
  
  ggplot(avg_velo, aes(x = GAME_ID, y = AVG_VELO)) +
    geom_point(aes(color = PITCH_TYPE), shape = 18, size = 5) +
    geom_path(aes(color = PITCH_TYPE), size = 2, alpha = 0.5) +
    scale_color_manual(name = "Pitch Type ",
                       values = c("CB" = unname(yarrr::piratepal("basel")[1]), #brewer.pal(7, "Dark2")[1],
                                  "CF" = unname(yarrr::piratepal("basel")[2]), #brewer.pal(7, "Dark2")[2],
                                  "CH" = unname(yarrr::piratepal("basel")[3]), #brewer.pal(7, "Dark2")[3],
                                  "FB" = unname(yarrr::piratepal("basel")[4]), #brewer.pal(7, "Dark2")[4],
                                  "SF" = unname(yarrr::piratepal("basel")[10]), #brewer.pal(7, "Dark2")[5],
                                  "SI" = unname(yarrr::piratepal("basel")[5]), #brewer.pal(7, "Dark2")[6],
                                  "SL" = unname(yarrr::piratepal("basel")[8])), #brewer.pal(7, "Dark2")[7]),
                       guide = guide_legend(nrow = 1)) +
    ylim(ymin, ymax) +
    pitcher_theme() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          legend.position = "bottom") +
    labs(title = "Game Velocity by Pitch Type",
         x = "Game ID",
         y = "Velocity")
}

# pitch usage plot
usg_plot <- function(data) {
  ggplot(data, aes(x = GAME_ID, y = PITCH_TYPE, fill = PITCH_TYPE, height = ..count..)) +
    geom_density_ridges(aes(color = PITCH_TYPE), stat = "binline", draw_baseline = FALSE, scale = 0.95, alpha = 0.5) +
    scale_fill_manual(values = c("CB" = unname(yarrr::piratepal("basel")[1]), #brewer.pal(7, "Dark2")[1],
                                 "CF" = unname(yarrr::piratepal("basel")[2]), #brewer.pal(7, "Dark2")[2],
                                 "CH" = unname(yarrr::piratepal("basel")[3]), #brewer.pal(7, "Dark2")[3],
                                 "FB" = unname(yarrr::piratepal("basel")[4]), #brewer.pal(7, "Dark2")[4],
                                 "SF" = unname(yarrr::piratepal("basel")[10]), #brewer.pal(7, "Dark2")[5],
                                 "SI" = unname(yarrr::piratepal("basel")[5]), #brewer.pal(7, "Dark2")[6],
                                 "SL" = unname(yarrr::piratepal("basel")[8]))) + #brewer.pal(7, "Dark2")[7])) +
    scale_color_manual(values = c("CB" = unname(yarrr::piratepal("basel")[1]), #brewer.pal(7, "Dark2")[1],
                                  "CF" = unname(yarrr::piratepal("basel")[2]), #(7, "Dark2")[2],
                                  "CH" = unname(yarrr::piratepal("basel")[3]), #brewer.pal(7, "Dark2")[3],
                                  "FB" = unname(yarrr::piratepal("basel")[4]), #brewer.pal(7, "Dark2")[4],
                                  "SF" = unname(yarrr::piratepal("basel")[10]), #brewer.pal(7, "Dark2")[5],
                                  "SI" = unname(yarrr::piratepal("basel")[5]), #brewer.pal(7, "Dark2")[6],
                                  "SL" = unname(yarrr::piratepal("basel")[8]))) + #brewer.pal(7, "Dark2")[7]))+
    pitcher_theme() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          legend.position = "none") +
    labs(title = "Pitch Usage by Game",
         x = "Game ID",
         y = "Pitch Type")
}

# release point plot
rel_plot <- function(data) {
  height_min <- 0.25 * floor(min(data$RELEASE_HEIGHT) / 0.25)
  height_max <- 0.25 * ceiling(max(data$RELEASE_HEIGHT) / 0.25)
  side_min <- 0.25 * floor(min(data$RELEASE_SIDE) / 0.25)
  side_max <- 0.25 * ceiling(max(data$RELEASE_SIDE) / 0.25)
  
  ggplot(data, aes(x = RELEASE_SIDE, y = RELEASE_HEIGHT)) +
    geom_point(aes(color = PITCH_TYPE), alpha = 0.5, size = 3) +
    scale_color_manual(name = "Pitch Type ",
                       values = c("CB" = unname(yarrr::piratepal("basel")[1]), #brewer.pal(7, "Dark2")[1],
                                  "CF" = unname(yarrr::piratepal("basel")[2]), #brewer.pal(7, "Dark2")[2],
                                  "CH" = unname(yarrr::piratepal("basel")[3]), #brewer.pal(7, "Dark2")[3],
                                  "FB" = unname(yarrr::piratepal("basel")[4]), #brewer.pal(7, "Dark2")[4],
                                  "SF" = unname(yarrr::piratepal("basel")[10]), #brewer.pal(7, "Dark2")[5],
                                  "SI" = unname(yarrr::piratepal("basel")[5]), #brewer.pal(7, "Dark2")[6],
                                  "SL" = unname(yarrr::piratepal("basel")[8])), #brewer.pal(7, "Dark2")[7]),
                       guide = guide_legend(nrow = 1)) +
    ylim(height_min, height_max) +
    xlim(side_min, side_max) +
    pitcher_theme() +
    theme(panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          legend.position = "bottom") +
    labs(title = "Release Points by Pitch Type",
         x = "Release Side",
         y = "Release Height")
}

# strike zone plot by pitch types
kzone_plot_pt <- function(data) {
  
  data$PITCH_TYPE <- as.factor(data$PITCH_TYPE)
  
  ggplot(data, aes(x = PITCH_LOCATION_SIDE, y = PITCH_LOCATION_HEIGHT)) +
    stat_density2d(aes(fill = ..level..), geom = "polygon") +
    #geom_bin2d(color = "white", binwidth = c(0.4, 0.4)) +
    geom_rect(aes(xmin = -1, xmax = 1, ymin = 1.5, ymax = 3.5), fill = NA, color = "black", size = 1.5) +
    #geom_point(alpha = 0.1) +
    scale_fill_gradientn(colors = rev(brewer.pal(9, "RdBu"))) +
    xlim(-2.5, 2.5) +
    ylim(0,5) +
    pitcher_theme() +
    theme(panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          legend.position = "None") +
    labs(title = "Pitch Location Heatmap",
         x = "Horizontal Distance from Plate (ft)",
         y = "Vertical Distance from Plate (ft)") +
    facet_wrap(vars(PITCH_TYPE))
  
}

# strike zone plot - all pitches
kzone_plot_all <- function(data) {
  
  data$PITCH_TYPE <- as.factor(data$PITCH_TYPE)
  
  ggplot(data, aes(x = PITCH_LOCATION_SIDE, y = PITCH_LOCATION_HEIGHT)) +
    stat_density2d(aes(fill = ..level..), geom = "polygon") +
    #geom_bin2d(color = "white", binwidth = c(0.4, 0.4)) +
    geom_rect(aes(xmin = -1, xmax = 1, ymin = 1.5, ymax = 3.5), fill = NA, color = "black", size = 1.5) +
    scale_fill_gradientn(colors = rev(brewer.pal(9, "RdBu"))) +
    xlim(-2.5, 2.5) +
    ylim(0,5) +
    pitcher_theme() +
    theme(panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          legend.position = "None") +
    labs(title = "Pitch Location Heatmap",
         x = "Horizontal Distance from Plate (ft)",
         y = "Vertical Distance from Plate (ft)")

}