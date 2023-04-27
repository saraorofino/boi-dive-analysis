##########
# Figure 2 
# Multipanel showing A) proportion of dive sites by MPA type in each frequency category;
# B) proportion of high frequency dives by MPA classification in each MPA definition for ecotourism scenario
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
dives <- read_csv(file.path(project_data_path, "processed", "ais-dives", "subset_north_max5hr_daytime_500m.csv"))

# Subset for ecotourism scenario 2: all dives except those during lobster season in October 
## Define lobster season
lobster_season <- data.frame(start_year = c(2016:2022),
                             start_date = c('2016-10-01', '2017-09-30', '2018-09-29', '2019-09-28',
                                            '2020-10-03', '2021-10-02', '2022-10-01'),
                             end_year = c(2016:2022),
                             end_date = c('2016-03-16', '2017-03-15', '2018-03-21', '2019-03-20', 
                                          '2020-03-18', '2021-03-17', '2022-03-16'))

## Subset
eco_sub <- dives %>% 
  left_join(lobster_season %>% 
              dplyr::select(start_year, start_date), by = c('year' = 'start_year')) %>%
  mutate(end_date = paste(year, "10", "31", sep = "-")) %>% 
  # label which days to remove 
  mutate(rm = case_when(year %in% c(2020, 2021, 2022) & date >= start_date & date <= end_date ~ "yes",
                        year %in% c(2016,2017,2018,2019) & month == 10 ~ "yes",
                        TRUE ~ "no")) %>% 
  filter(rm == 'no') %>% 
  dplyr::select(-start_date, -end_date, -rm)

# Results statistics for paper 
## Unique # of dives and dive sites
unique_dives <- nrow(eco_sub)/2 #3014 unique dives (rows are duplicated for each of the 2 mpa definitions)
unique_sites <- eco_sub %>% 
  filter(mpa_definition != "Marine Reserve") %>% 
  dplyr::select(site_id) %>% 
  distinct() #807 unique sites 

## Number of sites per frequency category 
sites_per_frequency <- eco_sub %>% 
  dplyr::select(site_id, site_frequency) %>% 
  distinct() %>% 
  group_by(site_frequency) %>% 
  count() # 219 high, 231 medium, 357 low 

## Number of MPA sites per frequency category 
mpa_sites <- eco_sub %>% 
  filter(mpa_definition != "Marine Reserve") %>% 
  dplyr::select(site_id, site_frequency, site_category) %>% 
  distinct() %>% 
  group_by(site_frequency) %>% 
  mutate(total_sites = n()) %>% 
  ungroup() %>% 
  filter(site_category == 'in_mpa') %>% 
  group_by(site_frequency, total_sites) %>% 
  summarize(sites_in_mpas = n()) %>% 
  ungroup() %>% 
  mutate(frac_mpa = sites_in_mpas / total_sites)

## Average number of dives by site category 
avg_dives_category <- eco_sub %>% 
  filter(mpa_definition != 'Marine Reserve') %>% 
  group_by(year) %>% 
  mutate(annual_dives = n()) %>% 
  ungroup() %>% 
  group_by(year, annual_dives, site_category) %>% 
  summarize(n_dives_category = n()) %>% 
  ungroup() %>% 
  mutate(frac_dives = n_dives_category / annual_dives) %>% 
  group_by(site_category) %>% 
  summarize(avg_fraction = mean(frac_dives),
            total_dives_category = sum(n_dives_category)) %>% 
  ungroup()

# A: Proportion of dive sites by frequency and MPA category
site_mpa_frequency <- eco_sub %>% 
  dplyr::select(mpa_definition, site_id, site_category, site_frequency) %>% 
  distinct() %>% 
  group_by(mpa_definition, site_frequency) %>% 
  mutate(total_sites_in_frequency = n()) %>% 
  ungroup() %>% 
  group_by(mpa_definition, site_frequency, site_category, total_sites_in_frequency) %>% 
  count() %>% 
  mutate(prop_category = n / total_sites_in_frequency) %>% 
  # Keep only combined MR and MCA for updated figure 
  filter(mpa_definition == 'Marine Reserves & Conservation Areas')

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
       fill = "Site Category") + 
  theme_bw() + 
  #facet_wrap(~mpa_definition) + 
  theme(strip.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        axis.title = element_text(size=10),
        axis.text = element_text(size=7),
        legend.position = "bottom",
        legend.title = element_text(size=9),
        legend.text = element_text(size=9))  

# B: Proportion of dives by MPA category and year   
dives_mpa_frequency <- eco_sub %>% 
  group_by(mpa_definition, year) %>% 
  mutate(annual_dives = n()) %>% 
  ungroup() %>% 
  group_by(mpa_definition, year, site_category, annual_dives) %>% 
  summarize(n_dives = n()) %>% 
  ungroup() %>% 
  mutate(prop_dives = n_dives / annual_dives) %>% 
  # Keep only combined MR and MCA for updated figure
  filter(mpa_definition == 'Marine Reserves & Conservation Areas')

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
  #facet_wrap(~mpa_definition) + 
  theme(strip.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        legend.position = 'bottom',
        axis.title = element_text(size=10),
        axis.text = element_text(size=7),
        legend.title = element_text(size=9),
        legend.text = element_text(size=9))

# Combine and save 
figure_2 <- site_mpa_plot + labs(tag='A') + dive_mpa_plot + labs(tag='B') +
  plot_layout(nrow=1, guides = 'collect') & theme(legend.position = 'bottom')

save_plot(plot = figure_2,
          filename = file.path(fig_path, "fig2.png"),
          dpi = 600,
          base_height = 4, base_width = 6)
