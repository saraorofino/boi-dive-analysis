##########
# Figure S2 
# Reported lobster catch by season 
##########

# Pacakges
library(tidyverse)
library(readxl)
library(here)

source(file.path(here::here(),"common.R"))

# Final figures path 
fig_path <- file.path(project_figure_path, "final")

# Data
lobster <- read_xlsx(file.path(project_data_path, "raw", "SEASON_LOBSTER(FIXED).xlsx"),
                     sheet = "Sheet1")

# Data prep
## Clean up lobster totals by season
lobster_clean <- lobster[, c(9,11)] %>% 
  filter(!is.na(Season)) %>% 
  dplyr::select(season = Season, total_lobster = `TOTAL_LOB_SD...11`)

# Plot
lobster_plot <- ggplot(lobster_clean) + 
  geom_col(aes(x=season, y=total_lobster)) + 
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,25000),
                     breaks = seq(0,25000,5000)) + 
  scale_x_discrete(expand = c(0,0)) + 
  labs(x="Season",
       y="Reported Lobster Catch (count)") + 
  theme_bw() + 
  theme(strip.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        axis.title = element_text(size=8),
        axis.text = element_text(size=8),
        legend.title = element_text(size=8),
        legend.text = element_text(size=8),
        text = element_text(family = 'sans'))

# Save
ggsave(plot = lobster_plot,
       filename = file.path(fig_path, "figS2.jpeg"),
       dpi = 300,
       height = 127, width = 190, units = 'mm')
