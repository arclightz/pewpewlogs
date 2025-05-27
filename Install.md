# PewPew Logs - Käyttöönotto-ohjeet

Tämä dokumentti ohjaa sinua PewPew Logs -sovelluksen käyttöönotossa ilmaisilla pilvipalveluilla: MongoDB Atlas tietokannalle, Render.com backendille ja Vercel frontendille.

---

## Esivaatimukset

Ennen käyttöönoton aloittamista varmista, että sinulla on:
* Koko projektikoodi (sisältäen `backend/` ja `frontend/` -kansiot) pushattuna **GitHub-repositorioosi**.
* Tunnukset luotuna seuraaviin palveluihin:
    * [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/lp/try4)
    * [Render](https://render.com/)
    * [Vercel](https://vercel.com/)

---

## 1. MongoDB Atlas - Tietokannan Asennus

MongoDB Atlas tarjoaa ilmaisen pilvipohjaisen MongoDB-tietokannan.

1.  **Luo ilmainen klusteri (M0 Sandbox):**
    * Kirjaudu MongoDB Atlasiin.
    * Valitse "Build a Database" (tai "Create") ja valitse **"Shared" (M0 Sandbox)** -taso, joka on ilmainen.
    * Valitse pilvipalvelun tarjoaja ja alue (esim. AWS, GCP, Azure) lähimpänä kohdeyleisöäsi tai Renderin oletusaluetta.
    * Nimeä klusterisi (esim. `pewpewlogs-cluster`).
    * Hyväksy klusterin luonti.

2.  **Määritä verkkoyhteys:**
    * Kun klusteri on valmistumassa, siirry vasemman sivupalkin kohtaan **"Network Access"**.
    * Napsauta **"ADD IP ADDRESS"**.
    * **Kehitys-/testikäyttöön:** Valitse **"ALLOW ACCESS FROM ANYWHERE" (IP-osoite `0.0.0.0/0`)** ja napsauta "Confirm".
        * **Huom:** Tämä ei ole turvallista tuotantokäytössä. Tuotannossa lisää Render-palvelusi tarkat IP-osoitteet tai käytä VPC Peeringiä.

3.  **Luo tietokantakäyttäjä:**
    * Siirry vasemman sivupalkin kohtaan **"Database Access"**.
    * Napsauta **"ADD NEW DATABASE USER"**.
    * Valitse "Password" todennusmenetelmäksi.
    * Syötä **vahva käyttäjätunnus ja salasana** (esim. `pewpewuser`, `oma_vahva_salasanasi`). **TALLENNA NÄMÄ TIEDOT TURVALLISESTI.**
    * Anna käyttäjälle vähintään "Read and write to any database" -oikeudet.
    * Napsauta "Add User".

4.  **Hae yhteysmerkkijono:**
    * Kun klusterisi on valmis, palaa **"Databases"**-sivulle.
    * Napsauta klusterisi kohdalla **"Connect"** -painiketta.
    * Valitse "Connect your application".
    * Valitse "Node.js" ja kopioi annettu yhteysmerkkijono. Se näyttää suunnilleen tältä:
        `mongodb+srv://<käyttäjätunnus>:<salasana>@klusterinimi.mongodb.net/test?retryWrites=true&w=majority`
    * **MUOKKAA TÄTÄ MERKKIJONOA:**
        * Korvaa `<käyttäjätunnus>` luomasi tietokantakäyttäjänimellä (esim. `pewpewuser`).
        * Korvaa `<salasana>` tietokantakäyttäjän salasanalla.
        * Vaihda `test` sovelluksesi tietokannan nimeksi (esim. `pewpewlogs`).
        * **Lisää `?authSource=admin`** jos käyttäjätunnuksesi on admin-roolissa.
        * **Esimerkki valmiista merkkijonosta:**
            `mongodb+srv://pewpewuser:oma_vahva_salasanasi@pewpewlogs-cluster.degwvjf.mongodb.net/pewpewlogs?authSource=admin&retryWrites=true&w=majority`
    * **TALLENNA TÄMÄ TARKKA MERKKIJONO SEURAAVIA VAIHEITA VARTEN.** Tämä on `MONGODB_URI` -ympäristömuuttujasi Renderille.

---

## 2. Render - Backend API:n Käyttöönotto

Render on erinomainen Node.js-backendien isännöintiin, ja tarjoaa ilmaistason.

1.  **Yhdistä Render GitHubiin:**
    * Kirjaudu Renderiin.
    * Napsauta "New" -> "Web Service".
    * Yhdistä GitHub-tilisi ja valtuuta Render pääsemään repositorioihisi.
    * Valitse `pewpewlogs` -repositorio.

2.  **Määritä uusi Web Service:**
    * **Root Directory:** `backend/` (Kerro Renderille, että backend-koodi on tässä alakansiossa).
    * **Name:** Anna palvelullesi yksilöllinen nimi (esim. `pewpewlogs-api`).
    * **Region:** Valitse alue (esim. `Frankfurt (EU Central)`), mieluiten sama kuin MongoDB Atlas -klusterisi.
    * **Branch:** `develop` (tai `main`, riippuen integraatiohaarastasi).
    * **Runtime:** `Node`
    * **Build Command:** `npm install`
    * **Start Command:** `node src/server.js` (Varmista, että tämä vastaa `backend/package.json`-tiedoston `start`-skriptiä).
    * **Instance Type:** Valitse "Free".
    * **Health Check Path:** `/`

3.  **Aseta ympäristömuuttujat:**
    * Ennen käyttöönottoa siirry "Advanced" -> "Add Environment Variable".
    * Lisää seuraavat:
        * `NODE_ENV`: `production`
        * `MONGODB_URI`: **Liitä tässä MongoDB Atlasista saamasi, MUOKATTU yhteysmerkkijono.**
        * `JWT_SECRET`: Anna vahva, pitkä ja satunnainen merkkijono (esim. `openssl rand -base64 32`). Tämä on kriittistä turvallisuudelle.
        * `PORT`: `10000` (tai mikä tahansa portti, jonka Render ehdottaa/vaatii). Render asettaa tämän automaattisesti, mutta on hyvä olla tietoinen.

4.  **Käynnistä käyttöönotto:**
    * Napsauta "Create Web Service". Render havaitsee automaattisesti `package.json`-tiedostosi ja aloittaa käyttöönoton.
    * Seuraa lokitiedostoja.

5.  **Hae Backend API:n URL-osoite:**
    * Kun käyttöönotto on valmis, Render antaa julkisen URL-osoitteen backend-palvelullesi (esim. `https://pewpewlogs-api.onrender.com`). **TALLENNA TÄMÄ URL-OSOITE.**

---

## 3. Vercel - Frontend-sovelluksen Käyttöönotto

Vercel sopii erinomaisesti staattisten sivustojen ja Vue.js-sovellusten isännöintiin.

1.  **Yhdistä Vercel GitHubiin:**
    * Kirjaudu Verceliin.
    * Napsauta "Add New..." -> "Project".
    * Yhdistä GitHub-tilisi ja valitse `pewpewlogs` -repositorio.

2.  **Tuo Frontend-projekti:**
    * Projektia määritettäessä:
        * **Root Directory:** `frontend/`
        * **Framework Preset:** Vercelin tulisi tunnistaa automaattisesti "Vue" (tai "Vite"). Jos ei, valitse se.
        * **Build Command:** `npm run build`
        * **Output Directory:** `dist` (Tämä on Viten oletustulostushakemisto).

3.  **Aseta ympäristömuuttujat:**
    * Ennen käyttöönottoa siirry projektiasetuksiin kohtaan "Environment Variables".
    * Lisää:
        * `VITE_API_BASE_URL`: **Liitä tähän Render-backend-palvelusi julkinen URL-osoite** (esim. `https://pewpewlogs-api.onrender.com`). **Tämä on kriittistä, jotta frontend tietää minne lähettää API-pyynnöt.**

4.  **Käynnistä käyttöönotto:**
    * Napsauta "Deploy". Vercel rakentaa ja ottaa käyttöön Vue.js-sovelluksesi.

5.  **Hae Frontend-sovelluksen URL-osoite:**
    * Kun käyttöönotto on valmis, Vercel antaa julkisen URL-osoitteen frontend-sovelluksellesi (esim. `https://pewpewlogs-app.vercel.app`).

---

## 4. Käyttöönoton jälkeinen tarkistus

1.  **Testaa Live-sovellusta:**
    * Avaa Vercelin frontend-URL-osoite selaimessasi.
    * Rekisteröi uusi käyttäjä (se käyttää Render-backendiasi ja MongoDB Atlas -tietokantaasi).
    * Kirjaudu sisään, lisää istuntoja, aseita, ampumaratoja ja varmista, että kaikki toiminnot toimivat.

Tämä on kattava ja ilmaistason ystävällinen käyttöönotto-opas, joka erottaa tietokannan, backendiin ja frontendiin omiin palveluihinsa.