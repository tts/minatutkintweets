library(rtweet)
library(tidyverse)
library(tidytext)
library(stopwords)
library(udpipe)

#------------------------------------------------------------------
# Based on #minätutkin tweets until midday 2021-09-12,
# With what words do researchers in Finland explain their research ?
#------------------------------------------------------------------

q <- "#minätutkin"
tweets <- search_tweets(q, n = 5000, include_rts = FALSE)

# Trying to get rid of at least some trolling, organisational tweets, 
# and other tweets not relevant here
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

text <- tweets_real_data %>% 
  select(status_url, text, description, lang)

#-----------------------------------------
# Tokenize, clean, and lemmatize by lang
#-----------------------------------------

#-----
# en
#-----

text_en <- text %>% 
  filter(!lang %in% c("fi", "sv")) 

words_en <- text_en %>%
  unnest_tokens(words, text, token = "tweets", drop = FALSE) %>% 
  filter(!words %in% stop_words$word)

words_en <- words_en %>% 
  filter(!str_detect(words, "^@")) %>%
  filter(!str_detect(words, "^http")) %>% 
  filter(!str_detect(words, "^#min[äae]")) %>% 
  mutate(words = gsub("#", "", words)) %>% 
  filter(str_detect(words, "^[a-zåäö]")) %>% 
  filter(!str_detect(words, "disser[ta]*tion")) %>% 
  filter(!status_url == "https://twitter.com/finli_degil_Fin/status/1435313822684823555") %>% 
  filter(!status_url == "https://twitter.com/JannatulKaruna/status/1436252925936877575") %>% 
  filter(!status_url == "https://twitter.com/MinnaFranck/status/1435897148223148035")

enl <- udpipe_download_model(language = "english")
udmodel_en <- udpipe_load_model(file = "english-ewt-ud-2.5-191206.udpipe")

input <- list(doc1 = words_en$words)
txt <- sapply(input, FUN = function(x) paste(x, collapse = "\n"))

start_time <- Sys.time()
x <- udpipe_annotate(udmodel_en, x = txt, tokenizer = "vertical")
end_time <- Sys.time()
(end_time - start_time)
# Time difference of 27.05291 secs

x <- as.data.frame(x)

x1 <- x %>% 
  filter(!grepl("study|incl|im|amp|could|myresearch|hashtag|wearehelsinkiuni|phd|e|jagforskar|phdlife|be|ja|thesis|luteng|basically", lemma)) %>% 
  filter(!grepl("getinspiredbyscience|h2020|highly|metutkimme|viestintä|prof|tutkimme|tutkimus|uniturku|a.k.a.", lemma)) %>% 
  filter(!grepl("academicchatter|ae|al|atm|ce|de|doctoralresearcher|eh|en|flippaus|hanke|wow", lemma)) %>% 
  filter(!grepl("yksityisyy|unioulu|uni|tuki|tilattu|soo|ts", lemma)) %>% 
  filter(!grepl("niin|muodinhuipulla|lagting|ii|humlog|tatuointi", lemma)) %>% #add c("tatuointi", 1) to lang=fi final df
  filter(!grepl("^hi[^t]", lemma)) %>% 
  filter(grepl("^[a-zA-Z]+$", lemma)) %>% 
  mutate(lemma = ifelse(lemma == "gambl", "gamble", lemma)) %>% 
  mutate(lemma = ifelse(lemma == "decisionmak", "decisionmaking", lemma)) %>% 
  mutate(lemma = ifelse(lemma == "wellbe", "wellbeing", lemma)) 

x_en_gr <- x1 %>% 
  group_by(lemma) %>% 
  summarise(n = n()) %>% 
  rename(word = lemma) %>% 
  arrange(desc(n))

write_csv(x_en_gr, "words_en.csv")

#-----
# sv
#-----

text_sv <- text %>% 
  filter(lang == "sv")

words_sv <- text_sv%>%
  unnest_tokens(words, text, token = "tweets", drop = FALSE) %>% 
  filter(!words %in% stopwords("sv"))

words_sv <- words_sv %>% 
  filter(!str_detect(words, "^@")) %>%
  filter(!str_detect(words, "^http")) %>% 
  filter(!str_detect(words, "^#min[äae]")) %>% 
  filter(!str_detect(words, "^#jagforskar")) %>%
  filter(!status_url == "https://twitter.com/MinnaFranck/status/1435897148223148035") %>% 
  filter(!status_url == "https://twitter.com/eFinnby/status/1435135887105478659") %>% 
  filter(!status_url == "https://twitter.com/studentprastMia/status/1435850600391102465") %>% 
  filter(!status_url == "https://twitter.com/kulturfonden/status/1435513885667246085") %>% 
  filter(!status_url == "https://twitter.com/MatiasJungar/status/1435327212362866694") %>% 
  filter(!status_url == "https://twitter.com/LafHR/status/1435458320400371716")

swl <- udpipe_download_model(language = "swedish")
udmodel_sv <- udpipe_load_model(file = "swedish-talbanken-ud-2.5-191206.udpipe")

input <- list(doc1 = words_sv$words)
txt <- sapply(input, FUN = function(x) paste(x, collapse = "\n"))

start_time <- Sys.time()
x <- udpipe_annotate(udmodel_sv, x = txt, tokenizer = "vertical")
end_time <- Sys.time()
(end_time - start_time)
# Time difference of 0.7776599 secs

x <- as.data.frame(x)

x1 <- x %>%
  filter(!grepl("^amp$|^bla$|^ca$|tex$|medborg$|mycket", lemma)) %>% 
  filter(!grepl("^[0-9][0-9]?$", lemma)) %>% 
  mutate(lemma = gsub("#", "", lemma)) %>% 
  mutate(lemma = ifelse(lemma == "hael", "hal", lemma)) %>% 
  mutate(lemma = ifelse(lemma == "ytan", "yta", lemma)) %>% 
  mutate(lemma = ifelse(lemma == "18751939", "1875-1939", lemma))

x_sv_gr <- x1 %>% 
  group_by(lemma) %>% 
  summarise(n = n()) %>% 
  rename(ord = lemma) %>% 
  arrange(desc(n))

write_csv(x_sv_gr, "words_sv.csv")


#-----
# fi
#-----

text_fi <- text %>% 
  filter(lang == "fi")

words_fi <- text_fi%>%
  unnest_tokens(words, text, token = "tweets", drop = FALSE) %>% 
  filter(!words %in% stopwords("fi"))

# Cleaning rows with occurrences >= 2 of the word
del <- str_sort(c("a", "ä", "aaltocreativitysymposium", "se",
                  "millä", "miten", "sen", "esimerkiksi", "kuinka",
                  "tutkin", "metutkimme", "selvitän", "mm", "lisäksi",
                  "about", "ai", "äh", "niin", "tämä", "aattelin",
                  "aikoinaan", "aikoinani", "aiemmin", "aikanaan", "aihe",
                  "myös", "sitä", "mitä", "erityisesti", "väitöskirjassani",
                  "tutkimus", "niiden", "eri", "voidaan", "voi", "amp", "voi",
                  "miksi", "tällä", "eli", "tutkimusta", "siitä", "siihen",
                  "jotta", "esim", "tutkimuksen", "kuten", "kiitos", "wearehelsinkiuni",
                  "niitä", "voisi", "voitaisiin", "jo", "vielä", "sitten", "tätä", "kyllä", "ihan",
                  "tähän", "niihin", "näitä", "tässä", "jossa", "affiliaationi", "agoratutkimuskeskuksessa",
                  "aina", "jopa", "josta", "minäkin", "silti", "eikä", "jne", "no",
                  "jonka", "mistä", "ehkä", "tästä", "samalla", "näin", "saadaan", "silloin",
                  "tämän", "siinä", "täällä", "tutkimukseni", "tutkitaan", "joilla", "joissa", "joita",
                  "heidän", "millaisia", "voivat", "näiden", "tutkia", "onko", "etenkin",
                  "siis", "voimme", "vähän", "tutkitaan", "aivan", "mihin", "hyvin", "joiden", "pyrin",
                  "tutkimme", "millaista", "n", "in", "pitäisi", "niistä", "and",
                  "teen", "tutkii", "joku", "kiinnostavia", "mitään", "taas", "tarkastelen", "vain",
                  "missä", "olevia", "parhaillaan", "haluan", "muita", "näihin", "ns", "siksi",
                  "tärkeä", "toivottavasti", "jota", "siksitiede", "näistä", "yritän",
                  "minua", "myötä", "täältä", "tutkimusryhmäni", "työssäni", "häsä", "i", "joten",
                  "tänä", "toisaalta", "väitöstutkimuksessani", "voiko", "jolla", "the", "vaikkapa",
                  "voisivat", "kiva", "koskaan", "minätutkin", "minkälaisia", "oon", "siten", "tein",
                  "toki", "erit", "haluaisin", "lähinnä", "ml", "näissä", "yhä", "ainakin", "tulisi",
                  "gradussani", "tärkeitä", "pitää", "etsin", "ettei", "tää", "tarkoituksena",
                  "tutkimuksessani", "tutkimustani", "v", "edes", "hei",
                  "keskityn", "luteng", "minkä", "minulle", "minusta",
                  "niissä", "olisiko", "paitsi", "siellä", "unioulu", "väikkärissäni",
                  "häsän", "hashtag", "joko", "kirjoitan", "of", "tosin", "sai",
                  "työni", "uskon", "ym", "fokuksessa", "imperfekti", "imperfektissä",
                  "johon", "jyunique", "kai", "joista", "millainen", "millaisin", "miltä", "mun",
                  "saataisiin", "saisi", "selvitämme", "ssa", "tee", "to", "uef",
                  "voisimme", "yms", "aihetunnisteella", "b", "c", "ehdin", "gradu",
                  "heitä", "ikinä", "itsekin", "jolloin", "just", "kovin", "kyseessä", "mä",
                  "mielelläni", "otti", "pohdin", "pyritään", "research", "sieltä", "sille",
                  "suosittelen", "tttv21", "verran", "aion", "arvostan", "enkä", "fokus", "halusin", "häsää", "häsällä",
                  "innolla", "jokin", "käsittelee", "käytän", "keitä", "kiinnostava",
                  "kiitoksia", "lähes", "laidasta", "laitaan", "mahdollisesti", "mielellään",
                  "minut", "mikään", "mitäolensaanutselville", "mut", "my", "osaisitko", "pidetään",
                  "piti", "post", "s", "sain", "saattaa", "saamme", "sellainen", "sellaisia", "sellaista",
                  "siitä", "t", "tampereuni", "tavoitteeni", "trendaa", "työkseni", "väikkärissä",
                  "väitöskirjatyössäni", "väittelin", "voidaanko", "vs", "ylipäänsä",
                  "saa", "as", "at", "doc", "entä", "etten", "häntutkii", "helsinkiuni",
                  "huomasin", "huomenta", "instituutissamme", "it", "joo", "jyunity",
                  "kannattaisi", "kiinnostaako", "kiinnostavalta", "kiitollinen",
                  "koen", "kollegani", "kulttuurirahastontuella", "kysyn", "lienee",
                  "lutbiz", "määrin", "meilläkin", "melko", "mielenkiintoinen",
                  "mpkkfi", "myresearch", "oikeastaan", "ois", "onkin", "onpa", "oo",
                  "pääsee", "parhaillani", "phd", "pitäisikö", "pohdintaa", "pyrkii", "pyrkivät",
                  "ryhmässämme", "saako", "sit", "tällaista", "tällaisten", "tältä",
                  "teidän", "tervetuloa", "tuskin", "tutkimusalamme", "tutkimuskohde",
                  "tutkisin", "tutkitaankaan", "tutkitte", "unohtamatta", "väitöskirjatutkimuksessani",
                  "voisin", "vrt", "what", "welma", "yllä", "älkää", "ao", "arvioin",
                  "blogissani", "by", "da", "eg", "eka", "for", "gradussa", "hankkeessani",
                  "hashtagilla", "hashtagin", "häshtägin",
                  "ilahduttavaa", "innostavaa", "jagforskar", "jatkan", "jatkoopiskelijana",
                  "jonkun", "jotakin", "jotkin", "julkaistussa", "katso", "kenelle",
                  "kerrankin", "kiinnostusta", "kiitokset", "kirjoitin", "klo",
                  "kohteenani", "koin", "kovasti", "kunhan",
                  "kyl", "lähdin", "liittyi", "lisäksi", "lohdullista", "loistoidea",
                  "mahd", "mielestäni", "mua", "mulla", "olis", "onkaan", "onneksi", "opin", "osaamistani",
                  "osatutkimuksessani", "ovatko", "parhaani", "pidin", "pyrimme",
                  "rahoittajana", "rahoittajat", "runsaasti", "saattavat",
                  "selvitin", "selvitetään", "sinne", "sovellamme", "soveltamista",
                  "ssä", "study", "suom", "tägi", "tahdon", "taisi", "tällainen", "tällaisen",
                  "tällaisia", "tämäkin", "tässähän", "tavoitteemme", "them", "tiedämme",
                  "tiimini", "tiivistettynä", "toi", "toimin", "toistaiseksi",
                  "ties", "tick", "teette", "tulin", "tutkimusryhmämme", "tutkimusryhmän",
                  "työtäni", "uniturku", "väitöskirjani",
                  "väitöskirjatutkija", "väitöskirjatutkimus", "väitöstutkimukseni",
                  "väitöstutkimus", "valitettavasti", "vapaaajallani", "varmaan", "varmasti",
                  "vissiin", "voin", "w", "with", "inspiroi",
                  "jahka", "kommentoin", "ks", "l", "laitan", "laittakaa",
                  "läjäpäin", "lisäinfoa", "lla", "löysin", "luulisi", "yritin",
                  "ykn", "xamk", "wastpan", "voitaisi", "voit", "vieläkö", "vieläkin",
                  "vau", "valtavan", "väitöskirjastani", "väikkärin", "väikkärihommia",
                  "va", "utulang", "unilut", "unieastfinland",
                  "työskentelen", "työryhmäni", "tutkivani", "tutkitko",
                  "tutkimustamme", "tutkimuskohteitani", "tutkimusalani", "tutkimushommat",
                  "tutkimusaiheeni", "tutkimuksestasi", "tutkimuksestani", "tuolloin",
                  "ts", "tosiaan", "tiukkaa", "metutkimmeminätutkin",
                  "yhtään", "yritämme", "aihetunnisteen", "aihetunnisteet", "aloitan",
                  "am", "an", "antoisinta", "aokktutkii", "captain", "case", "ehkäpä", "eihän",
                  "eiku", "eipä", "focus", "graduni", "haastoin", "hankkeessamme",
                  "harjoittelin", "häsälle", "häsästä", "hashtagi", "hashtagia", "hästägillä",
                  "hästäkillä", "hauskaa", "havaintoni", "hommaa", "hommaista", "homman",
                  "huipputiimin", "huolissani", "hurahtanut", "hutkin",
                  "huuhaa", "huvittaa", "hyödytöntä", "hyvinsanottu",
                  "ilmeisesti", "iloitsen", "iltaisin", "innostuin", "innostavaa",
                  "is", "issa", "itseäni", "itseeni", "itseasiassa",
                  "jaan", "jäin", "jatkakaa", "jonakin", "jonkin", "joskin", "jospa", "jossain",
                  "joulukuussa", "julkaisen", "jyu", "k", "kaikkeni", "kans",
                  "kävin", "kehitin", "kellekään", "kerromme", "kiehtoo", "kiehtovaa",
                  "kiehtovia", "kielinguablogiin", "kiinnostukseni", "kiinnostavin",
                  "kiintoisaa", "kirjoittamani", "ko", "kollegoideni",
                  "artikkelin", "artikkelia", "artikkeliini", "artikkelissa", "artikkelissamme", "artikkelistamme",
                  "academicswithbunnies"))

words_fi <- words_fi %>% 
  filter(!str_detect(words, "^@")) %>% 
  filter(!str_detect(words, "^http")) %>% 
  filter(!str_detect(words, "^#min[äae]")) %>% 
  mutate(words = gsub("#", "", words)) %>% 
  filter(str_detect(words, "^[a-zåäö]")) %>% 
  filter(!words %in% del)

fl <- udpipe_download_model(language = "finnish")
udmodel_fi <- udpipe_load_model(file = "finnish-tdt-ud-2.5-191206.udpipe")

# Test set
#
# test <- list(doc1 = head(words_fi$words))
# txt <- sapply(test, FUN = function(x) paste(x, collapse = "\n"))
# x <- udpipe_annotate(udmodel_fi, x = txt, tokenizer = "vertical")
# x <- as.data.frame(x)

input <- list(doc1 = words_fi$words)
txt <- sapply(input, FUN = function(x) paste(x, collapse = "\n"))

# Run
start_time <- Sys.time()
x <- udpipe_annotate(udmodel_fi, x = txt, tokenizer = "vertical")
end_time <- Sys.time()
(end_time - start_time)
# Time difference of 4.871036 hours

x <- as.data.frame(x)

x1 <- x %>% 
  mutate(lemma = ifelse(lemma == "suoma", "suomi", lemma)) %>% 
  mutate(lemma = ifelse(lemma == "metsi", "metsä", lemma)) %>% 
  mutate(lemma = ifelse(lemma == "metsikö", "metsikkö", lemma)) %>% 
  mutate(lemma = gsub("#", "", lemma)) %>% 
  filter(nchar(lemma) > 1) %>% 
  filter(str_detect(lemma, "^[a-zåäö]"))

x_fi_g <- x1 %>% 
  group_by(lemma) %>%
  summarise(n = n()) %>% 
  rename(sana = lemma) %>% 
  arrange(desc(n))

# Adding this from the lang=en set, see above
to_fi <- c("tatuointi", 1)
x_fi_g <- rbind(x_fi_g, to_fi) 

write_csv(x_fi_g, file = "words_fi.csv")

# How many rows with occ > 1 ?
(over1 <- str_c(round(nrow(x_fi_g[x_fi_g$n > 1,]) / nrow(x_fi_g[x_fi_g$n == 1,]) * 100), "%", sep = " "))
# "40 %" 
# so 60% of words remain uncleaned
