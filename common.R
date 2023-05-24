# A script to be sourced at the beginning of each working script to load working paths

##########
# File paths 
##########

# Working paths
sys_path <- ifelse(Sys.info()["sysname"]=="Windows", "G:/My Drive/", "~/Google Drive/My Drive/")
# Path to this project's folder
project_path <- paste0(sys_path,"emLab/Projects/boi-dive-project")
#Path to project's data folder
project_data_path <- file.path(project_path,"data")
# Path to project's output table folder
project_table_path <- file.path(project_path, "tables")
# Path to project's output figure folder
project_figure_path <- file.path(project_path, "figures")

##########
# Themes
##########

# Plot theme : matching specifications for Marine Policy figures 
plot_theme <- function(base_family = "sans"){
  
  theme_bw(base_family = base_family) %+replace%
    theme(strip.background = element_rect(fill = "white"),
          panel.grid = element_blank(),
          axis.title = element_text(size=8),
          axis.text = element_text(size=8),
          legend.title = element_text(size=8),
          legend.text = element_text(size=8),
          legend.position = "bottom",
          text = element_text(family = 'sans'))
}

# Map theme: matching specifications for Marine Policy figures
map_theme <- function(base_family = 'sans'){
  
  theme_bw(base_family = base_family) %+replace%
    theme(legend.margin=margin(0,0,0,0, unit="cm"),
          legend.position = 'bottom',
          legend.direction = 'horizontal',
          legend.title = element_text(size=7, family='sans'),
          legend.text = element_text(size=7, family='sans'),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          panel.grid = element_blank(),
          text = element_text(family = "sans"))
}
