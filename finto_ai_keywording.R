library(tidyverse)
library(httr)

source("functions.R")

data <- readRDS("tweets.RDS")

data_cleaned <- data %>% 
  filter(!screen_name %in% c("byntti", "SamiSyrjamaki", "Ruokaosuuskunta",
                             "AijaL", "GTK_FI", "hannemaaret", "HeinanenS",
                             "HenryOssian", "HMerikoski", "JamiJokinen",
                             "janinacecilia", "jatlaine", "JussiLahde",
                             "KaarinaHazard", "a_alanko", "aaroka", "AFinLA_ry",
                             "agricola_verkko", "aikuiskasvatus", "AitiJonsku",
                             "ajnabifinlandi", "akaratammi", "AlainenSuvi",
                             "ammaunu", "AMRajoo", "anjahelenar", "annekookoo",
                             "AnniinaLundvall", "annlesk1", "AnnukkaMeronen",
                             "anttiseppl", "AriJLaaksonen", "auervaara",
                             "CASfinland", "CoelThomas", "DJJuvenalis",
                             "DogIMikko", "edvpml", "eemelivee", "eevajkl",
                             "eevamehtatalo", "Ehto2", "EIviiraMarjovuo",
                             "elina_castren", "Elinahaha", "elisalautala",
                             "Emikyy1", "eppuJ", "EppuMJ", "ErikMiltton",
                             "ErkkoSointu", "FocusLocalis", "giacbotta",
                             "GisseProf", "GreenThaifood", "haamuraja",
                             "HakkinenEliisa", "HAMK_Edu", "HAMK_UAS",
                             "hannatakala", "hannemaaret","Harmaja1",
                             "HarriKamala", "HelenMetsa", "HeliAntila",
                             "helihorkko", "henrikarppine", "henrikju",
                             "HenriMuroke", "HenryOssian", "HessuLehti",
                             "himberg_timo", "HMerikoski", "homepakolaiset",
                             "HRydenfelt", "HupsSaara", "HurskainenUlla",
                             "HVoikeus", "HYPsykoLogo", "ienkkis",
                             "ilmastoviesti", "iqoTopi", "j_aaltonen",
                             "j_seppola", "jaleksi", "JAMK_AOKK", "janaarnikoivu",
                             "jannehak", "JariHuttunen88", "JariLeino3",
                             "JarkkoVikman", "jarmoritola", "jarvansalo",
                             "jennifer_stoney", "JenniVirtaluoto", "Jirgson",
                             "jirisalin", "JJarainen", "JKarkimaa", "JohannaHellste2",
                             "Johannes_Jau", "JoonasKiviranta", "JoukoJunttila",
                             "JSaramies", "JuhoWilskman", "juhsa", "juhuus",
                             "jukaipia", "julia_pajunen", "jupeai","juuhaa",
                             "JyrkiLiikka", "JYUavoin", "KaarinaKaminen",
                             "kaisa_hiltunen", "KaleniusSaija", "kaljalainen",
                             "kallevihtari", "Kallixia", "Kariheikki",
                             "karinajutila", "katri_ollila", "KatriSisko",
                             "Kemikaalikimara", "kevinteak", "KFogelholm",
                             "kilgore7", "kilpimies", "KimKrappala", "kimvaisanen",
                             "KKyppo", "KoponenHei", "KorhonenMla", "Koso_muminski",
                             "krista_ri_", "ksuvanto", "kuusiplus", "lahikuva",
                             "lampilinna", "Laspaa1","Laura_Jii", "Laura_Juvonen",
                             "LauraHuu", "LauraKemppaine", "leanvaltio",
                             "LeoLiukkonen", "LepistoJoonas", "LiisaSuoninen",
                             "lilohtander", "LindholmJukka", "LKairesalo",
                             "LogosEnsy", "Maarit_Nousi", "maijantwit",
                             "Maliri92", "marion_fields", "MariVaisto",
                             "MarjaRoiha", "Marjobee", "markkusseppala",
                             "MarkoKettunen", "markusleikola", "MartinaHuhtam",
                             "matiasmakynen", "MattiHameenaho", "MattiMuukkonen",
                             "MattiPaananen1", "MaukkaP", "MetsatSeura",
                             "mi_kymalainen", "MiaMiettinen", "MidiaDaimi",
                             "MiikkaKeranen", "MikaelNiku", "MikaPirhonen",
                             "MikaTuuliainen", "MikkoFabric", "Mikkohann",
                             "MikkoMyl", "MikkoVuorenpaa", "mikkowaeder",
                             "millahavanka", "milotoivonen", "minnatimo",
                             "MirvaGullman", "MMLeskinen", "mpkkfi",
                             "Nahuman", "NeraBec", "NeurocenterFI", "NeuvonenTuija",
                             "NevalainenJaana", "Nieharri", "nousjk", "OlliKorhonen5",
                             "ossi_mantylahti", "oula_silver", "outi_leskinen",
                             "outilammi", "PAittakumpu", "PaivikkiER", "PekkaHagstrom",
                             "PekkaMetso", "pekkarahko", "pesonja75", "PetriHolmberg",
                             "PipsaHumalamaki", "PJHeikura", "PMeemit", "Prologos_ry",
                             "Ptterz", "puutuote", "Pyrynestori", "Rahi", "rauno_varis",
                             "real_el_raimo", "ReettaMeri", "reettavoutilai",
                             "RiittaMonto", "riittaoceane", "RikuKangasniemi",
                             "RikuWallin", "rkalmi", "RonjaOja", "rrenkone",
                             "Ruokavirasto", "ruokojenni", "Ruralia_UH", "RuusaSaarinen",
                             "SaaraOsterberg", "Sainio3Sainio", "sakuvee74",
                             "SallamaariM", "salum_AR", "SamiLukkari", "samponev",
                             "SamuliAlppi", "sannalyly", "SannaSaariS", "SannaWuorio",
                             "sattumatutkija", "Satu_Helenius", "satuylahaikunen",
                             "seppo_hanninen", "SeppoAlaruikka", "SiljaLatvanen",
                             "SimoHosio", "SiniHeinoja", "SiniKaarina", "SMarttinen",
                             "SoilaKarreinen", "steivonen", "StopDiaFinland",
                             "sykkyrainen", "TahitiOulu", "Taideyliopisto",
                             "taija_rutanen", "taisto_hakala", "TanjaRisikko",
                             "tapiomaatta", "TarjaViholainen", "tarukuhalampi",
                             "TeaVnen", "TeijaKoskela", "TESSUprojekti",
                             "tiarAnon", "Tiedeakatemia", "tiedejatutkimus",
                             "tiedetati", "TiinaOnikki", "TiinaValonen","Timo_Kukkonen",
                             "TimoTossavainen", "tinamustakallio", "TinoLintunen",
                             "TMertanen", "tommi_tenkanen", "ToniEronen",
                             "TOYRYLM", "tsv_media", "TuomasEnbuske", "tutkitusti",
                             "ulapland", "UllaMR", "unellastic", "UNITEflagship",
                             "unofficial_mara", "UTU_Sote", "UudenmaanAVH",
                             "VeliHolopainen", "VesaKirves", "ViertolaAsta",
                             "Vihtori_", "viivi_e", "villecantell", "VilleLahtinen5",
                             "ViRiikonen", "virpi_anttila", "Vulgareon",
                             "yplehti")) %>% # fi
  filter(!screen_name %in% c("kulturfonden", "LafHR", "MatiasJungar", "studentprastMia")) %>% # sv
  filter(!screen_name %in% c("andrikos", "CancerFinland", "CorinnaCasi", "datadriveby",
                             "DocSchool_TAU", "domekarukoski", "e_rawlins", "Hanken_fi",
                             "Hasse_Karlsson1", "HelsinkiHSSH", "InkaSantala",
                             "JannatulKaruna", "jukkamahonen", "larihuttunen",
                             "LauraHirsto", "mantyne", "meerihaataja", "MeskanenP",
                             "olofflo", "pembertonfilms", "petri_pellinen", "RECecochange",
                             "RiinaSalmimies", "SallaAtkins", "Satu_Helenius",
                             "Singingarchives", "StadinHyttyset", "Taideyliopisto",
                             "TaneliPuputti", "teemul", "theodorajarvi", "tijh",
                             "tutamAW", "Vormanen")) %>% # en
  mutate(text = gsub("#min[äa]tutkin|#minaetutkin|#metutkimme|#min[aä]hutkin|#jagforskar|[0-9]\\)", "", text, ignore.case = TRUE)) %>% 
  mutate(text = gsub("@[^ ]*", "", text)) %>% 
  mutate(text = gsub("#|\\:", "", text)) %>% 
  mutate(text = gsub("https?[^ ]+", "", text)) %>% 
  rowwise() %>% 
  mutate(text = remove_emojis(c(text))) %>% 
  select(user_id, created_at, text, lang, favorite_count, retweet_count, status_url, followers_count, friends_count)

write_csv(data_cleaned, "cleaned_tweets.csv")

# Concatenate multiple tweets by user
data_cleaned_by_user <- data_cleaned %>% 
  group_by(user_id) %>% 
  mutate(alltext = paste0(text, collapse = "")) %>% 
  distinct(user_id, .keep_all = TRUE)

#  Automatic keywording with Finto AI
#  https://www.kiwi.fi/display/Finto/Finto+AI%3An+rajapintapalvelu

# fi
data_cleaned_by_user %>% 
  ungroup() %>% 
  filter(lang == "fi") %>% 
  select(alltext) %>% 
  as.vector() -> tw_vec_fi

req <- plyr::llply(tw_vec_fi, kw_fetch, project = "yso-fi", .progress = "text") %>%
  dplyr::bind_rows()

write_rds(req, "req_fi_3.RDS")

out_fi <- unnest_req(req)
write_rds(out_fi, "out_fi_3.RDS")

#  sv
data_cleaned_by_user %>% 
  ungroup() %>% 
  filter(lang == "sv") %>% 
  select(alltext) %>% 
  as.vector() -> tw_vec_sv

req <- plyr::llply(tw_vec_sv, kw_fetch, project = "yso-sv", .progress = "text") %>%
  dplyr::bind_rows()

write_rds(req, "req_sv_3.RDS")
out_sv <- unnest_req(req)
write_rds(out_sv, "out_sv_3.RDS")

# en
data_cleaned_by_user %>% 
  ungroup() %>% 
  filter(lang == "en") %>% 
  select(alltext) %>% 
  as.vector() -> tw_vec_en

req <- plyr::llply(tw_vec_en, kw_fetch, project = "yso-en", .progress = "text") %>%
  dplyr::bind_rows()

write_rds(req, "req_en_3.RDS")
out_en <- unnest_req(req)
write_rds(out_en, "out_en_3.RDS")

kw_data <- rbind(out_fi, out_sv, out_en)

# Joining with other relevant tweet data
kw_data_labels_date <- left_join(kw_data, data_cleaned_by_user, by = c("text" = "alltext"))

kw_data_labels_date <- kw_data_labels_date %>% 
  select(text, label, uri, user_id, created_at, followers_count)

write_csv(kw_data_labels_date, "kw_data_labels_3_date.csv")




