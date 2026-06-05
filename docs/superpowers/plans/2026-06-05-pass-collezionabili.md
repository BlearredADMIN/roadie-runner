# Pass backstage collezionabili — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aggiungere pass backstage brandizzati Blearred come collezionabili che danno +50 punti, presi correndo (bassi) o saltando (alti), senza mai causare game over.

**Architecture:** Approccio A (spawner indipendente). Un nuovo array `passes[]` scorre in parallelo a `obstacles[]` usando lo stesso loop `update()`/`draw()` e lo stesso helper `overlap()`. I pass sono completamente isolati dagli ostacoli: nessuna modifica alla logica di spawn/collisione degli ostacoli.

**Tech Stack:** Singolo file `index.html` — HTML + CSS + JavaScript vanilla, rendering su `<canvas>` con `requestAnimationFrame`. Nessuna dipendenza, nessun build. Verifica **manuale nel browser** (il progetto non ha framework di test, ed è una scelta deliberata: vedi spec).

**File toccati:**
- Modify: `index.html` — unico file del progetto. Aggiunte: 1 array di stato, 1 contatore, 2 funzioni (`spawnPass`, `drawPasses`), 1 blocco nel loop `update()`, 1 chiamata in `draw()`, cleanup in `reset()`.

**Spec di riferimento:** `docs/superpowers/specs/2026-06-05-pass-collezionabili-design.md`

**Nota su git:** la cartella del progetto **non è un repo git**. Il Task 0 (consigliato) inizializza git per avere commit atomici per task. Se preferisci non usare git, salta gli step di commit e tieni come unico "diario" l'aggiornamento di `STATO-LAVORO.md` nel Task 5.

---

### Task 0 (consigliato): Inizializzare git

**Files:**
- Create: `.gitignore`

- [ ] **Step 1: Inizializzare il repo e fare il commit della baseline**

Run (dalla cartella del progetto):
```bash
cd ~/Desktop/CLAUDE\ PROJECTS/Blearred\ RoadieRunner/
git init
printf '.DS_Store\n' > .gitignore
git add -A
git commit -m "chore: baseline RoadieRunner prima dei pass collezionabili"
```
Expected: un primo commit che contiene `index.html`, `CLAUDE.md`, `STATO-LAVORO.md`, i doc `docs/superpowers/...` e `.gitignore`.

---

### Task 1: Stato e spawn dei pass

**Files:**
- Modify: `index.html` (dichiarazione array `passes`, contatore `nextPass`, funzione `spawnPass`)

- [ ] **Step 1: Dichiarare l'array `passes`**

Dopo la riga `  const obstacles = [];` (riga ~94), aggiungere:
```javascript
  const passes = [];
```

- [ ] **Step 2: Dichiarare il contatore `nextPass`**

Subito dopo la riga `  let nextSpawn = 70;` (riga ~236), aggiungere:
```javascript
  let nextPass = 90;
```

- [ ] **Step 3: Aggiungere la funzione `spawnPass`**

Subito dopo la funzione `spawnObstacle()` (che termina con `return ob; }`, riga ~227), aggiungere:
```javascript
  function spawnPass() {
    const high = Math.random() < 0.5;        // metà alti (da saltare), metà bassi (di corsa)
    const w = 16, h = 22;
    // basso: dentro il corpo del roadie a terra; alto: verso l'apice del salto
    const y = high ? GROUND_Y - 130 : GROUND_Y - 40;
    passes.push({ x: W + 20, y, w, h, taken: false });
  }
```

- [ ] **Step 4: Verifica (caricamento senza errori)**

Run:
```bash
open ~/Desktop/CLAUDE\ PROJECTS/Blearred\ RoadieRunner/index.html
```
Apri la Console del browser (Cmd+Opt+J su Chrome). Expected: il gioco parte come prima, **nessun errore** in console. I pass non si vedono ancora (manca il loop e il disegno): è corretto.

- [ ] **Step 5: Commit** *(salta se non usi git)*

```bash
git add index.html
git commit -m "feat: stato e spawn dei pass collezionabili (no-op finché manca il loop)"
```

---

### Task 2: Movimento, raccolta e punteggio

**Files:**
- Modify: `index.html` (blocco nel loop `update()`)

- [ ] **Step 1: Aggiungere il blocco pass nel loop `update()`**

Nel corpo di `update()`, **subito dopo** il ciclo `for` che muove e testa gli ostacoli (il blocco che fa `o.x -= state.speed; ... gameOver();`, finisce circa a riga 778) e **prima** del ciclo `for` delle particelle (`for (let i = particles.length - 1; ...`), inserire:
```javascript
    // --- Pass collezionabili (bonus, non causano MAI game over) ---
    nextPass--;
    if (nextPass <= 0) {
      spawnPass();
      nextPass = Math.floor((120 + Math.random() * 120) * (5 / state.speed));
    }
    for (let i = passes.length - 1; i >= 0; i--) {
      const p = passes[i];
      p.x -= state.speed;
      if (p.x + p.w < -20) { passes.splice(i, 1); continue; }
      if (!p.taken && overlap(roadieBox(), p)) {
        p.taken = true;
        state.score += 50;
        for (let k = 0; k < 8; k++) {
          particles.push({
            x: p.x + p.w / 2, y: p.y + p.h / 2,
            vx: (Math.random() - 0.5) * 4, vy: (Math.random() - 0.7) * 4,
            life: 25 + Math.random() * 15,
            col: ['#ffd24a', '#ffe9a0', '#fff3c4'][Math.floor(Math.random() * 3)],
            r: 1 + Math.random() * 2,
          });
        }
        passes.splice(i, 1);
      }
    }
```

- [ ] **Step 2: Verifica (raccolta funziona, anche se i pass sono invisibili)**

Run:
```bash
open ~/Desktop/CLAUDE\ PROJECTS/Blearred\ RoadieRunner/index.html
```
Gioca qualche secondo. Expected: ogni tanto, correndo o saltando, il **punteggio fa un salto di +50** e compaiono **scintille dorate** in punti "vuoti" (i pass ancora non si disegnano — normale). Verifica che attraversare quei punti **non interrompa mai** la partita.

- [ ] **Step 3: Commit** *(salta se non usi git)*

```bash
git add index.html
git commit -m "feat: movimento, raccolta e bonus +50 dei pass nel game loop"
```

---

### Task 3: Disegno dei pass (laminato BLEARRED)

**Files:**
- Modify: `index.html` (funzione `drawPasses` + chiamata in `draw()`)

- [ ] **Step 1: Aggiungere la funzione `drawPasses`**

Subito dopo la funzione `drawObstacles()` (che termina con `}); }`, riga ~657), aggiungere:
```javascript
  function drawPasses() {
    passes.forEach(p => {
      const x = p.x, y = p.y, w = p.w, h = p.h;
      // cordino (lanyard)
      ctx.strokeStyle = '#ff3860';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(x + w / 2 - 5, y - 8);
      ctx.lineTo(x + w / 2, y);
      ctx.lineTo(x + w / 2 + 5, y - 8);
      ctx.stroke();
      // corpo del laminato
      ctx.fillStyle = '#12121a';
      ctx.fillRect(x, y, w, h);
      ctx.strokeStyle = '#ffd24a';
      ctx.lineWidth = 1.5;
      ctx.strokeRect(x + 0.5, y + 0.5, w - 1, h - 1);
      // scritta BLEARRED verticale (micro)
      ctx.save();
      ctx.translate(x + w / 2, y + h / 2);
      ctx.rotate(-Math.PI / 2);
      ctx.fillStyle = '#ffd24a';
      ctx.font = 'bold 5px monospace';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('BLEARRED', 0, 0);
      ctx.restore();
      ctx.textAlign = 'left';
      ctx.textBaseline = 'alphabetic';
    });
  }
```

- [ ] **Step 2: Chiamare `drawPasses()` nel loop di disegno**

Nella funzione `draw()`, subito dopo la riga `    drawObstacles();`, aggiungere:
```javascript
    drawPasses();
```

- [ ] **Step 3: Verifica (i pass si vedono e sono leggibili)**

Run:
```bash
open ~/Desktop/CLAUDE\ PROJECTS/Blearred\ RoadieRunner/index.html
```
Gioca. Expected: compaiono i laminati col cordino e la scritta **BLEARRED**; alcuni **bassi** (si prendono correndo) e alcuni **alti** (si prendono saltando). Toccandoli: +50 e scintille dorate. Nessun errore in console.

- [ ] **Step 4: Commit** *(salta se non usi git)*

```bash
git add index.html
git commit -m "feat: resa grafica dei pass (laminato brandizzato BLEARRED)"
```

---

### Task 4: Reset pulito tra partite

**Files:**
- Modify: `index.html` (funzione `reset()`)

- [ ] **Step 1: Azzerare i pass in `reset()`**

In `reset()`, sostituire la riga:
```javascript
    obstacles.length = 0; particles.length = 0;
```
con:
```javascript
    obstacles.length = 0; particles.length = 0; passes.length = 0;
```
e sostituire la riga:
```javascript
    nextSpawn = 70;
```
con:
```javascript
    nextSpawn = 70; nextPass = 90;
```

- [ ] **Step 2: Verifica (nessun pass residuo dopo il game over)**

Run:
```bash
open ~/Desktop/CLAUDE\ PROJECTS/Blearred\ RoadieRunner/index.html
```
Fai finire una partita, poi "Tocca per ricominciare". Expected: la nuova partita riparte **senza pass vecchi** a schermo e con la cadenza di spawn da capo.

- [ ] **Step 3: Commit** *(salta se non usi git)*

```bash
git add index.html
git commit -m "fix: reset azzera i pass e il loro timer tra una partita e l'altra"
```

---

### Task 5: Verifica finale completa + diario

**Files:**
- Modify: `STATO-LAVORO.md`

- [ ] **Step 1: Checklist di accettazione (dalla spec)**

Run:
```bash
open ~/Desktop/CLAUDE\ PROJECTS/Blearred\ RoadieRunner/index.html
```
Verifica TUTTI questi punti:
1. Compaiono pass **sia bassi sia alti**.
2. Toccando un pass: punteggio **+50** e **scintille dorate**.
3. Un pass **non uccide mai** (ci passo attraverso senza rischio).
4. Dopo "Tocca per ricominciare": **nessun pass residuo**.
5. Il record (`localStorage` chiave `roadie_best`) funziona come prima.
6. Su finestra stretta (simulazione iPhone): i pass restano leggibili e raccoglibili.

Se un'altezza risulta troppo facile/impossibile, **tarare** i valori `GROUND_Y - 130` (alto) / `GROUND_Y - 40` (basso) in `spawnPass`, e la cadenza `120 + Math.random()*120` in `update()`. Riprovare finché il bilanciamento convince.

- [ ] **Step 2: Aggiornare il diario di bordo**

In `STATO-LAVORO.md`, aggiungere in cima una nuova sezione datata che riassuma:
> Aggiunta meccanica **pass collezionabili** (+50 a pass, bassi/alti, mai letali), brandizzati BLEARRED. Spec e piano in `docs/superpowers/`.

E sposta la voce "collezionabili" dai "possibili prossimi passi" a "Fatto".

- [ ] **Step 3: Commit finale** *(salta se non usi git)*

```bash
git add index.html STATO-LAVORO.md
git commit -m "docs: aggiorna stato lavoro dopo i pass collezionabili"
```

---

## Self-Review (eseguita in fase di scrittura del piano)

**1. Spec coverage:**
- Pass +50 punti → Task 2 (`state.score += 50`). ✓
- Bassi e alti → Task 1 (`spawnPass`, ramo `high`). ✓
- Spawn indipendente → Task 1/2 (`nextPass` separato da `nextSpawn`). ✓
- Non causano mai game over → Task 2 (nessuna chiamata a `gameOver`). ✓
- Grafica laminato BLEARRED → Task 3 (`drawPasses`). ✓
- Reset pulito → Task 4. ✓
- Verifica manuale (5 punti spec) → Task 5. ✓
- Particelle riusate → Task 2 (push su `particles[]`). ✓

**2. Placeholder scan:** nessun TBD/TODO; ogni step di codice ha il codice completo. I valori di altezza/cadenza sono numeri concreti, con istruzione esplicita di taratura nel Task 5. ✓

**3. Type consistency:** `passes` (array), `nextPass` (number), `spawnPass()`, `drawPasses()`, campo `taken`, `overlap(roadieBox(), p)` con `p` che espone `{x,y,w,h}` — coerenti tra Task 1→4. ✓
