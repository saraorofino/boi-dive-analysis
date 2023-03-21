##########
# Figure 1 
# Map of Northern Channel Islands protected areas 
##########

# Pacakges
library(tidyverse)
library(here)
library(sf)
library(stringr)

source(file.path(here::here(),"common.R"))

# Final figures path 
fig_path <- file.path(project_figure_path, "final")


# Shapefiles
ci_shp <- st_read(file.path(project_data_path, "processed", "spatial", "channel_islands.shp"))
ci_nms <- st_read(file.path(project_data_path, "processed", "spatial", "channel_islands_mpas.shp")) %>% 
  filter(mpa_id == 8688)
mpa_shp <- st_read(file.path(project_data_path, "processed", "spatial", "north_channel_islands_mpas.shp"))

# Clean up data
northern_ci <- ci_shp %>% 
  filter(island %in% c("San Miguel", "Santa Rosa", "Santa Cruz", "Anacapa"))

mpa_types <- mpa_shp %>% 
  mutate(mpa_type = ifelse(str_detect(mpa_type, "Conservation"), "Marine Conservation Area", "Marine Reserve"))


# Map 
ci_map <- ggplot() + 
  geom_sf(data = ci_nms, aes(color=mpa_type),
          fill = NA, key_glyph = 'polygon', size = 1) +
  scale_color_manual(values = c('midnightblue'),
                     guide = guide_legend(order = 2),
                     name = "") +
  geom_sf(data = northern_ci, fill = '#C9D2D3', 
          color = '#B4B4B4', size = 1) + 
  geom_sf_text(data = northern_ci, aes(label = island), 
               size=2, position = position_nudge(y = c(-0.005, 0, 0, -0.012),
                                                 x = c(0, 0, 0, 0.04))) + 
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
  labs(x="",
       y="") + 
  theme_bw() + 
  theme(legend.margin=margin(0,0,0,0, unit="cm"),
        legend.position = 'bottom',
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank()) + 
  coord_sf(ylim = c(33.79, 34.21),
           xlim = c(-120.61, -119.29))

ggsave(plot = ci_map,
       filename = file.path(fig_path, "fig1.png"),
       dpi = 600,
       height = 4, width = 6)
