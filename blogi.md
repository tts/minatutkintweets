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

Syyskuun alussa 2021 Twitterin aihetunniste *minätutkin* oli suosittu. Tutkijat innostuivat tiivistämään työnsä twiitin merkkimäärään ja suuri yleisö innostui yhtä lailla lukemastaan. Vaikka Suomesta löytyy ajantasaisia sivustoja tutkimuksesta, uusimpana [tutkimustietovaranto](https://www.tiedejatutkimus.fi/fi/), niiden varsinainen fokus ei ole tehdä tiedettä helposti lähestyttäväksi. Toki ne saattavat onnistua siinäkin, mutta vain välillisesti.

Mistä sitten twiitattiin? Mitä olivat ne tieteenalat, joiden tutkijat ehtivät tai kiinnostuivat twiittaamaan? Millä termeillä aloja kuvattiin? 

Päätin tehdä epätieteellisen tutkimuksen siitä, miten Kansalliskirjaston [Finto AI -rajapintapalvelu](https://www.kiwi.fi/display/Finto/Finto+AI%3An+rajapintapalvelu) palvelisi twiittien automaattisessa asiasanoituksessa ja [Finto API](https://api.finto.fi/) näiden asiasanojen ryhmittelyssä pääluokkiin. Heti alkuun on muistutettava siitä, että Finto AI on toistaiseksi vain suosittelija; ihmisen on tarkoitus tehdä lopulliset asiasanavalinnat. Näin toimitaan mm. Jyväskylän yliopistossa, jossa opiskelijat hakevat rajapinnan web-liittymän kautta asiasanoja, valitsevat niistä sopivat (tai keksivät omat), ja lopuksi kirjasotonhoitaja hyväksyy ne. Tässä harjoituksessa annan kuitenkin mennä täysautomaatilla, kädet poissa ratilta. 

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

Osa tutkijoista postitti useita #minätutkin-twiittejä. Joiltakin oli unohtunut ensimmäisestä aihetunniste - jolloin se ei siis tarttunut haaviini - jotkut halusivat täydentää, eräät taas jatkoivat aiheen parissa muulla tavoin, innostaen kolleegoita tulemaan mukaan jne. Yhdistin nämä kaikki jatkokäsittelyä varten. Jälkiviisastellen olisi ollut fiksua päätellä näistä se "päätwiitti" (ehkä ajallisesti ensimmäinen), jotta yleiskielen määrä olisi pysynyt minimissä. Muuntelu oli kuitenkin niin suurta ettei maksanut vaivaa.

Tämän osuuden koodi on tiedostossa [gettweets.R](https://github.com/tts/minatutkintweets/blob/main/gettweets.R)

### Asiasanoitus

Finto AI -rajapintapalvelulle lähetetään asiasanoitettava teksti HTTP POST -kutsussa. Palautettavien asiasanojen lukumäärää voi säätää (limit), samoin niiden osumistarkkuutta (threshold). Lisäksi URL:ssa on oltava tieto projektista eli käytännössä siitä, minkä kielisestä tekstistä on kyse. Palvelulla on interaktiivinen [hiekkalaatikko](https://ai.finto.fi/v1/ui/).

En osaa sanoa, kuinka luotettava Twitterin palauttama `lang`-arvo on, mutta joka tapauksessa käytin sitä. Satunnaisotannalla se näytti kertovan totta. Toinen asia on sitten se, että jotkut twiittaajat käyttävät twiiteissään kahta kieltä. Ei-englantilaiselle käyttäjälle, jolla on myös englanninkielisiä seuraajia, kieli onkin jatkuva päänsärky. Yksi vaihtoehto on ylläpitää kahta erikielistä tiliä, mutta kankeaa se on. Twitter tarjoaa kylläkin automaattista käännösapua lukijalle, mikä toimiikin melko mukavasti.


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

Kaikkien twiittien asiasanoitus tarkoittaa toistuvaa rajapinnan kutsua. Finto AI:n käyttöohjeissa toivotaan, ettei rajapintaa pommitettaisi samanaikaisilla kutsuilla, mikä on ymmärrettävää. Rajapinta on toistaiseksi täysin avoin, mitään rekisteröintiä ei ole. Otin yhteyttä Finton asiakaspalveluosoitteeseen, kun aloin epäillä koodini aiheuttavan ongelmia. Yritin näet lisätä kutsujen väliin `Sys.sleep()` -kutsun, mutta en sittenkään onnistunut löytämään sille toimivaa koloa; kutsut palauttivat tyhjää. Finton vastaus oli rauhoittava: he eivät olleet huomanneet palvelussa mitään kuormitusta.

Kutsujen käsittelyyn lainasin ison osan vastaavasta koodista [roadoi](https://github.com/ropensci/roadoi)-kirjastolta, joka on osa [rOpenSci-yhteisön](https://ropensci.org/) piirissä ylläpidettävistä monista työkaluista. Minulla oli kunnia olla mukana roadoin [review-prosessissa](https://github.com/ropensci/software-review/issues/115). Siinä keskityin toiminnallisuuteen ja opasteisiin, nyt hyödynsin kirjastoa ensimmäistä kerran kooditasolla. Kysyin Najko Jahnilta, [mihin hän asettaisi paussin](https://github.com/ropensci/roadoi/issues/33). Najko ehdotti, että vaihtaisin `httr`:n tilalle modernimman kirjaston [httr2](https://httr2.r-lib.org/). Tutustumisen paikka.

*Jos toistat saman asian kolmesti, tee funktio* on tuttu toteama. Kolme kieltä, kolme toistoa. Ensi kerralla sitten funktio :)

Asiasanoituksen koodi on tiedostossa [finto_ai_keywording.R](https://github.com/tts/minatutkintweets/blob/main/finto_ai_keywording.R)

### Ryhmittely ja visualisointi

para

![kuva1](/post/yyyy-mm-dd-mina-tutkin.fi_files/kuva1.png)
*Kuvateksti.*

para

![kuva2](/post/yyyy-mm-dd-mina-tutkin.fi_files/kuva2.png)
*Kuvateksti.*

para

### Päätelmiä

para

para