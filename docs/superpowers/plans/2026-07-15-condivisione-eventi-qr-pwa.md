# Condivisione agli eventi (QR + PWA leggera) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rendere Roadie Runner immediato da condividere agli eventi via QR code, con "Aggiungi a Home" che dà un'app Blearred a schermo intero con icona brandizzata, e pubblicare tutto online con un comando.

**Architecture:** Il gioco resta un singolo `index.html` statico su GitHub Pages. Aggiungiamo asset di contorno (icona PNG, `manifest.json`, QR, cartolina) e i meta/link PWA nell'`<head>`. Il deploy avviene copiando i soli file pubblici in un clone del repo pubblico (`.deploy/`, ignorato da git) e facendo push — così le note interne restano private.

**Tech Stack:** HTML/CSS/JS vanilla; `qlmanage`+`sips` (rasterizzazione SVG→PNG, built-in macOS); Python `segno` (QR, pure-python); git + credential-osxkeychain (deploy, built-in macOS).

## Global Constraints

- Nessuna dipendenza di build; il gioco resta `index.html` (asset PWA a fianco, non un build step).
- **Niente service worker / offline** (escluso su richiesta).
- Nessun backend nuovo: classifica Firebase invariata.
- Palette brand: sfondo `#0a0a0f`, accento magenta `#ff3860`, oro `#f5b301`.
- URL pubblico target: `https://blearredadmin.github.io/roadie-runner/`
- Repo pubblico: `blearredadmin/roadie-runner` (GitHub Pages, branch `main`, root).
- **Verifica**: non esiste framework di test; ogni task si verifica visivamente nel browser / ispezionando i file generati. Le "verifiche" sono passi espliciti qui sotto.

---

### Task 1: Icona Blearred (SVG su misura → PNG)

**Files:**
- Create: `assets/icon.svg`
- Create (generati): `assets/icon-master.png`, `assets/icon-512.png`, `assets/icon-192.png`, `assets/icon-180.png`

**Interfaces:**
- Produces: i file `assets/icon-180.png` (apple-touch), `assets/icon-192.png`, `assets/icon-512.png` usati dal Task 2 (meta + manifest).

- [ ] **Step 1: Creare `assets/icon.svg`**

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <defs>
    <radialGradient id="bg" cx="50%" cy="28%" r="85%">
      <stop offset="0%" stop-color="#1b1422"/>
      <stop offset="100%" stop-color="#0a0a0f"/>
    </radialGradient>
    <linearGradient id="beam" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ff3860" stop-opacity="0.85"/>
      <stop offset="100%" stop-color="#ff3860" stop-opacity="0"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#bg)"/>
  <!-- fascio luce (spotlight) -->
  <polygon points="256,116 156,392 356,392" fill="url(#beam)"/>
  <!-- testa mobile (fixture) in alto -->
  <rect x="234" y="92" width="44" height="28" rx="7" fill="#f5b301"/>
  <circle cx="256" cy="120" r="11" fill="#ffffff"/>
  <!-- pavimento palco -->
  <rect x="96" y="392" width="320" height="9" rx="4" fill="#ff3860"/>
  <!-- roadie che corre (silhouette bold, oro) -->
  <g stroke="#f5b301" stroke-width="17" stroke-linecap="round" stroke-linejoin="round" fill="none">
    <line x1="258" y1="272" x2="242" y2="322"/>
    <polyline points="242,322 280,330 288,384"/>
    <polyline points="242,322 212,352 224,386"/>
    <polyline points="253,288 290,300 296,276"/>
    <polyline points="253,288 218,296 208,272"/>
  </g>
  <circle cx="264" cy="250" r="21" fill="#f5b301"/>
  <!-- wordmark -->
  <text x="256" y="446" text-anchor="middle" font-family="Helvetica, Arial, sans-serif" font-weight="700" font-size="30" letter-spacing="4" fill="#e8e8e8">BLEARRED</text>
</svg>
```

- [ ] **Step 2: Rasterizzare a master 1024px con qlmanage**

```bash
cd "/Users/ivanmacair/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner"
qlmanage -t -s 1024 -o assets assets/icon.svg
mv assets/icon.svg.png assets/icon-master.png
```
Expected: creato `assets/icon-master.png` (~1024×1024, sfondo scuro pieno, roadie oro visibile). Se qlmanage rende male il testo/gradienti, annotarlo: il fallback è aprire l'SVG nel browser e fare uno screenshot, ma di norma qlmanage basta.

- [ ] **Step 3: Ridimensionare nelle misure finali con sips**

```bash
cd "/Users/ivanmacair/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner"
sips -z 512 512 assets/icon-master.png --out assets/icon-512.png
sips -z 192 192 assets/icon-master.png --out assets/icon-192.png
sips -z 180 180 assets/icon-master.png --out assets/icon-180.png
```
Expected: tre PNG creati senza errori.

- [ ] **Step 4: Verifica visiva**

```bash
open assets/icon-512.png assets/icon-180.png
```
Expected: icona leggibile anche a 180px (roadie riconoscibile, "BLEARRED" leggibile o comunque estetico), sfondo pieno (no trasparenza). Se non convince, ritoccare l'SVG (colori/posizioni) e rifare Step 2-3 prima di procedere.

- [ ] **Step 5: Commit**

```bash
cd "/Users/ivanmacair/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner"
git add assets/icon.svg assets/icon-master.png assets/icon-512.png assets/icon-192.png assets/icon-180.png
git commit -m "feat: icona app Blearred (SVG + PNG 180/192/512)"
```

---

### Task 2: PWA — manifest + meta tag + icona in index.html

**Files:**
- Create: `manifest.json`
- Modify: `index.html` (dentro `<head>`, dopo i meta apple esistenti — attorno alla riga 8)

**Interfaces:**
- Consumes: `assets/icon-180.png`, `assets/icon-192.png`, `assets/icon-512.png` (Task 1).
- Produces: sito installabile (Add to Home) usato nella verifica del Task 4.

- [ ] **Step 1: Creare `manifest.json`**

```json
{
  "name": "Roadie Runner",
  "short_name": "Roadie Runner",
  "description": "L'endless runner brandizzato Blearred: corri sul palco e salta gli ostacoli del backstage.",
  "start_url": "./index.html",
  "scope": "./",
  "display": "standalone",
  "orientation": "portrait",
  "background_color": "#0a0a0f",
  "theme_color": "#0a0a0f",
  "icons": [
    { "src": "assets/icon-192.png", "sizes": "192x192", "type": "image/png", "purpose": "any maskable" },
    { "src": "assets/icon-512.png", "sizes": "512x512", "type": "image/png", "purpose": "any maskable" }
  ]
}
```

- [ ] **Step 2: Aggiungere i meta/link nell'`<head>` di `index.html`**

Individuare il blocco (righe 6-8):

```html
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
```

Subito DOPO quella terza riga, inserire:

```html
<meta name="apple-mobile-web-app-title" content="Roadie Runner">
<meta name="theme-color" content="#0a0a0f">
<link rel="apple-touch-icon" href="assets/icon-180.png">
<link rel="manifest" href="manifest.json">
```

- [ ] **Step 3: Verifica in locale (server già usato dal progetto)**

```bash
cd "/Users/ivanmacair/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner"
python3 -m http.server 8765 >/dev/null 2>&1 &
open "http://localhost:8765/index.html"
```
Verifica: in Chrome DevTools → Application → Manifest, il manifest carica senza errori, mostra nome "Roadie Runner", `display: standalone`, e le due icone 192/512 senza warning "Failed to load". La `apple-touch-icon` risponde 200 (Network). Il gioco funziona come prima.

- [ ] **Step 4: (Se manifest inline/icone danno warning) nessuna azione**

I file sono separati (non inline) → niente problema di data-URI. Se un'icona dà warning, ricontrollare i path relativi (`assets/...`).

- [ ] **Step 5: Commit**

```bash
cd "/Users/ivanmacair/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner"
git add manifest.json index.html
git commit -m "feat: PWA leggera (manifest, apple-touch-icon, theme-color)"
```

---

### Task 3: QR code + cartolina stampabile

**Files:**
- Create (generati): `assets/qr.png`, `assets/qr.svg`
- Create: `assets/cartolina.html`

**Interfaces:**
- Consumes: URL pubblico `https://blearredadmin.github.io/roadie-runner/`.
- Produces: `assets/qr.png` usato dalla cartolina; nessun consumo a valle (asset locali, non deployati).

- [ ] **Step 1: Installare segno (pure-python, nessuna dipendenza di sistema)**

```bash
python3 -m pip install --user segno
```
Expected: "Successfully installed segno-...". Se pip non c'è: `python3 -m ensurepip --user` poi ripetere.

- [ ] **Step 2: Generare il QR verso il link pubblico**

```bash
cd "/Users/ivanmacair/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner"
python3 - <<'PY'
import segno
url = "https://blearredadmin.github.io/roadie-runner/"
q = segno.make(url, error='m')
q.save("assets/qr.png", scale=14, border=2, dark="#0a0a0f", light="#ffffff")
q.save("assets/qr.svg", scale=14, border=2, dark="#0a0a0f", light="#ffffff")
print("QR creato")
PY
```
Expected: "QR creato"; esistono `assets/qr.png` e `assets/qr.svg`.

- [ ] **Step 3: Verifica scansione**

```bash
open assets/qr.png
```
Inquadrare con la fotocamera dell'iPhone: deve aprire il link del gioco. Se non legge, aumentare `scale` o `border` e rigenerare.

- [ ] **Step 4: Creare `assets/cartolina.html` (stampabile)**

```html
<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<title>Roadie Runner — Cartolina</title>
<style>
  @page { size: A6 portrait; margin: 0; }
  * { box-sizing: border-box; }
  body { margin: 0; font-family: -apple-system, "Helvetica Neue", Arial, sans-serif; }
  .card {
    width: 105mm; height: 148mm; margin: 0 auto;
    background: radial-gradient(120% 80% at 50% 20%, #1b1422 0%, #0a0a0f 100%);
    color: #e8e8e8; display: flex; flex-direction: column;
    align-items: center; justify-content: space-between;
    padding: 10mm 8mm; text-align: center;
  }
  h1 { margin: 0; font-size: 26px; letter-spacing: 2px; color: #ff3860; }
  .sub { margin: 4px 0 0; font-size: 13px; color: #f5b301; letter-spacing: 3px; }
  .qr { background: #fff; padding: 6mm; border-radius: 10px; }
  .qr img { width: 55mm; height: 55mm; display: block; }
  .cta { font-size: 17px; font-weight: 700; }
  .cta small { display: block; font-weight: 400; font-size: 12px; color: #b8b8c0; margin-top: 3px; }
  .brand { font-size: 12px; letter-spacing: 4px; color: #888; }
  @media screen { body { background: #333; padding: 20px; } }
</style>
</head>
<body>
  <div class="card">
    <div>
      <h1>ROADIE RUNNER</h1>
      <p class="sub">BLEARRED</p>
    </div>
    <div class="qr"><img src="qr.png" alt="QR Roadie Runner"></div>
    <div>
      <p class="cta">Inquadra e gioca<small>Salta gli ostacoli del backstage. Batti il record!</small></p>
    </div>
    <p class="brand">B L E A R R E D</p>
  </div>
</body>
</html>
```

- [ ] **Step 5: Verifica stampa**

```bash
open assets/cartolina.html
```
Nel browser: Cmd+P → dimensione A6 (o "Adatta"), il QR è nitido e centrato. Salvare come PDF di prova. Deve risultare stampabile.

- [ ] **Step 6: Commit**

```bash
cd "/Users/ivanmacair/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner"
git add assets/qr.png assets/qr.svg assets/cartolina.html
git commit -m "feat: QR code + cartolina stampabile per eventi"
```

---

### Task 4: Deploy con un comando + pubblicazione live

**Files:**
- Create: `publish.sh`
- Modify: `.gitignore` (aggiungere `.deploy/`)

**Interfaces:**
- Consumes: `index.html`, `manifest.json`, `assets/icon-180.png`, `assets/icon-192.png`, `assets/icon-512.png` (Task 1-2).
- Produces: sito live aggiornato su GitHub Pages; comando ripetibile `./publish.sh`.

> **Nota deploy:** copiamo SOLO i file pubblici in un clone del repo pubblico (`.deploy/`), così docs/spec/note interne NON finiscono online. La cartolina e i sorgenti (`icon.svg`, `qr.*`, `icon-master.png`) restano locali.

- [ ] **Step 1: Ignorare la cartella di deploy**

Aggiungere in coda a `.gitignore`:

```
.deploy/
```

- [ ] **Step 2: Creare `publish.sh`**

```bash
#!/bin/bash
set -e
cd "$(dirname "$0")"
REPO_URL="https://github.com/blearredadmin/roadie-runner.git"
DEPLOY=".deploy"

# Clone del repo pubblico al primo uso (il clone è pubblico, non serve auth)
if [ ! -d "$DEPLOY/.git" ]; then
  git clone "$REPO_URL" "$DEPLOY"
fi

# Allinea il clone al remoto
git -C "$DEPLOY" fetch origin
git -C "$DEPLOY" reset --hard origin/main

# Copia SOLO i file pubblici
cp index.html "$DEPLOY/"
cp manifest.json "$DEPLOY/"
mkdir -p "$DEPLOY/assets"
cp assets/icon-180.png assets/icon-192.png assets/icon-512.png "$DEPLOY/assets/"

# Commit + push
cd "$DEPLOY"
git add -A
if git diff --cached --quiet; then
  echo "Niente da pubblicare (già aggiornato)."
else
  git commit -m "deploy: aggiornamento gioco ($(date '+%Y-%m-%d %H:%M'))"
  git push origin main
  echo "Pubblicato. Attendi ~1 min, poi hard-refresh (Cmd+Shift+R)."
fi
```

- [ ] **Step 3: Renderlo eseguibile**

```bash
cd "/Users/ivanmacair/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner"
chmod +x publish.sh
```

- [ ] **Step 4: Configurare l'autenticazione GitHub (una volta sola, con Ivan)**

Il push richiede scrittura su `blearredadmin/roadie-runner`. Senza `gh`/`brew`, usiamo un Personal Access Token salvato nel Portachiavi macOS (built-in):

1. Abilitare l'helper keychain (built-in):
   ```bash
   git config --global credential.helper osxkeychain
   ```
2. **Ivan** crea un token dall'account con permesso di scrittura sul repo:
   GitHub → Settings → Developer settings → **Personal access tokens → Fine-grained tokens** → Generate:
   - Repository access: *Only select repositories* → `blearredadmin/roadie-runner`
   - Permissions → Repository → **Contents: Read and write**
   - Copiare il token (`github_pat_...`).
3. Al primo `git push`, quando chiede username/password: username = `blearredadmin` (o l'account collaboratore), password = **il token**. Verrà salvato nel Portachiavi (non lo richiederà più).

> Se Ivan preferisce, in alternativa si può installare Homebrew + `gh` più avanti; per ora il token è la via senza installazioni.

- [ ] **Step 5: Primo deploy (pubblica TUTTO il pendente: classifica Top 10 + PWA)**

```bash
cd "/Users/ivanmacair/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner"
./publish.sh
```
Expected: clone di `.deploy`, commit, push riuscito (prima volta chiede il token). Messaggio "Pubblicato".

- [ ] **Step 6: Verifica live (criteri di successo della spec)**

Dopo ~1 minuto:
```bash
open "https://blearredadmin.github.io/roadie-runner/"
```
1. Hard refresh (Cmd+Shift+R): si vede la **classifica Top 10** (versione aggiornata online).
2. Su iPhone: apri il link → Condividi → **Aggiungi a Home** → compare l'**icona Blearred** e il nome "Roadie Runner"; aprendola parte a **schermo intero**.
3. Il **QR** (`assets/qr.png`) inquadrato apre il gioco live.

- [ ] **Step 7: Commit dello script**

```bash
cd "/Users/ivanmacair/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner"
git add publish.sh .gitignore
git commit -m "chore: publish.sh per deploy con un comando su GitHub Pages"
```

- [ ] **Step 8: Aggiornare STATO-LAVORO.md**

Segnare come FATTO: pubblicazione classifica Top 10, PWA/icona, QR, deploy con un comando. Rimuovere dai "In sospeso" i punti #1 (pubblicare) risolti. Commit:

```bash
git add STATO-LAVORO.md
git commit -m "docs: stato lavoro dopo condivisione eventi (QR+PWA) online"
```

---

## Note di ordine e dipendenze

- Ordine obbligato: **Task 1 → Task 2 → Task 4** (il deploy usa icona+manifest). **Task 3** (QR/cartolina) è indipendente ma va prima del Task 4 solo se si vuole verificare il QR sul live; il QR punta all'URL, non ai file, quindi può anche stare in parallelo.
- Il Task 4 Step 4 è **interattivo** (richiede il token di Ivan): fermarsi lì e coinvolgerlo.
