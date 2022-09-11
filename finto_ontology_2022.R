library(tidyverse)
library(httr)

source("utils.R")

#----------------------
# Broader terms
#----------------------

# fi

out_fi <- readRDS("out_fi_3.RDS")

l_vec <- unique(str_sort(as.vector(unlist(out_fi['uri']))))

req_fi <- plyr::llply(l_vec, t_fetch, lang = "fi", .progress = "text") %>%
  dplyr::bind_rows()

write_csv(req_fi, "broaderterm_fi_3_2022.csv")

# Remove deprecated uris
valid_fi <- req_fi %>% 
  filter(!is.na(broader_term))

terms_fi <- left_join(out_fi, valid_fi) %>% 
  mutate(broader_term = ifelse(is.na(broader_term), label, broader_term),
         broader_term_uri = ifelse(is.na(broader_term_uri), uri, broader_term_uri)) %>% 
  select(-label_score)

write_csv(terms_fi, "terms_fi_3_2022.cvs")

#  sv

out_sv <- readRDS("out_sv_3.RDS")

l_vec <- unique(str_sort(as.vector(unlist(out_sv['uri']))))

req <- plyr::llply(l_vec, t_fetch, lang = "sv", .progress = "text") %>%
  dplyr::bind_rows()

write_csv(req, "broaderterm_sv_3_2022.csv")

# If broader term is NA, the term is most probably a country
terms_sv <- left_join(out_sv, req) %>% 
  mutate(broader_term = ifelse(is.na(broader_term), label, broader_term),
         broader_term_uri = ifelse(is.na(broader_term_uri), uri, broader_term_uri)) %>% 
  select(-label_score)

write_csv(terms_sv, "terms_sv_3_2022.cvs")

# en

out_en <- readRDS("out_en_3.RDS")

l_vec <- unique(str_sort(as.vector(unlist(out_en['uri']))))

req_en <- plyr::llply(l_vec, t_fetch, lang = "en", .progress = "text") %>%
  dplyr::bind_rows()

write_csv(req_en, "broaderterm_en_3_2022.csv")

terms_en <- left_join(out_en, req_en) %>% 
  mutate(broader_term = ifelse(is.na(broader_term), label, broader_term),
         broader_term_uri = ifelse(is.na(broader_term_uri), uri, broader_term_uri)) %>% 
  select(-label_score)

write_csv(terms_en, "terms_en_3_2022.cvs")

terms_all <- rbind(terms_fi, terms_sv, terms_en)
write_csv(terms_all, "terms_all_3_2022.csv")

#--------
# Groups
#--------

#  fi

fi <- read_csv("terms_fi_3_2022.cvs")

# Non-place terms
out_fi <- fi %>% 
  filter(!label == broader_term)

# Place terms
out_fi_p <- fi %>% 
  filter(label == broader_term) %>% 
  mutate(group = "Place")

l_vec <- unique(str_sort(as.vector(unlist(out_fi['uri']))))

req <- plyr::llply(l_vec, g_fetch, lang = "fi", .progress = "text") %>%
  dplyr::bind_rows()

out_fi_g <- left_join(out_fi, req)
out_fi_g <- out_fi_g %>% 
  rename(group = sn)

out_fi_g_all <- rbind(out_fi_g, out_fi_p)

write_csv(out_fi_g_all, "terms_groups_fi_3_2022.csv")


#  sv

sv <- read_csv("terms_sv_3_2022.cvs")

# Non-place terms
out_sv <- sv %>% 
  filter(!label == broader_term)

# Place terms
out_sv_p <- sv %>% 
  filter(label == broader_term) %>% 
  mutate(group = "Place")

l_vec <- unique(str_sort(as.vector(unlist(out_sv['uri']))))

req <- plyr::llply(l_vec, g_fetch, lang = "sv", .progress = "text") %>%
  dplyr::bind_rows()

out_sv_g <- left_join(out_sv, req)
out_sv_g <- out_sv_g %>% 
  rename(group = sn)

out_sv_g_all <- rbind(out_sv_g, out_sv_p)

write_csv(out_sv_g_all, "terms_groups_sv_3_2022.csv")

#  en

en <- read_csv("terms_en_3_2022.cvs")

# Non-place terms
out_en <- en %>% 
  filter(!label == broader_term)

# Place terms
out_en_p <- en %>% 
  filter(label == broader_term) %>% 
  mutate(group = "Place")

l_vec <- unique(str_sort(as.vector(unlist(out_en['uri']))))

req <- plyr::llply(l_vec, g_fetch, lang = "en", .progress = "text") %>%
  dplyr::bind_rows()

out_en_g <- left_join(out_en, req)
out_en_g <- out_en_g %>% 
  rename(group = sn)

out_en_g_all <- rbind(out_en_g, out_en_p)

write_csv(out_en_g_all, "terms_groups_en_3_2022.csv")

# Combine all langs
all <- rbind(out_fi_g_all, out_sv_g_all, out_en_g_all)

# Exclude 00 General terms (in all lang)
all <- all %>% 
  filter(!grepl("^00", group)) 

write_csv(all, "terms_groups_all_3_2022.csv")

#------------------------------------------------
# Finnish group terms to join later on 
# due to difficulties in detecting/parsing lang
# from the previous results
# https://api.finto.fi/rest/v1/yso/groups?lang=fi

g_df <- fetch_fi_g()

write_csv(g_df, "groups_fi_2022.csv")

