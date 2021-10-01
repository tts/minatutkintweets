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

Päätin tehdä epätieteellisen tutkimuksen siitä, miten Kansalliskirjaston [Finto AI -rajapintapalvelu](https://www.kiwi.fi/pages/viewpage.action?pageId=165380606) palvelisi twiittien automaattisessa asiasanoituksessa ja [Finto API](https://api.finto.fi/) näiden asiasanojen ryhmittelyssä pääluokkiin. Heti alkuun on muistutettava siitä, että Finto AI on toistaiseksi vain suosittelija; ihmisen on tarkoitus tehdä lopulliset asiasanavalinnat. Tässä harjoituksessa annan kuitenkin mennä täysautomaatilla, kädet poissa ratilta. 

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

Osa tutkijoista postitti useita #minätutkin-twiittejä. Joiltakin oli unohtunut ensimmäisestä aihetunniste - jolloin se ei siis tarttunut haaviini - jotkut halusivat täydentää, eräät taas jatkoivat aiheen parissa muulla tavoin, innostaen kolleegoita tulemaan mukaan jne. Yhdistin nämä kaikki jatkokäsittelyä varten. Jälkiviisastellen olisi ollut fiksua päätellä näistä se "päätwiitti" (ehkä ajallisesti ensimmäinen), jotta yleiskielen määrä olisi pysynyt minimissä. Variaatio oli kuitenkin niin suurta ettei maksanut vaivaa.

Tämän osuuden koodi on tiedostossa [gettweets.R](https://github.com/tts/minatutkintweets/blob/main/gettweets.R)

### Asiasanoitus

para

Koodia:

```
library(tidyverse)
sdfsdf
```

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