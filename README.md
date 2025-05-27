# PewPew Logs - Ampumapäiväkirja

## Sisällysluettelo
1.  [Yleiskatsaus](#1-yleiskatsaus)
2.  [Ominaisuudet](#2-ominaisuudet)
3.  [Teknologiat](#3-teknologiat)
4.  [Arkkitehtuuri & Käyttöönotto](#4-arkkitehtuuri--käyttöönotto)
5.  [Paikallinen Kehitys](#5-paikallinen-kehitys)
6.  [Testaus](#6-testaus)
7.  [Lisenssi](#7-lisenssi)

---

## 1. Yleiskatsaus

PewPew Logs on henkilökohtainen ampumapiväkirja, joka on suunniteltu ampujille. Sen avulla voit kirjata ja seurata ampumaistuntojasi, hallita asevarastoasi ja analysoida suorituskykyäsi ajan mittaan. Tavoitteena on tarjota intuitiivinen alusta, joka auttaa ampujia kehittymään ja pysymään ajan tasalla harrastuksestaan.

## 2. Ominaisuudet (MVP)

* **Käyttäjähallinta:**
    * Rekisteröinti ja sisäänkirjautuminen (JWT-pohjainen autentikointi).
    * Profiilin tarkastelu.
* **Ampumaistuntojen hallinta:**
    * Uusien istuntojen kirjaaminen kattavilla tiedoilla (päivämäärä, ampumarata, ase, laukausmäärä, tyyppi, laji, rooli, sää, muistiinpanot, tulokset).
    * Valinnaisten kenttien laajentaminen/piilottaminen lomakkeella.
    * Istuntojen tarkastelu listana.
    * Istunnon tallentaminen "mallina" (kopioi arvot uuteen istuntoon).
* **Aseiden hallinta:**
    * Aseiden lisääminen ja hallinta (nimi, tyyppi, kaliiberi, ERVA, ostopäivä, muistiinpanot).
    * Aseen tyypin ja kaliiberin valinta alasvetovalikoista.
    * Ampumatyypin automaattinen täyttyminen aseen kaliiberin perusteella.
* **Ampumaratojen hallinta:**
    * Ampumaratojen lisääminen (nimi, osoite, puhelin, verkkosivusto, muistiinpanot).
    * Sijainnin paikannus kartalta (OpenStreetMap / Leaflet).
    * Osoitehaku ja käänteinen geokoodaus (Nominatim).
    * Ampumaratojen tarkastelu listana laajennettavilla tiedoilla ja kartalla.
* **Tilastot:**
    * Yleiset tilastot ja laukausmäärät asetyypeittäin.
* **Käyttökokemus:**
    * Responsiivinen käyttöliittymä (pöytäkone: staattinen sivupalkki, mobiili: alapalkki).
    * Suomenkielinen käyttöliittymä.

## 3. Teknologiat

### Frontend
* **Vue.js 3:** Progressiivinen JavaScript-viitekehys käyttöliittymien rakentamiseen.
* **Vite:** Rakennustyökalu nopeaan kehitykseen.
* **Tailwind CSS:** Järjestelmä nopeaan ja responsiiviseen käyttöliittymän tyylittelyyn.
* **Vue Router 4:** Reititykseen.
* **Axios:** HTTP-pyyntöihin backendille.
* **Leaflet.js & @vue-leaflet/vue-leaflet:** Interaktiivisten karttojen toteuttamiseen.

### Backend
* **Node.js:** JavaScript-ajoympäristö.
* **Express.js:** Nopea ja joustava Node.js-verkkosovelluskehys.
* **Mongoose:** MongoDB-objektimallinnustyökalu Node.js:lle.
* **bcryptjs:** Salasanojen hashaukseen.
* **jsonwebtoken:** Käyttäjän autentikointiin (JWT).
* **cors:** CORS-käytäntöjen sallimiseen.
* **dotenv:** Ympäristömuuttujien lataamiseen paikallisessa kehityksessä.

### Tietokanta
* **MongoDB:** NoSQL-dokumenttitietokanta.

### Käyttöönottoalustat (Deployment)
* **MongoDB Atlas:** Tietokannan pilvipalvelu.
* **Render:** Backend API:n isännöinti (ilmaispalvelu).
* **Vercel:** Frontend-sovelluksen isännöinti (ilmaispalvelu).

## 4. Arkkitehtuuri & Käyttöönotto

Sovellus noudattaa tyypillistä client-server-arkkitehtuuria:

```mermaid
C4Context
    title Järjestelmän konteksti - PewPew Logs
    Person(user, "Käyttäjä")
    System(frontend_app, "PewPew Logs Frontend", "Vue.js-sovellus, isännöity Vercelissä")
    System(backend_api, "PewPew Logs Backend API", "Node.js/Express.js-sovellus, isännöity Renderissä")
    SystemDb(mongodb_atlas, "MongoDB Atlas", "Pilvipohjainen NoSQL-tietokanta")
    System_Ext(nominatim_api, "OpenStreetMap Nominatim API", "Ulkoinen geokoodauspalvelu")

    Rel(user, frontend_app, "Käyttää")
    Rel(frontend_app, backend_api, "Tekee API-kutsuja (HTTP/HTTPS)")
    Rel(backend_api, mongodb_atlas, "Lukee ja kirjoittaa dataa (MongoDB-ajuri)")
    Rel(frontend_app, nominatim_api, "Hakee osoitetietoja (HTTP/HTTPS)")