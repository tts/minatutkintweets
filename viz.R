library(tidyverse)
library(lubridate)
library(patchwork)

source("utils.R")

kw <- read_csv("kw_data_labels_3_date.csv")
ts <- read_csv("terms_groups_all_3.csv")
g <- read_csv("groups_fi.csv")

to_viz <- inner_join(kw, ts, by = c("uri"="uri")) %>% 
  select(!ends_with(".y")) %>% 
  rename(text = text.x,
         label = label.x) %>% 
  filter(!label %in% c("Suomi", "tutkimus", "artikkelit (julkaisut)", "minä", "research", "tiede",
                       "Finland", "tutkijat", "kehittäminen", "tutkimusryhmät", "tutkimustoiminta", 
                       "tutkimustyö", "väitöskirjat"))
rm(kw)
rm(ts)
gc()

# Only Finnish group names
to_viz_g <- right_join(to_viz, g, by = c("group"="gl"))

write_csv(to_viz_g, "all_data_with_fi_groups_3.csv")

rm(to_viz)
gc()

# Trim, clean, and group
to_viz <- to_viz_g %>%
  mutate(group = gsub("[0-9]*", "", group)) %>%
  mutate(group = trimws(str_extract(group, "^[^.]+"))) %>%
  mutate(day = day(created_at)) %>%
  group_by(day, group) %>%
  summarise(n = n()) %>% 
  ungroup() %>% 
  filter(!is.na(day))

write_csv(to_viz, "day_group_n.csv")

rm(to_viz_g)
gc()

# Just a copy
viz <- to_viz

# https://stackoverflow.com/a/53598064
viz <- arrange(viz, day, n) %>% 
  filter(n >= 150) %>% # note: graph coloring breaks when aux size > 35
  mutate(group = factor(group)) 

aux <- with(viz, match(sort(unique(group)), group))
q_colors <- length(aux) 
v_colors <- viridis::viridis(q_colors, option = "cividis", begin = 0.25, end = 0.95)

# Modified from https://github.com/gkaramanis/tidytuesday/blob/master/2021/2021-week37/billboard.R
ggplot(data = viz, aes(x = day, y = n, fill = interaction(n, day))) +
  geom_bar(stat = "identity", position = "fill", width = 1) +
  geom_text(aes(label = group), size = 4,
            position = position_fill(vjust = 0.5), check_overlap = TRUE, color = "grey10") +
  scale_fill_manual("Ryhmä", 
                    values = v_colors[viz$group],
                    labels = with(viz, group[aux]), 
                    breaks = with(viz, interaction(n, day)[aux])) +
  scale_size_continuous(range = c(2, 5)) +
  scale_x_continuous(breaks = seq(6, 12, 1)) +
  coord_cartesian(expand = FALSE, clip = "off") +
  labs(
    title = "#minätutkin 6-12.9.2021",
    subtitle = "Aiheryhmien suhteellinen osuus päivittäin (n >= 150)",
    caption = "Lähteet: Twitter, Finto AI, Finto API. Grafiikka @ttso, alkuperäinen: @geokaramanis"
  ) +
  theme_void() + do_theme()

ggsave(
  "minatutkintweets.png",
  width = 35, 
  height = 25, 
  dpi = 300, 
  units = "cm", 
  device = 'png'
)

