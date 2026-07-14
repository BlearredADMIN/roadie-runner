# Stato lavoro — Blearred RoadieRunner

> Diario di bordo. Aggiornare a ogni sessione: Fatto / In corso / Prossimi passi.

## ▶︎ RIPRESA (leggere qui per primo)

**Dove siamo:** gioco completo e **pubblicato online** con classifica globale.
Repo git locale pulito, tutto committato. Workflow usato: superpowers
(brainstorming → spec → plan → execute); spec e piani in `docs/superpowers/`.

- **Link pubblico:** https://blearredadmin.github.io/roadie-runner/
- **Hosting:** GitHub Pages, repo `blearredadmin/roadie-runner` (branch `main`, root).
- **Classifica:** Firebase Firestore, progetto `roadie-runner`, collezione `scores`.

**In sospeso (da fare):**
- ⏳ **Test classifica dal telefono** (cross-dispositivo): aprire il link su iPhone,
  salvare un punteggio, verificare che compaia anche sul Mac.
- ⏳ **Pubblicare online la nuova classifica**: `index.html` aggiornato in locale ma
  NON ancora ricaricato nel repo `blearredadmin/roadie-runner` (il live è indietro).
- ⏳ **(Opzionale) Regole Firestore**: oggi sono create-only → la dedup per nome è
  lato client e i vecchi documenti restano nel DB (invisibili ma si accumulano).
  Per pulizia vera servirebbe consentire update sullo stesso nome (azione console).

**Possibili prossimi passi (non confermati):**
- Configurare `gh`/git push per aggiornare il gioco online con un comando
  (ora si ricarica `index.html` a mano via web su GitHub).
- Audio (salto / game over / musica). Icona app brandizzata.
- Dominio Blearred (es. `game.blearred.com`) al posto del sottodominio github.io.
- Tarature fini: altezze pass, frequenza ostacoli, ritmo strobo.

---

## Aggiornamento 2026-07-14

### Fatto — Classifica High Score ridisegnata (Top 10, un nome per giocatore)
- **Fine partita ridisegnata**: punteggio finale grande e centrale
  ("Il tuo punteggio"), Top 10 accanto (affiancata ≥620px, sotto su mobile),
  pulsante **"🔁 Rigioca"** (evento `roadie:restart` → `reset()` nel gioco).
- **Logica classifica**:
  - Fuori Top 10 → nessun campo nome, solo classifica + riga "TU" evidenziata.
  - Dentro Top 10 con nuovo record → titolo **"🎉 Nuovo High Score!"**;
    la **prima volta** chiede il nome, poi salva in automatico col nome memorizzato.
  - Già in classifica ma senza migliorare → "Il tuo record resta XXX", niente campo.
  - Dopo il salvataggio la Top 10 si aggiorna con **animazione flash** sul record.
- **Un solo record per nome**: `window.LB.top()` legge fino a 100 doc e deduplica
  lato client (max score per nome, case-insensitive); al salvataggio non si
  sovrascrive un punteggio già ≥. Ordinamento sempre desc.
- **Vincolo noto**: regole Firestore create-only → dedup/aggiornamento solo lato
  client; i doc vecchi restano nel DB (nascosti). Vedi "In sospeso".
- Testato in locale (server `python3 -m http.server 8765`) e approvato da Ivan.
  Modalità di lavoro: Superpowers **lite** (diretto, senza spec/piani formali).

**Per riprendere:** `cd` nella cartella del progetto e `claude --continue`
(o `claude --resume`).

---

## Aggiornamento 2026-06-05

### Fatto — Online + classifica globale
- **Gioco pubblicato:** https://blearredadmin.github.io/roadie-runner/
  (GitHub Pages, repo `blearredadmin/roadie-runner`).
- **Classifica globale** con nickname via **Firebase Firestore** (progetto
  `roadie-runner`, collezione `scores`): inserimento nome a ogni game over,
  pannello Top 10, pulsante "🏆 Classifica" in home. Overlay HTML sopra il canvas,
  con guardia che blocca il salto mentre si scrive. Degradazione elegante se offline.
- Testato e funzionante sul Mac (via server locale). Da provare sul telefono col link.

### Fatto — meccaniche/grafica (vedi sotto)
- Aggiunta meccanica **pass backstage collezionabili** (+50 punti a pass,
  bassi da prendere correndo / alti da prendere saltando, **mai letali**),
  laminati brandizzati **BLEARRED** con scintille dorate alla raccolta.
- Implementata con workflow superpowers: brainstorming → spec → piano → esecuzione.
  Spec e piano in `docs/superpowers/`.
- Inizializzato **git** nel progetto: ogni task committato atomicamente.

- **Rinnovati gli ostacoli** per renderli più riconoscibili:
  - Rimossi flightcase piccolo e medio; tenuto solo quello grande **BLEARRED**.
  - Aggiunti: **transenna**, **testa mobile** (faro animato), **batterista**,
    **trabattello**. Tier ribilanciati (vedi `pickObstacleType` e `CLAUDE.md`).
  - **Microfono volante rimosso**, sostituito dalla **strobo** (`strobo`,
    `drawStrobo`): ostacolo aereo lampeggiante, stesso ruolo "da non saltare".
  - **Teste mobili rese più frequenti** in tutti i tier (preferenza di Ivan).

### Nota
- Altezze pass (`GROUND_Y - 130` alto / `GROUND_Y - 40` basso) e cadenza spawn
  (`120 + rnd*120`) in `index.html` (funzione `spawnPass` e blocco pass in
  `update()`): tarabili se il bilanciamento non convince provando.
- Geometrie/animazioni nuovi ostacoli: funzioni `drawTransenna`,
  `drawMovingHead`, `drawDrummer`, `drawScaffold`; taglie in `makeObstacle`.

## Aggiornamento 2026-06-04

### Fatto
- **Riordino cartella**: c'erano 5 copie sparse del gioco. Verificato con
  checksum che 4 erano **byte-identiche** (versione 21 mag, 823 righe,
  `b8f0d02a…`); `roadie-runner.html` (20 mag, 526 righe) era una versione
  vecchia.
- Tenuta l'unica versione funzionante come **`index.html`** nella radice del
  progetto.
- Spostati nel Cestino (recuperabili): `roadie-runner.html`,
  `Blearred RoadieRunner.html`, `Blearred-RoadieRunner.zip`.
- Rimosse le cartelle duplicate `Blearred-RoadieRunner/` e
  `Blearred-RoadieRunner 2/` (contenevano solo copie identiche di `index.html`).
- Pulita la cartella padre `CLAUDE PROJECTS/`: rimosso `download.png` (era il
  logo Anthropic, non un asset del gioco → Cestino). `README.md` conservato.
- Creati i file mancanti: questo `STATO-LAVORO.md` e `CLAUDE.md`.

### Stato attuale
Cartella pulita, contiene solo: `index.html`, `CLAUDE.md`, `STATO-LAVORO.md`.
Gioco completo e giocabile.

### Possibili prossimi passi (idee, non confermate)
- Aggiungere audio (jump / game over / musica di sottofondo).
- Schermata "Aggiungi a Home" + icona app brandizzata Blearred.
- Online: pubblicare su un dominio/URL Blearred per la condivisione.
- Eventuale classifica condivisa (richiederebbe un backend).
