library(rtweet)
library(tidyverse)

#--------------------------------------------
# #minätutkin tweets until 2022-09-11
#--------------------------------------------

q <- "#minätutkin"
tweets <- search_tweets(q, n = 5000, include_rts = FALSE)

# Trying to get rid of at least some trolling, organisational tweets etc.
tweets_real <- tweets %>% 
  filter(!screen_name %in% c("AaltoUniversity", "AnninaRop", "AnnukkaMeronen",
                             "anssihan", "AriJLaaksonen", "ArkoSalminen", "AtteKaleva", 
                             "DocSchool_TAU", "DrSeppanen", "EevaPrimmer", "Epanetverkosto",
                             "esahamal", "fin_sci", "geography1888", "himberg_timo",
                             "InFLAMES_Health", "JantunenKaarina", "jennimheikkinen",
                             "JoonasKiviranta", "JukkaSavo", "juuhaa", "KaltiomaaTarja",
                             "kehityosaajana", "kirkontutkimus", "knuutinen_mikko",
                             "kultutlehti", "LammiTerhi", "LegaltechHEL", "LifeSciHelsinki",
                             "LiisaPuskala", "MaaritLeinonen", "maijareetta",
                             "makinenJAM", "MarjoHonkaranta", "MattiHameenaho", "mervi_rantsi",
                             "mikkolahm", "MikkonenTuija", "MikkoVuorenpaa", "miliisimusic", "MLiimatainen",
                             "mvonwi", "myllarni", "nazzeus", "NesslingSaatio",
                             "OJhoine", "Outi_Pakarinen", "PValvoja",
                             "RomanBednarik", "SamiSyrjamaki", "sashamakila", "sattumatutkija",
                             "satu_lipponen", "satuseppa", "Skr_fi",
                             "Sotkis", "stifundu", "Suomijm", "Taideyliopisto",
                             "TanjaRisikko", "TenhunenSilja", "terojuutilainen", "Tre_Brain_Mind",
                             "Tiina_Ollila", "Tku_brain_mind", "TomasSjoblom",
                             "TraciInFinland", "Tre_Brain_Mind", "tutkitusti",
                             "tykytuo", "uefcceel", "UniEastFinland",
                             "uniofjyvaskyla", "unipidfinland", "UNITEflagship",
                             "ValtteriParikka", "VeraMikkila", "vijarvinen",
                             "ville_e", 
                             "mihkal")) %>%  #lähinnä analyyseja
  filter(!grepl("parasta|parhautta|huippua|huikea|huikeita|hurja|inspiroiv|rakasta|tykkä|koukutta|mahtav|mainio|valtavasti|loistava|upea|upeita|mielenkiintois|vinkki|aarreaitta|hieno|ahmien|ihana|recommendera|kurkkaa|tsekkaa|käykää", 
                text, ignore.case = TRUE)) %>% 
  mutate(text = gsub("#min[äa]tutkin|#minaetutkin|#metutkimme|#min[aä]hutkin|#jagforskar|[0-9]\\)", "", text, ignore.case = TRUE)) %>% 
  mutate(text = gsub("@[^ ]*", "", text)) %>% 
  mutate(text = gsub("#|\\:", "", text)) %>% 
  mutate(text = gsub("https?[^ ]+", "", text)) %>% 
  rowwise() %>% 
  mutate(text = remove_emojis(c(text))) %>% 
  select(user_id, created_at, text, lang, favorite_count, 
         retweet_count, status_url, followers_count, friends_count)
 
saveRDS(tweets_real, "tweets_2022.RDS")