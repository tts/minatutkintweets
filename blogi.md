---
title: "#minätutkin-twiittien aiheet"
date: "2021-10-01"
author: "Tuija Sonkkila"
slug: "mina-tutkin"
categories:
  - R
  - asiasanoitus
  - ontologiat
  - visualisointi
tags:
  - twitter
  - finto
output:
  blogdown::html_page:
    highlight: tango
---

Syyskuun alussa 2021 Twitterin aihetunniste *minätutkin* oli suosittu. Itä-Suomen yliopiston akateeminen rehtori Tapio Määttä [sysäsi meemin liikkeelle](https://twitter.com/tapiomaatta/status/1434449463268057092), ja pain siihen liitettiin sopiva aihetunniste. Tutkijat innostuivat tiivistämään työnsä twiitin merkkimäärään ja suuri yleisö innostui yhtä lailla lukemastaan. Vaikka Suomesta löytyy ajantasaisia sivustoja tutkimuksesta, uusimpana [tutkimustietovaranto](https://www.tiedejatutkimus.fi/fi/), niiden varsinainen fokus ei ole tehdä tiedettä helposti lähestyttäväksi. Toki ne saattavat onnistua siinäkin, mutta vain välillisesti.

Mistä sitten twiitattiin? Mitä olivat ne tieteenalat, joiden tutkijat ehtivät tai kiinnostuivat twiittaamaan? Millä termeillä aloja kuvattiin? 

Päätin tehdä epätieteellisen tutkimuksen siitä, miten Kansalliskirjaston [Finto AI -rajapintapalvelu](https://www.kiwi.fi/display/Finto/Finto+AI%3An+rajapintapalvelu) palvelisi twiittien automaattisessa asiasanoituksessa ja [Finto API](https://api.finto.fi/) näiden asiasanojen ryhmittelyssä pääluokkiin. Heti alkuun on muistutettava siitä, että Finto AI on toistaiseksi pelkkä suosittelija; ihmisen on tarkoitus tehdä lopulliset asiasanavalinnat. Näin toimitaan mm. Jyväskylän yliopistossa, jossa opiskelijat asiasanoittavat opinnäytteensä Finto API:lla, valitsevat ehdotuksista sopivat (tai muokkaavat niitä), ja lopuksi kirjastonhoitaja hyväksyy ne. Tässä harjoituksessa annan kuitenkin mennä täysautomaatilla, kädet poissa ratilta. 

(Alla olevat koodit ovat [Github-repossa](https://github.com/tts/minatutkintweets).)

### Twiittien haku ja siivous

Kuten tunnettua, on toimittava nopeasti, jos haluaa kerätä twiittejä ilman erityistoimenpiteitä. Vaikka #minätutkin-häntää on näkynyt aina näihin päiviin asti, hain tässä käsitellyt twiitit jo 12.9. alkuiltapäivästä enkä sen jälkeen enää uudistanut hakua. Piikki osui välille tiistai-torstai 7-9.9.

Harto Pöngän [10.9 keräämien tilastojen mukaan](https://twitter.com/hponka/status/1436240568045158402) 5000 kappaletta vaikutti sopivalta ylärajalta. Ei uudelleentwiittauksia.

```
library(rtweet)
q <- "#minätutkin"
tweets <- search_tweets(q, n = 5000, include_rts = FALSE)
```

Twiittien siivous on käsityötä. Aivan aluksi poistin selkeimpiä trollauksia, lukijoiden kiittäviä postauksia ja muita tässä yhteydessä epärelevantteja. Myöhemmin kävin vielä twiitit kertaalleen läpi ja filtteröin pois ne, jotka eivät olleet tutkijoilta itseltään vaan suurelta yleisöltä, tutkimusorganisaatiolta tai rahoittajalta. En edes pyrkinyt täydelliseen siivoukseen, ja lisäksi twiiteissä oli rajatapauksia. 

Osa tutkijoista postitti useita #minätutkin-twiittejä. Joiltakin oli unohtunut ensimmäisestä aihetunniste - jolloin se ei siis tarttunut haaviini - jotkut halusivat täydentää, eräät taas jatkoivat aiheen parissa muulla tavoin, innostaen kolleegoita tulemaan mukaan jne. Yhdistin nämä kaikki jatkokäsittelyä varten. Jälkiviisastellen olisi ollut fiksua päätellä näistä "päätwiitti" (ehkä ajallisesti ensimmäinen), jotta yleiskielen määrä olisi pysynyt minimissä. Muuntelu oli kuitenkin niin suurta ettei maksanut vaivaa.

Tämän osuuden koodi on tiedostossa [gettweets.R](https://github.com/tts/minatutkintweets/blob/main/gettweets.R)

### Asiasanoitus

Finto AI -rajapintapalvelulle lähetetään asiasanoitettava teksti HTTP POST -kutsussa. Palautettavien asiasanojen lukumäärää voi säätää (limit), samoin niiden osumistarkkuuden kynnysarvoa (threshold). Lisäksi URL:ssa on oltava tieto projektista eli siitä, minkä kielisestä tekstistä on kyse. Palvelulla on interaktiivinen [hiekkalaatikko](https://ai.finto.fi/v1/ui/).

En osaa sanoa, kuinka luotettava Twitterin palauttama `lang`-arvo on, mutta joka tapauksessa käytin sitä. Satunnaisotannalla se näytti kertovan totta. Toinen asia on sitten se, että jotkut twiittaajat käyttävät twiiteissään kahta kieltä. Ei-englantilaiselle käyttäjälle, jolla on myös englanninkielisiä seuraajia, kieli onkin ongelma. Yksi vaihtoehto on ylläpitää kahta erikielistä tiliä, mutta kankeaa sekin on. Twitter tarjoaa lukijalle automaattista käännösapua, mikä toimii aika mukavasti, mutta yhtä kaikki kieli ei ole ihan pikkujuttu.


```
make_body <- function(tw){
  list(
    text = tw,
    limit = 3
  ) -> body
  return(body)
}

resp <- httr::RETRY(verb = "POST",
                    url = paste0("https://ai.finto.fi/v1/projects/", project, "/suggest"),
                    body = make_body(tweet),
                    user_agent("https://github.com/tts/minatutkintweets"))
```

Kaikkien twiittien asiasanoitus tarkoittaa toistuvaa rajapinnan kutsua. Finto AI:n käyttöohjeissa toivotaan, ettei rajapintaa pommitettaisi samanaikaisilla kutsuilla, mikä on ymmärrettävää. Rajapinta on toistaiseksi täysin avoin, mitään rekisteröintiä ei ole. Otin yhteyttä Finton asiakaspalveluosoitteeseen, kun aloin epäillä koodini aiheuttavan ongelmia. Yritin näet lisätä kutsujen väliin `Sys.sleep()` -kutsun, mutta en sittenkään onnistunut löytämään sille toimivaa koloa; kutsut palauttivat tyhjää. Finton vastaus oli rauhoittava: he eivät olleet huomanneet palvelussa mitään epänormaalia kuormitusta.

Kutsuihin ja tulosten parsimiseen lainasin ison osan vastaavasta koodista [roadoi](https://github.com/ropensci/roadoi)-kirjastolta, joka on osa [rOpenSci-yhteisön](https://ropensci.org/) piirissä ylläpidettävistä monista työkaluista. Minulla oli ilo olla mukana roadoin [review-prosessissa](https://github.com/ropensci/software-review/issues/115). Siinä keskityin toiminnallisuuteen ja opasteisiin, nyt hyödynsin kirjastoa ensimmäistä kerran kooditasolla. Kysyin Najko Jahnilta, [mihin hän asettaisi paussin](https://github.com/ropensci/roadoi/issues/33). Najko ehdotti, että vaihtaisin `httr`:n tilalle kirjaston [httr2](https://httr2.r-lib.org/). Tutustumisen paikka. Samoin se, miten vaihtaa `plyr::llply` modernimpaan `purrr::map*`-funktioon, jotta toisteisuus koodissa vähenisi.

Miten Finto AI onnistuu? Sitä voi testata twiittikohtaisesti tässä pienessä [apupalvelussa](https://ttso.shinyapps.io/minatutkintweets/). Valitse ensin jokin syyskuun päivistä (6-12), sen jälkeen yksi sen twiiteistä, kokeile vaihtaa palautettavien asiasanojen lukumäärää - ja klikkaa Hae!-nappia. Tulos palautuu muutamassa sekunnissa. Tässä omassa harjoitelmassani käytin kolmea asiasanaa, eikä kynnysarvoa ollut. Finto AI tarjoaa omavalintaiselle tekstille [tämän webbisivun](https://ai.finto.fi/).

Asiasanoituksen koodi on tiedostossa [finto_ai_keywording.R](https://github.com/tts/minatutkintweets/blob/main/finto_ai_keywording.R) ja interaktiivisen [Shiny](https://github.com/rstudio/shiny)-applikaation tiedostossa [app.R](https://github.com/tts/minatutkintweets/blob/main/app.R)

### Ryhmittely

Idea tähän koko harjoitukseen tuli Helsingin yliopiston Ekosysteemit ja ympäristö -tutkimusohjelman professori Sakari Kuikalta. Hän [ehdotti puolileikillään](https://twitter.com/Sakari_Kuikka/status/1435905714455814148), että twiittien perusteella katsottaisiin

>mitkä tieteen alat tulivat esiin, paljonko ne saivat kannatusta ja kuinka suuri niiden rahoitusosuus Suomessa on?

Miten erottaa twiittien vapaasta kielenkäytöstä tieteenala? Ei mitenkään ilman luonnollisen kielen käsittelyn menetelmiä ja erityisesti taitoja. Seuraavalla #minätutkin-kierroksella tutkijoiden pitää käyttää twiiteissään Tilastokeskuksen tieteenalaluokitusta!

Vakavasti puhuen oma tavoitteeni oli saada aikaan visualisointi siitä, mistä aiheista suunnilleen twiitattiin ja mitkä niiden suhteet olivat päivittäin. Pelkkien asiasanojen käyttö ei tässä kohtaa tuntunut järkevältä. Niitä tulee liikaa. Olisin voinut pysyä tiukasti yhden asiasanan politiikassa per twiitti, jolloin kirjo olisi ollut pienempi, mutta siinä olisi luultavasti menetetty iso osa twiittien sisällöstä. Sitä paitsi ensimmäinen asiasana voi olla täydellinen huti.

Finto-palvelu yllättää monipuolisuudellaan. En edes heti äkännyt, mitä kaikkea on tarjolla. Niinpä tartuin ensimmäiseen löydökseen ja hain asiasanoille yhtä tasoa yleisemmän termin (broader term). Niitä parsiessa ja ryhmitellessä kävin vielä kerran läpi vaihtoehtoja ja kas, sanastokohtaisista metodeista löytyi rajapinta [get_vocid_data](https://api.finto.fi/doc/#!/Vocabulary45specific32methods/get_vocid_data), joka palauttaa mm. asiasanan [käsiteryhmän](https://finto.fi/yso/fi/groups). Niitäkin on paljon, mutta luonnollisesti huomattavan paljon vähemmän kuin asiasanoja.

Tämän osuuden koodi on tiedostossa [finto_ontology.R](https://github.com/tts/minatutkintweets/blob/main/finto_ontology.R).

### Visualisointi

Olen seurannut R-ekosysteemin viikottaista [#tidytuesday](https://github.com/rfordatascience/tidytuesday)-projektia. Viikolla 37 julkaistu datasetti käsitteli USA:n [Billboard Top 100](https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-09-14/readme.md) -listaa. Sen visualisoinneista osui silmiini Georgios Karamanisin visuaalisesti näyttävä [toteutus](https://github.com/gkaramanis/tidytuesday/tree/master/2021/2021-week37), jossa vaaka-akselilla on vuosi ja pystyakselilla pylväsgraafi musiikkityylien suhteellisista osuuksista kunakin vuonna. 

Karamanisin graafissa tyylilajit olivat nimen mukaisessa aakkosjärjestyksessä. 

![kuva1](/post/yyyy-mm-dd-mina-tutkin.fi_files/kuva1.png)
*Kuvateksti.*

para

![kuva2](/post/yyyy-mm-dd-mina-tutkin.fi_files/kuva2.png)
*Kuvateksti.*

para

### Päätelmiä

para

para