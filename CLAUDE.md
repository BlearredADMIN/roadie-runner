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

## Regole / convenzioni
- Tenere il gioco **single-file** (`index.html`): niente dipendenze, niente build.
- Conservare **una sola** versione funzionante in cartella (no duplicati sparsi).
- Questo progetto vive in `~/Desktop/CLAUDE PROJECTS/Blearred RoadieRunner/`
  secondo la convenzione descritta nel `README.md` della cartella padre.
