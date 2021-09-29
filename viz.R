library(tidyverse)
library(lubridate)

kw <- read_csv("kw_data_labels_3_date.csv")
ts <- read_csv("terms_groups_all_3.csv")
g <- read_csv("groups_fi.csv")

to_viz <- inner_join(kw, ts, by = c("uri"="uri")) %>% 
  select(!ends_with(".y")) %>% 
  rename(text = text.x,
         label = label.x) %>% 
  filter(!label %in% c("Suomi", "tutkimus", "artikkelit (julkaisut)", "minä", "research", "tiede",
                       "Finland", "tutkijat", "kehittäminen", "tutkimusmenetelmät", "menetelmät",
                       "tutkimusryhmät", "tutkimustoiminta", "tutkimustyö", "Twitter", "väitöskirjat",
                       "vaikutukset", "vaikuttavuus", "vaikuttaminen", "tiedeviestintä", "merkitys (tärkeys)", 
                       "sosiaalinen media")) 

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
  ungroup()

rm(to_viz_g)
gc()

# Just a copy
viz <- to_viz

# https://stackoverflow.com/a/53598064
viz <- arrange(viz, day, n) %>% 
  filter(n >= 400) %>% # graph coloring breaks when aux size > 30
  mutate(group = factor(group)) 

aux <- with(viz, match(sort(unique(group)), group))

q_colors =  length(aux) 
v_colors =  viridis::viridis(q_colors, option = "turbo", begin = 0.05, end = 0.95)

# Modified from https://github.com/gkaramanis/tidytuesday/blob/master/2021/2021-week37/billboard.R
g <- ggplot(data = viz, aes(x = day, y = n, fill = interaction(n, day))) +
  geom_bar(stat = "identity", position = "fill", width = 1) +
  geom_text(aes(label = group, size = n), position = position_fill(vjust = 0.5), check_overlap = TRUE, color = "grey10") +
  scale_fill_manual("Ryhmä", 
                    values = v_colors[viz$group],
                    labels = with(to_viz, group[aux]), 
                    breaks = with(to_viz, interaction(n, day)[aux])) +
  scale_size_continuous(range = c(1, 5)) +
  scale_x_continuous(breaks = seq(6, 12, 1)) +
  coord_cartesian(expand = FALSE, clip = "off") +
  labs(
    title = "#minätutkin 6-11.9.2021",
    subtitle = "Ryhmän suhteellinen osuus päivittäin (n > 400)",
    caption = "Lähteet: Twitter, Finto AI, Finto API"
  ) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "grey10", color = NA),
    axis.text.x = element_text(size = 20, face = "bold", margin = margin(10, 0, 0, 0), color = "grey97"),
    plot.margin = margin(20, 5, 20, 5),
    plot.title = element_text(face = "bold", size = 30, color = "grey97"),
    plot.subtitle = element_text(size = 18, margin = margin(5, 0, 10, 0), color = "grey97"),
    plot.caption = element_text(size = 8, margin = margin(10, 0, 0, 0), color = "grey97")
  )
g
ggsave("minatutkin.pdf", width = 10.2, height = 6.5, device = cairo_pdf)

# Day 12 separately because then, no n > 400
viz <- to_viz

viz <- to_viz %>% 
  filter(day == 12)

# Note: just in alphabetical order by group
g <- ggplot(data = viz, aes(x = day, y = n, fill = group)) +
  geom_bar(stat = "identity", position = "fill", width = 1) +
  geom_text(aes(label = group, size = n), position = position_fill(vjust = 0.5), check_overlap = TRUE, color = "grey10") +
  scale_fill_viridis_d(option = "turbo", begin = 0.05, end = 0.95) +
  scale_size_continuous(range = c(1, 5)) +
  scale_x_continuous(breaks = seq(6, 12, 1)) +
  coord_cartesian(expand = FALSE, clip = "off") +
  labs(
    title = "#minätutkin 12.9.2021",
    subtitle = "Suhteellinen osuus",
    caption = "Lähteet: Twitter, FINTO. Alkuperäinen grafiikkakoodi: Georgios Karamanis"
  ) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "grey10", color = NA),
    axis.text.x = element_text(size = 20, face = "bold", margin = margin(10, 0, 0, 0), color = "grey97"),
    plot.margin = margin(20, 5, 20, 5),
    plot.title = element_text(face = "bold", size = 30, color = "grey97"),
    plot.subtitle = element_text(size = 18, margin = margin(5, 0, 10, 0), color = "grey97"),
    plot.caption = element_text(size = 8, margin = margin(10, 0, 0, 0), color = "grey97")
  )
g
ggsave("minatutkin_2021-09-12.pdf", width = 10.2, height = 6.5, device = cairo_pdf)
