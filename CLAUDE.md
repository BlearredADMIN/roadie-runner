# Blearred RoadieRunner

## Chi è Ivan
Ivan è co-founder di **Blearred** (eventi, light design, service per spettacoli).
Lavora in italiano. Vedi anche la memoria persistente di Claude.

## Cos'è questo progetto
**Roadie Runner** è un mini videogioco endless-runner (stile "dino di Chrome") a
tema Blearred. Il giocatore è un **roadie** che corre sul palco e deve saltare
gli ostacoli del backstage. È un gioco-gadget brandizzato, pensato per girare al
volo su iPhone (web app a schermo intero) e da condividere.

## Com'è fatto (tecnico)
- **Un solo file**: `index.html` — HTML + CSS + JavaScript, nessuna dipendenza
  esterna, nessun build. Si apre con doppio clic nel browser.
- Reso su `<canvas>` 400×700 con `requestAnimationFrame`.
- Mobile-first: meta tag per web-app a tutto schermo iOS, gestione
  `safe-area-inset`, blocco pinch-zoom, input unificato `pointerdown` con
  de-dup anti doppio-tap iOS (vedi commento nel codice).

### Meccaniche di gioco
- **Comandi**: tocca lo schermo (o `Spazio`/`↑` da tastiera) per saltare;
  **doppio salto** disponibile in aria. `R` per ricominciare.
- **Punteggio**: cresce nel tempo e con la velocità; record salvato in
  `localStorage` (chiave `roadie_best`).
- **Difficoltà progressiva**: la velocità aumenta ogni ~250 frame fino a 11.
- **Ostacoli a tier** (sbloccati al crescere del punteggio):
  - Tier 1 (<100): cassa (speaker), getto CO₂, strobo, testa mobile, transenna
  - Tier 2 (<250): + flightcase grande (BLEARRED), fiamma, batterista
  - Tier 3 (<450): + trabattello
  - Tier 4 (≥450): + il cantante
  - Unico flightcase rimasto: quello grande brandizzato (`flightcase_l`).
  - **Teste mobili** = ostacolo più frequente (scelta di design).
  - **Strobo** (`strobo`): unico ostacolo aereo "da NON saltare" (ci passi sotto
    correndo), ha sostituito il microfono volante.
- **Pass collezionabili**: laminati BLEARRED (bassi/alti) che danno +50 punti,
  mai letali (vedi `spawnPass` / `drawPasses`).
- Ostacoli **a coppia** con gap calibrato per richiedere il doppio salto.
- Estetica palco: truss, fari colorati animati, stelle, cavi serpentina; sui
  flightcase grandi compare lo stencil **BLEARRED**.

## Come si prova
Doppio clic su `index.html` (o trascinalo in Safari/Chrome). Su iPhone:
"Aggiungi a Home" per giocare a schermo intero.
Per testare la **classifica** in locale serve un mini server (non `file://`):
`python3 -m http.server 8765` poi apri `http://localhost:8765/index.html`.

## Online (pubblicato)
- **URL pubblico:** https://blearredadmin.github.io/roadie-runner/
- **Hosting:** GitHub Pages, repo `blearredadmin/roadie-runner` (Pages = branch `main`, root).
- **Classifica globale:** Firebase Firestore, progetto `roadie-runner`, collezione `scores`
  (`{name, score, ts}`). Regole: lettura pubblica, solo create validato, no update/delete.
  La config web in `index.html` **non è segreta** (sicurezza data dalle regole).
- **Aggiornare il gioco online:** ricaricare `index.html` nel repo GitHub (via web:
  Add file → Upload files, oppure si potrà configurare `gh`/git push più avanti).
- **Cancellare voci farlocche:** dalla console Firebase → Firestore → collezione `scores`.

## Regole / convenzioni
- Il gioco resta **un solo file** (`index.html`), niente build. Da quando c'è la
  classifica ha però una dipendenza CDN (Firebase SDK) e parla con Firestore.
- Conservare **una sola** versione funzionante in cartella (no duplicati sparsi).
- Questo progetto vive in `~/CLAUDE PROJECTS/roadie-runner/` (spostato dalla
  Scrivania il 19/07/2026: era sincronizzata su iCloud, che sfrattava i file `.git`)
  secondo la convenzione descritta nel `README.md` della cartella padre.
- Repo git locale = fonte con storia completa; GitHub = copia pubblicata del solo gioco.
