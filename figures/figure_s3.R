##########
# Figure S3 
# Percentage of scuba lobster catch by month 
##########

# Pacakges
library(tidyverse)
library(here)

source(file.path(here::here(),"common.R"))

# Final figures path 
fig_path <- file.path(project_figure_path, "final")

# Data 
lobster_catch <- read_csv(file.path(project_data_path, "raw", "Mladjov_recreational_lobster_summary_230214.csv"))

# Data prep
## Define lobster season dates 
lobster_season <- data.frame(start_year = c(2016:2022),
                             start_date = c('2016-10-01', '2017-09-30', '2018-09-29', '2019-09-28',
                                            '2020-10-03', '2021-10-02', '2022-10-01'),
                             end_year = c(2016:2022),
                             end_date = c('2016-03-16', '2017-03-15', '2018-03-21', '2019-03-20', 
                                          '2020-03-18', '2021-03-17', '2022-03-16'))

## Percent of lobster catch by month
## Keep only catch from within the season 
percent_catch <- lobster_catch %>% 
  filter(GearType == 'scuba') %>% 
  mutate(date = lubridate::as_date(paste(Month, Day, Year, sep = "-"), format = "%m-%d-%Y")) %>% 
  filter(!is.na(Month)) %>% 
  left_join(lobster_season %>% 
              dplyr::select(start_year, start_date), by = c('Year' = 'start_year')) %>% 
  left_join(lobster_season %>% 
              dplyr::select(end_year, end_date), by = c('Year' = 'end_year')) %>% 
  # Keep January 1st to end date and start date through December 31
  filter(date >= start_date | date <= end_date) %>% 
  group_by(Month) %>% 
  summarize(monthly_catch = sum(TotalLob, na.rm=T)) %>% 
  ungroup() %>% 
  filter(!is.na(Month)) %>% 
  mutate(total_catch = sum(.$monthly_catch),
         percent_catch = (monthly_catch/total_catch) * 100)

# Plot 
percent_catch_plot <- ggplot(percent_catch) + 
  geom_col(aes(x=Month, y=percent_catch)) + 
  scale_x_continuous(expand = c(0,0),
                     breaks = seq(1,12,1)) + 
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,50),
                     breaks = seq(0,50,10)) + 
  labs(x="Month",
       y="Percentage of lobster catch") + 
  theme_bw() + 
  theme(strip.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        axis.title = element_text(size=8),
        axis.text = element_text(size=8),
        legend.title = element_text(size=8),
        legend.text = element_text(size=8),
        text = element_text(family = 'sans'))

# Save
ggsave(plot = percent_catch_plot,
       filename = file.path(fig_path, "figS3.jpeg"),
       dpi = 300,
       height = 127, width = 190, units = 'mm')
