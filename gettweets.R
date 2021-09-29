library(rtweet)
library(tidyverse)
library(tidytext)
library(stopwords)
library(udpipe)

#--------------------------------------------
# #minätutkin tweets until midday 2021-09-12
#--------------------------------------------

q <- "#minätutkin"
tweets <- search_tweets(q, n = 5000, include_rts = FALSE)

# Trying to get rid of at least some trolling, organisational tweets etc.
tweets_real <- tweets %>% 
  filter(favorite_count > 0) %>% 
  filter(!grepl("ca", lang)) %>% 
  filter(!grepl("#pinnalla|#budjettiriihi", text)) %>% 
  filter(!screen_name %in% c("keijomedia", "MayaHartikainen", "lauri_linden", "NieminenIiro",
                             "sepukka", "Akatemia_STN", "FinnaBot", "ueflibrary", "finli_degil_Fin",
                             "hponka", "mihkal")) %>% # these two have made analysis
  filter(!grepl("[uU]ni[versity]*", screen_name)) %>% 
  filter(!grepl("parasta|parhautta|huippua|huikea|huikeita|hurja|inspiroiv|rakasta|tykkä|koukutta|mahtav|mainio|valtavasti|loistava|upea|upeita|mielenkiintois|vinkki|aarreaitta|hieno|ahmien|ihana|recommendera|kurkkaa|tsekkaa|käykää", 
                text, ignore.case = TRUE)) %>% 
  filter(!grepl("@hponka|@mihkal", text)) %>% 
  filter(!grepl("hponka|mihkal", urls_url))  

tweets_real_data <- tweets_real %>% 
  select(user_id, created_at, screen_name, text,
         favorite_count, lang, retweet_count,
         status_url,
         description, followers_count, friends_count, 
         account_created_at, profile_image_url, profile_banner_url)

saveRDS(tweets_real_data, "tweets.RDS")
