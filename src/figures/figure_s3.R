##########
# Figure S3 
# Percentage of scuba lobster catch by month 
##########

# Pacakges
library(tidyverse)
library(here)
library(readxl)

source(file.path(here::here(), "src", "common.R"))

# Final figures path 
fig_path <- file.path(project_figure_path, "final")

# Data 
sheet_names <- c("2015-2016", "2016-2017", "2017-2018", "2018-2019",
                 "2019-2020", "2020-2021", "2021-2022")

lobster_catch <- NULL
for(i in 1:length(sheet_names)){
  lobster_catch <- lobster_catch %>% 
    bind_rows(read_xlsx(file.path(project_data_path, "raw", "SCUBA_LOB_BY_SEASON.xlsx"),
                        sheet=sheet_names[i]))
}

# Data prep
## Define lobster season dates 
lobster_season <- data.frame(start_year = c(2015:2022),
                             start_date = c('2015-10-03', '2016-10-01', '2017-09-30', '2018-09-29', 
                                            '2019-09-28', '2020-10-03', '2021-10-02', '2022-10-01'),
                             end_year = c(2015:2022),
                             end_date = c('2015-12-31', '2016-03-16', '2017-03-15', '2018-03-21',  
                                          '2019-03-20', '2020-03-18', '2021-03-17', '2022-03-16'))

## Percent catch by month 
## Keep only data from within the exact dates of lobster season 
percent_catch <- lobster_catch %>% 
  mutate(date = lubridate::as_date(paste(Month, Day, Year, sep = "-"), format = "%m-%d-%Y")) %>% 
  left_join(lobster_season %>%
              dplyr::select(start_year, start_date), by = c('Year' = 'start_year')) %>%
  left_join(lobster_season %>%
              dplyr::select(end_year, end_date), by = c('Year' = 'end_year')) %>%
  # Keep January 1st to end date and start date through December 31
  filter(date >= start_date | date <= end_date) %>% 
  group_by(Month) %>% 
  summarize(montly_catch = sum(TotalLob)) %>% 
  ungroup() %>% 
  mutate(total_catch = sum(.$montly_catch),
         percent_catch = round((montly_catch/total_catch) * 100, 1))


# Plot 
percent_catch_plot <- ggplot(percent_catch) + 
  geom_col(aes(x=Month, y=percent_catch)) + 
  scale_x_continuous(expand = c(0,0),
                     breaks = seq(1,12,1)) + 
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,50.3),
                     breaks = seq(0,50,10)) + 
  labs(x="Month",
       y="Percentage of lobster catch") + 
  plot_theme()

# Save
ggsave(plot = percent_catch_plot,
       filename = file.path(fig_path, "figS3.jpeg"),
       dpi = 300,
       height = 127, width = 190, units = 'mm')
