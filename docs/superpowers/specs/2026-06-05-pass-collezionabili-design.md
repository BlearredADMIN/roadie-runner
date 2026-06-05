# Design — Pass backstage collezionabili (RoadieRunner)

**Data:** 2026-06-05
**Progetto:** Blearred RoadieRunner (`index.html`, single-file)
**Stato:** approvato, pronto per la pianificazione

## Obiettivo

Aggiungere **pass backstage** brandizzati Blearred come collezionabili. Compaiono
lungo il percorso (alcuni bassi, alcuni alti); raccogliendoli si guadagnano
**+50 punti**. La meccanica introduce un "rischio per la ricompensa" leggero senza
nuovi comandi e senza modificare le regole degli ostacoli.

Tutto resta in `index.html`: nessuna dipendenza, nessun build, single-file.

## Decisioni di design (confermate)

- **Oggetto:** pass / laminato backstage con scritta **BLEARRED** (coerente con
  lo stencil già usato sui flightcase grandi).
- **Effetto:** solo punti bonus, **+50 a pass**. Nessun moltiplicatore, nessuna
  barra di carica, nessun power-up.
- **Posizione:** misti — alcuni **bassi** (presi correndo) e alcuni **alti**
  (presi saltando).
- **Spawn:** indipendente dagli ostacoli (approccio A), su un proprio timer.
- **Sicurezza:** un pass **non causa mai game over**. È solo bonus.

## Architettura (innesto sul codice esistente)

Il gioco gira su un unico loop `update()` / `draw()` con `requestAnimationFrame`.
Gli ostacoli sono in un array `obstacles[]` che scorre a sinistra
(`o.x -= state.speed`), viene ripulito fuori schermo e testato in collisione con
`overlap(roadieBox(), hitbox(o))`. I pass seguono lo **stesso schema**, in
parallelo e isolati dagli ostacoli.

### 1. Modello dati

- Nuovo array `passes[]`. Ogni elemento: `{ x, y, w, h, taken }`.
- Nuovo contatore `nextPass` (gemello di `nextSpawn`), che conta i frame al
  prossimo pass.

### 2. Spawn (indipendente dagli ostacoli)

- Quando `nextPass <= 0`, creo un pass a destra dello schermo (`x = W + 20`).
- Scelta casuale **basso / alto**:
  - **basso:** `y` tale che il roadie lo intercetti *correndo* (entro il corpo
    del roadie a terra, attorno a `GROUND_Y - h_roadie/2`).
  - **alto:** `y` all'altezza dell'apice del salto, così va preso saltando
    (di riferimento, sopra la linea dei microfoni a `GROUND_Y - 95`).
- `nextPass` si reimposta a una distanza casuale e si accorcia con la velocità
  usando la stessa formula degli ostacoli (`* (5 / state.speed)`), così il ritmo
  dei pass resta coerente con quello del gioco.
- I valori esatti di altezza/cadenza vanno **tarati in fase di implementazione**
  provando il gioco; l'apice reale del salto si misura dai parametri `GRAVITY` e
  velocità di salto esistenti.

### 3. Movimento + raccolta (dentro `update()`)

- Per ogni pass: `p.x -= state.speed`.
- Se `p.x + p.w < -20` → rimuovo dall'array.
- Altrimenti, se non `p.taken` e `overlap(roadieBox(), passBox(p))`:
  - `p.taken = true`,
  - `state.score += 50`,
  - emetto qualche particella **dorata** riusando il sistema `particles[]`
    esistente,
  - rimuovo il pass.
- Nessuna chiamata a `gameOver()` per i pass, mai.

### 4. Resa grafica

- Nuova funzione `drawPasses()`, chiamata in `draw()` **dopo** `drawObstacles()`
  e **prima** di `drawRoadie()`.
- Disegno: piccolo laminato/lanyard rettangolare con cordino, colori Blearred e
  micro-scritta **BLEARRED**, leggibile anche a dimensioni ridotte.

### 5. Reset

- In `reset()` aggiungo `passes.length = 0` e reinizializzo `nextPass`, così una
  nuova partita riparte senza pass residui.

## Verifica (test manuale)

Niente framework di test: è un single-file game, si verifica a mano aprendo
`index.html` nel browser.

1. Durante una partita compaiono pass **sia bassi sia alti**.
2. Toccando un pass: il punteggio sale di **50** e compaiono scintille dorate.
3. Un pass **non uccide mai** il roadie (ci passo attraverso senza rischio se non
   lo raccolgo, e raccoglierlo non interrompe il gioco).
4. Dopo il game over e "Tocca per ricominciare", **non restano pass vecchi** a
   schermo.
5. Il record (`localStorage` chiave `roadie_best`) continua a funzionare come
   prima.

## Fuori scope (YAGNI)

Moltiplicatori, power-up, suoni, pattern predefiniti di pass. Tutto aggiungibile
in seguito senza rifare questa base (l'approccio A evolve verso lo spawn
agganciato agli ostacoli — approccio B — senza buttare via nulla).
