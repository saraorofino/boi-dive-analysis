##########
# Figure S1 
# Histogram of frequency of dive sites 
##########

# Pacakges
library(tidyverse)
library(here)

source(file.path(here::here(),"common.R"))

# Final figures path 
fig_path <- file.path(project_figure_path, "final")

# Data
dives <- read_csv(file.path(project_data_path, "processed", "ais-dives", "northern_ais_dives_2016_november_2022_500m.csv"))

# Data prep
## Count number of dives at each site 
agg_site_visits <- dives %>% 
  # Use only one MPA definition to avoid double counting
  filter(mpa_definition == "Marine Reserve") %>% 
  group_by(site_id) %>% 
  summarize(n_dives = n()) %>% 
  ungroup() %>% 
  mutate(bins = case_when(n_dives == 1 ~ '1',
                          n_dives > 1 & n_dives <=3 ~ '2-3',
                          n_dives > 3 ~ "4+")) %>% 
  group_by(bins) %>% 
  mutate(sites_in_bin = n()) %>% 
  ungroup() %>% 
  mutate(frac_total = round(sites_in_bin / 1440, 2))

# Frequency plot 
frequency_plot <- ggplot(agg_site_visits) + 
  geom_bar(aes(x=bins)) + 
  geom_text(aes(x=bins, label = frac_total), 
            stat='count', vjust=1.5) + 
  scale_x_discrete(expand=c(0,0),
                   labels = c("1 dive\n(Low frequency)", "2-3 dives\n(Medium frequency)", "4-125 dives\n(High frequency)")) + 
  scale_y_continuous(expand=c(0,0)) +
  labs(x="Number of Dive Events at Site",
       y="Number of Sites") + 
  theme_bw()

# Histogram
dives_hist <- ggplot(agg_site_visits) + 
  geom_histogram(aes(x=n_dives), boundary=0, binwidth = 1) + 
  scale_x_continuous(expand=c(0,0),
                     breaks = seq(1,125,5)) + 
  scale_y_continuous(expand=c(0,0)) + 
  labs(x="Number of Dive Events at Site",
       y="Number of Sites") + 
  theme_bw() + 
  theme(strip.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        axis.title = element_text(size=8),
        axis.text = element_text(size=7),
        legend.title = element_text(size=8),
        legend.text = element_text(size=8),
        text = element_text(family = 'sans'))

# Save
ggsave(plot = dives_hist,
       filename = file.path(fig_path, "figS1.jpeg"),
       dpi = 300,
       height = 127, width = 190, units = 'mm')
