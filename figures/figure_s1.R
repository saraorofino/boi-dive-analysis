##########
# Figure S1 
# Heat map of possible dive sites with Channel Islands 1 nm boundary 
##########

# Pacakges
library(tidyverse)
library(here)
library(sf)
library(colorspace)

source(file.path(here::here(),"common.R"))

# Final figures path 
fig_path <- file.path(project_figure_path, "final")

# Shapefiles
ci_shp <- st_read(file.path(project_data_path, "processed", "spatial", "channel_islands.shp"))
ci_1nm <- st_read(file.path(project_data_path, "raw", "data_EPSG_4326", "CI_1nm.shp"))

# Data 
dive_sites <- read_csv(file.path(project_data_path, "processed", "dive_sites_1hr30min_1vessel_labeled.csv"))

# Northern CI 
northern_ci <- ci_shp %>% 
  filter(island %in% c("San Miguel", "Santa Rosa", "Santa Cruz", "Anacapa"))

northern_dive_sites <- dive_sites %>% 
  filter(nearest_island %in% c("San Miguel", "Santa Rosa", "Santa Cruz", "Anacapa"))

# Aggregate grid size up to 100th degree 
sites_100th <- northern_dive_sites %>% 
  mutate(lat_bin = floor(lat_bin * 100) / 100,
         lon_bin = floor(lon_bin * 100) / 100) %>% 
  group_by(lat_bin, lon_bin) %>% 
  summarize(n_sites = n()) %>% 
  ungroup() %>% 
  mutate(n_sites_per_km2 = n_sites / 1.23)


# Map 
site_map <- ggplot() + 
  geom_tile(data = sites_100th, aes(x=lon_bin, y=lat_bin, fill=n_sites_per_km2)) + 
  geom_sf(data = ci_1nm, color = '#B4B4B4',
          fill = NA, size = 1) +
  geom_sf(data = northern_ci, fill = '#C9D2D3', 
          color = '#B4B4B4', size = 1) + 
  geom_sf_text(data = northern_ci, aes(label = island), 
               size=2, position = position_nudge(y = c(-0.005, 0, 0, 0.015),
                                                 x = c(0, 0, 0, 0))) + 
  scale_fill_continuous_sequential(palette = 'Heat',
                                   limits = c(0.8, 11.4),
                                   breaks = c(0.8, 11.4),
                                   labels = c("Low", "High"),
                                   oob = scales::squish) + 
  labs(fill="Dive Site Density",
       x="", 
       y="") + 
  theme_bw() + 
  theme(legend.margin=margin(0,0,0,0, unit="cm"),
        legend.position = 'bottom',
        legend.title = element_text(size=6),
        legend.text = element_text(size=6),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank()) + 
  coord_sf(ylim = c(33.87, 34.13),
           xlim = c(-120.5, -119.36))

ggsave(plot = site_map,
       filename = file.path(fig_path, "figs1.png"),
       dpi = 600,
       height = 4, width = 6)
