##########
# Figure 4 
# Multipanel figure showing A) proportion of dive sites by MPA type in each frequency category;
# B) proportion of high frequency dives by MPA classification in each MPA definition for lobster scenario
##########

# Pacakges
library(tidyverse)
library(here)
library(DescTools)
library(patchwork)
library(cowplot)

source(file.path(here::here(), "src", "common.R"))

# Final figures path 
fig_path <- file.path(project_figure_path, "final")

# Colors
pal <- c("#E7D4AB", "#ACC2CFFF", "#678096FF")
greypal <- DescTools::ColToGray(pal) #make sure colors are distinct in greyscale 

# Data
dives <- read_csv(file.path(project_data_path, "output", "lobster_dive_events_mr.csv"))

# Results statistics for paper 
## Unique # of dives and dive sites
unique_sites <- length(unique(dives$site_id)) #249 unique sites 

## Number of sites per frequency category 
sites_per_frequency <- dives %>% 
  dplyr::select(site_id, site_frequency) %>% 
  distinct() %>% 
  group_by(site_frequency) %>% 
  count() # 79 high, 75 medium, 95 low 

## Number of outside MPA sites per frequency category 
outside_mpa_sites <- dives %>% 
  dplyr::select(site_id, site_frequency, site_category) %>% 
  distinct() %>% 
  group_by(site_frequency) %>% 
  mutate(total_sites = n()) %>% 
  ungroup() %>% 
  filter(site_category == 'outside_mpa') %>% 
  group_by(site_frequency, total_sites) %>% 
  summarize(sites_outside_mpas = n()) %>% 
  ungroup() %>% 
  mutate(frac_outside = sites_outside_mpas / total_sites)

## High frequency sites in MPAs
mpa_sites <- dives %>% 
  filter(site_frequency == 'high') %>% 
  dplyr::select(site_id, site_frequency, site_category) %>% 
  distinct() %>% 
  group_by(site_frequency) %>% 
  mutate(total_sites = n()) %>% 
  ungroup() %>% 
  group_by(site_frequency, total_sites, site_category) %>% 
  summarize(n_sites = n()) %>% 
  ungroup() %>% 
  mutate(frac_sites = n_sites / total_sites)

## Average frequency of dives by site catgory 
avg_dives_category <- dives %>%  
  group_by(year) %>% 
  mutate(annual_dives = n()) %>% 
  ungroup() %>% 
  group_by(year, site_category, annual_dives) %>% 
  summarize(n_dives_category = n()) %>% 
  ungroup() %>% 
  bind_rows(data.frame(year=c(2020, 2020),
                       site_category=c('in_mpa', 'in_buffer'),
                       annual_dives=c(17,17),
                       n_dives_category=c(0,0))) %>% 
  mutate(frac_dives = n_dives_category / annual_dives) %>% 
  group_by(site_category) %>% 
  summarize(n_dives = sum(n_dives_category),
            avg_frac = mean(frac_dives)) %>% 
  ungroup()

# A: Proportion of dive sites by frequency and MPA category
site_mpa_frequency <- dives %>% 
  dplyr::select(site_id, site_category, site_frequency) %>% 
  distinct() %>% 
  group_by(site_frequency) %>% 
  mutate(total_sites_in_frequency = n()) %>% 
  ungroup() %>% 
  group_by(site_frequency, site_category, total_sites_in_frequency) %>% 
  count() %>% 
  mutate(prop_category = n / total_sites_in_frequency) %>% 
  mutate(site_category = factor(site_category, levels = c("outside_mpa", "in_buffer", "in_mpa")))

site_mpa_plot <- ggplot(site_mpa_frequency) + 
  geom_col(aes(x=factor(site_frequency, levels = c('low', 'medium', 'high')), y=prop_category, fill=site_category)) + 
  scale_x_discrete(expand = c(0,0),
                   labels = c("Low", "Medium", "High")) + 
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,1)) + 
  scale_fill_manual(values = pal,
                    labels = c("Outside MPA", "In Buffer", "In MPA")) + 
  labs(x="Site Frequency",
       y="Proportion of Dive Sites",
       fill = "Site Category") + 
  plot_theme() 

# B: proportion of dives by MPA category and year  
dives_mpa_frequency <- dives %>%  
  group_by(year) %>% 
  mutate(annual_dives = n()) %>% 
  ungroup() %>% 
  group_by(year, site_category, annual_dives) %>% 
  summarize(n_dives = n()) %>% 
  ungroup() %>% 
  mutate(prop_dives = n_dives / annual_dives) %>% 
  mutate(site_category = factor(site_category, levels = c("outside_mpa", "in_buffer", "in_mpa")))

dive_mpa_plot <- ggplot(dives_mpa_frequency) + 
  geom_col(aes(x=year, y=prop_dives, fill=site_category)) +
  scale_x_continuous(expand = c(0,0),
                     breaks = seq(2016,2022,2)) + 
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,1)) + 
  scale_fill_manual(values = pal,
                    labels = c("Outside MPA", "In Buffer", "In MPA")) + 
  labs(x="Year",
       y="Proportion of Dive Events",
       fill = "Site Category") + 
  plot_theme()

# Combine and save 
figure_4 <- site_mpa_plot + labs(tag='A') + dive_mpa_plot + labs(tag='B') +
  plot_layout(nrow=1, guides = 'collect') & theme(legend.position = 'bottom')

save_plot(plot = figure_4,
          filename = file.path(fig_path, "fig4.jpeg"),
          dpi = 300,
          base_height = 127, base_width = 190, units = "mm")

save_plot(plot = figure_4,
          filename = file.path(fig_path, "fig4.pdf"),
          dpi = 300,
          base_height = 127, base_width = 190, units = "mm")
