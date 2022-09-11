library(tidyverse)
library(httr)

source("utils.R")

data <- readRDS("tweets_2022.RDS")

# Concatenate multiple tweets by user
data <- data %>% 
  group_by(user_id) %>% 
  mutate(alltext = paste0(text, collapse = "")) %>% 
  distinct(user_id, .keep_all = TRUE)

# Few emojis still persist
# https://stackoverflow.com/a/11971126
data <- map_df(data, ~ gsub("[^[:alnum:]///' ]", "", .x))
# and one tweet from previous month
data <- data %>% 
  filter(!grepl("2022-08-31 10:22:30", created_at))

write_csv(data, "cleaned_tweets_2022.csv")

#  Automatic keywording with Finto AI
#  https://www.kiwi.fi/display/Finto/Finto+AI%3An+rajapintapalvelu

# fi
data %>% 
  ungroup() %>% 
  filter(lang == "fi") %>% 
  select(alltext) %>% 
  #head() %>% #debug
  as.list() -> tw_vec_fi

req <- plyr::llply(tw_vec_fi$alltext, kw_fetch, project = "yso-fi", .progress = "text") %>%
  dplyr::bind_rows()

write_rds(req, "req_fi_3.RDS")
out_fi <- unnest_req(req)
write_rds(out_fi, "out_fi_3.RDS")

#  sv
data %>% 
  ungroup() %>% 
  filter(lang == "sv") %>% 
  select(alltext) %>% 
  as.list() -> tw_vec_sv

req <- plyr::llply(tw_vec_sv$alltext, kw_fetch, project = "yso-sv", .progress = "text") %>%
  dplyr::bind_rows()

write_rds(req, "req_sv_3.RDS")
out_sv <- unnest_req(req)
write_rds(out_sv, "out_sv_3.RDS")

# en
data %>% 
  ungroup() %>% 
  filter(lang == "en") %>% 
  select(alltext) %>% 
  as.list() -> tw_vec_en

req <- plyr::llply(tw_vec_en$alltext, kw_fetch, project = "yso-en", .progress = "text") %>%
  dplyr::bind_rows()

write_rds(req, "req_en_3.RDS")
out_en <- unnest_req(req)
write_rds(out_en, "out_en_3.RDS")

kw_data <- rbind(out_fi, out_sv, out_en)

# Joining with other relevant tweet data
kw_data_labels_date <- left_join(kw_data, data, by = c("text" = "alltext"))

kw_data_labels_date <- kw_data_labels_date %>% 
  select(text, label, uri, user_id, created_at)

write_csv(kw_data_labels_date, "kw_data_labels_3_date_2022.csv")




