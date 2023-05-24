##########
# Figure S5 
# Number of dives per year 2016-2022
##########

# Pacakges
library(tidyverse)
library(here)

source(file.path(here::here(), "src", "common.R"))

# Final figures path 
fig_path <- file.path(project_figure_path, "final")

# Data
dives <- read_csv(file.path(project_data_path, "processed", "ais-dives", "northern_ais_dives_2016_november_2022_500m.csv"))

# Data prep
## Number of dives per year
annual_dives <- dives %>% 
  filter(mpa_definition == "Marine Reserve") %>% 
  group_by(year) %>% 
  summarize(n_dives = n()) %>% 
  ungroup()

# Plot
annual_dive_plot <- ggplot(annual_dives) + 
  geom_line(aes(x=year, y=n_dives)) +
  scale_x_continuous(expand = c(0,0.05),
                     breaks = seq(2016,2022,1)) + 
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,1200),
                     breaks = seq(0,1200,400)) + 
  labs(x="Year",
       y="Number of Dive Events") + 
  plot_theme()


# Save
ggsave(plot = annual_dive_plot,
       filename = file.path(fig_path, "figS5.jpeg"),
       dpi = 300,
       height = 127, width = 190, units = 'mm')
