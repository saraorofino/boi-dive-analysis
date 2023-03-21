##########
# Figure 4 
# Multipanel figure showing A) proportion of dive sites by MPA type in each frequency category;
# B) proportion of high frequency dives by MPA classification in each MPA definition for lobster scenario
##########

# Pacakges
library(tidyverse)
library(here)
library(patchwork)
library(cowplot)

source(file.path(here::here(),"common.R"))

# Final figures path 
fig_path <- file.path(project_figure_path, "final")

# Data
dives <- read_csv(file.path(project_data_path, "processed", "ais-dives", "all_ais_dives_2016_november_2022_500m.csv"))

# Subset for lobster scenario 3: dives during lobster season occuring at night or overnight 
## Define lobster season
lobster_season <- data.frame(start_year = c(2016:2022),
                             start_date = c('2016-10-01', '2017-09-30', '2018-09-29', '2019-09-28',
                                            '2020-10-03', '2021-10-02', '2022-10-01'),
                             end_year = c(2016:2022),
                             end_date = c('2016-03-16', '2017-03-15', '2018-03-21', '2019-03-20', 
                                          '2020-03-18', '2021-03-17', '2022-03-16'))

## Subset 
lobster_sub <- dives %>% 
  filter(island_group == 'Northern') %>% 
  left_join(lobster_season %>% 
              dplyr::select(start_year, start_date), by = c('year' = 'start_year')) %>% 
  left_join(lobster_season %>% 
              dplyr::select(end_year, end_date), by = c('year' = 'end_year')) %>% 
  # Keep January 1st to end date and start date through December 31
  filter(date >= start_date | date <= end_date) %>% 
  filter(time_of_day %in% c("night", "overnight"))

# Results statistics for paper 
## Unique # of dives and dive sites
unique_dives <- nrow(lobster_sub)/2 #346 unique dives (rows are duplicated for each of the 2 mpa definitions)
unique_sites <- lobster_sub %>% 
  filter(mpa_definition == "Marine Reserve") %>% 
  dplyr::select(site_id) %>% 
  distinct() #249 unique sites 

## Number of sites per frequency category 
sites_per_frequency <- lobster_sub %>% 
  dplyr::select(site_id, site_frequency) %>% 
  distinct() %>% 
  group_by(site_frequency) %>% 
  count() # 79 high, 75 medium, 95 low 

## Number of dives on at high frequency sites per year
annual_dives_high <- lobster_sub %>% 
  filter(mpa_definition == 'Marine Reserve') %>% 
  group_by(year) %>% 
  mutate(annual_dives = n()) %>% 
  ungroup() %>% 
  group_by(year, annual_dives, site_frequency) %>% 
  summarize(n_dives = n()) %>% 
  ungroup() %>% 
  mutate(prop_dives = n_dives / annual_dives) #27-56% by year

## Average number of dives at high frequency sites 2016-2022
avg_dives_high <- lobster_sub %>% 
  filter(mpa_definition == 'Marine Reserve') %>% 
  group_by(site_frequency) %>% 
  summarize(n_dives = n()) %>% 
  ungroup() %>% 
  mutate(prop_dives = n_dives / 346)

## Average frequency of high frequency dives in MPAs 
avg_dives_high_mpas <- lobster_sub %>% 
  filter(site_frequency == "high") %>% 
  group_by(mpa_definition, year) %>% 
  mutate(total_dives_year = n()) %>% 
  ungroup() %>% 
  group_by(mpa_definition, year, site_category, total_dives_year) %>% 
  summarize(n_dives = n()) %>% 
  ungroup() %>% 
  mutate(prop_dives = n_dives / total_dives_year) %>% 
  filter(site_category == 'in_mpa') %>% 
  # Add in years that were zero 
  bind_rows(data.frame(mpa_definition = c("Marine Reserve", "Marine Reserve", "Marine Reserve", 
                                          "Marine Reserves & Conservation Areas", "Marine Reserves & Conservation Areas"),
                       year = c(2020, 2021, 2022,
                                2020, 2021),
                       site_category = rep("in_mpa", 5),
                       total_dives_year = c(7, 6, 17,
                                            7, 6),
                       n_dives = rep(0,5),
                       prop_dives = rep(0,5))) %>% 
  group_by(mpa_definition) %>% 
  summarize(avg_prop = mean(prop_dives)) %>% 
  ungroup()

# A: Proportion of dive sites by frequency and MPA category
site_mpa_frequency <- lobster_sub %>% 
  dplyr::select(mpa_definition, site_id, site_category, site_frequency) %>% 
  distinct() %>% 
  group_by(mpa_definition, site_frequency) %>% 
  mutate(total_sites_in_frequency = n()) %>% 
  ungroup() %>% 
  group_by(mpa_definition, site_frequency, site_category, total_sites_in_frequency) %>% 
  count() %>% 
  mutate(prop_category = n / total_sites_in_frequency)

site_mpa_plot <- ggplot(site_mpa_frequency) + 
  geom_col(aes(x=factor(site_frequency, levels = c('low', 'medium', 'high')), y=prop_category, fill=site_category)) + 
  scale_x_discrete(expand = c(0,0),
                   labels = c("Low", "Medium", "High")) + 
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,1)) + 
  scale_fill_manual(values = c("#F4E7C5FF", "#979461FF", "#CD5733FF"),
                    labels = c("In Buffer", "In MPA", "Outside MPA")) + 
  labs(x="Site Frequency",
       y="Proportion of Dive Sites",
       fill = "") + 
  theme_bw() + 
  facet_wrap(~mpa_definition) + 
  theme(strip.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        legend.position = "none") # one legend only 

# B: proportion of high frequency dives by MPA category and year  
dives_mpa_frequency <- lobster_sub %>% 
  filter(site_frequency == "high") %>% 
  group_by(mpa_definition, year) %>% 
  mutate(total_dives_year = n()) %>% 
  ungroup() %>% 
  group_by(mpa_definition, year, site_category, total_dives_year) %>% 
  summarize(n_dives = n()) %>% 
  ungroup() %>% 
  mutate(prop_dives = n_dives / total_dives_year)

dive_mpa_plot <- ggplot(dives_mpa_frequency) + 
  geom_col(aes(x=year, y=prop_dives, fill=site_category)) +
  scale_x_continuous(expand = c(0,0),
                     breaks = seq(2016,2022,2)) + 
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,1)) + 
  scale_fill_manual(values = c("#F4E7C5FF", "#979461FF", "#CD5733FF"),
                    labels = c("In Buffer", "In MPA", "Outside MPA")) + 
  labs(x="Year",
       y="Proportion of Dives",
       fill = "Site Category") + 
  theme_bw() + 
  facet_wrap(~mpa_definition) + 
  theme(strip.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        legend.position = 'bottom')

# Combine and save 
figure_4 <- site_mpa_plot + labs(tag='A') + dive_mpa_plot + labs(tag='B') +
  plot_layout(ncol=1)

save_plot(plot = figure_4,
          filename = file.path(fig_path, "fig4.png"),
          dpi = 600,
          base_height = 6, base_width = 6)
