##########
# Figure 1 
# Map of Northern Channel Islands protected areas 
##########

# Pacakges
library(tidyverse)
library(here)
library(sf)
library(stringr)
library(readxl)
library(ggnewscale)

source(file.path(here::here(),"common.R"))

# Final figures path 
fig_path <- file.path(project_figure_path, "final")


# Shapefiles
ci_shp <- st_read(file.path(project_data_path, "processed", "spatial", "channel_islands.shp"))
ci_nms <- st_read(file.path(project_data_path, "processed", "spatial", "channel_islands_mpas.shp")) %>% 
  filter(mpa_id == 8688)
mpa_shp <- st_read(file.path(project_data_path, "processed", "spatial", "north_channel_islands_mpas.shp"))
ca_counties <- st_read(file.path(project_data_path, "raw", "California_County_Boundaries", "cnty19_1.shp")) %>% 
  filter(COUNTY_NAM %in% c("Santa Barbara", "Ventura") &
           is.na(ISLAND)) %>% 
  mutate(map_lab = ifelse(COUNTY_NAM == "Santa Barbara", "Santa Barbara County", 'Ventura County'))

# Harbors
harbors <- read_csv(file.path(project_data_path, "processed", "spatial", "harbors.csv"))

# Clean up data
ca_counties <- st_transform(ca_counties, crs = 4326)

northern_ci <- ci_shp %>% 
  filter(island %in% c("San Miguel", "Santa Rosa", "Santa Cruz", "Anacapa"))

mpa_types <- mpa_shp %>% 
  mutate(mpa_type = ifelse(str_detect(mpa_type, "Conservation"), "Marine Conservation Area", "Marine Reserve"))

harbors_north <- harbors %>% 
  filter(island %in% c("San Miguel", "Santa Rosa", "Santa Cruz", "Anacapa") |
           is.na(island)) %>% 
  # Remove the LA ports and Port Hueneme (won't show up on the map)
  filter(!harbor %in% c('Port Hueneme', 'Port of Los Angeles', 'Port of Long Beach')) %>% 
  # Make labels two lines 
  mutate(harbor_lab = case_when(harbor == "Santa Barbara Harbor" ~ "Santa Barbara\nHarbor",
                                harbor == "Ventura Harbor" ~ "Ventura\nHarbor",
                                harbor == "Cuyler Harbor" ~ "Cuyler\nHarbor",
                                harbor == "Prisoners Harbor" ~ "Prisoners\nHarbor",
                                harbor == "Landing Cove" ~ "Landing\nCove",
                                TRUE ~ harbor))

# Calculate MPA area 
northern_mpas <- mpa_shp %>% 
  filter(island %in% c("San Miguel", "Santa Rosa", "Santa Cruz", "Anacapa"))

# Map 
ci_map <- ggplot() + 
  geom_sf(data = ca_counties, fill = '#C9D2D3',
          color = '#B4B4B4', size = 1) +
  geom_sf(data = northern_ci, fill = '#C9D2D3',
          color = '#B4B4B4', size = 1) +
  geom_sf(data = ci_nms, aes(color=mpa_type),
          fill = NA, key_glyph = 'polygon', size = 1.5) +
  scale_color_manual(values = c('midnightblue'),
                     guide = guide_legend(order = 2),
                     name = "") +
  geom_sf_text(data = northern_ci, aes(label = island), 
               size=1, position = position_nudge(y = c(-0.005, 0, 0, -0.012),
                                                 x = c(0, 0, 0, 0.01))) + 
  geom_sf_text(data = ca_counties, aes(label = map_lab),
               size = 1, position = position_nudge(y = c(-0.27,0),
                                                   x = c(0,0))) +
  ggnewscale::new_scale_fill() + 
  ggnewscale::new_scale_color() + 
  geom_sf(data = mpa_types, aes(fill = mpa_type, color=mpa_type), 
          alpha = 0.7, key_glyph = 'polygon') + 
  scale_fill_manual(values = c('darkcyan', 'firebrick'),
                    guide = guide_legend(order = 1),
                    name = "MPA Type") +
  scale_color_manual(values = c('darkcyan', 'firebrick'),
                     guide = guide_legend(order = 1),
                     name = "MPA Type") + 
  geom_point(data = harbors_north, aes(x=lon, y=lat),
             size = 0.1, position = position_nudge(y = c(0,-0.01,0,0,0,
                                                       -0.01,0.06),
                                                 x = c(0,0.01,0.01,0,0,
                                                       0,-0.1))) +
  geom_text(data = harbors_north, aes(x=lon, y=lat, label=harbor_lab),
            size = 1, position = position_nudge(y = c(0.02,-0.01,0.015,0.005,0,
                                                       -0.028,0.042),
                                                   x = c(0.02,0.06,0.04,0.037,0.035,
                                                         0,-0.1))) +
  labs(x="",
       y="") + 
  theme_bw() + 
  theme(legend.margin=margin(0,0,0,0, unit="cm"),
        legend.position = 'bottom',
        legend.title = element_text(size=5),
        legend.text = element_text(size=5),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank()) + 
  coord_sf(ylim = c(33.79, 34.45),
           xlim = c(-120.65, -119.05))

ggsave(plot = ci_map,
       filename = file.path(fig_path, "fig1.png"),
       dpi = 600,
       height = 4, width = 6)
