# Ostacoli più riconoscibili — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Rimuovere i due flightcase piccoli e aggiungere 4 ostacoli più riconoscibili e on-brand (transenna, testa mobile, batterista, trabattello), ribilanciando i tier.

**Architecture:** Modifiche localizzate in `index.html`: `makeObstacle` (geometrie), `pickObstacleType` (tier), `PAIR_TYPES`/`canPair` (coppie), `drawObstacles`+nuove draw functions (resa), `hitbox` (collisioni). Nessun cambiamento al game loop.

**Tech Stack:** Singolo file `index.html`, canvas 2D. Verifica: syntax-check via JavaScriptCore + verifica visiva nel browser.

**File toccati:** solo `index.html` (+ aggiornamento `STATO-LAVORO.md` e `CLAUDE.md`).

## Decisioni (approvate)

- **Rimossi:** `flightcase_s`, `flightcase_m`.
- **Tenuto:** `flightcase_l` (unico flightcase, branded BLEARRED + ruote).
- **Aggiunti:** `transenna` (bassa/larga), `testa_mobile` (faro animato), `batterista` (figura animata), `trabattello` (torre alta).
- **Tier:**
  - Tier 1 (<100): speaker, co2, mic, testa_mobile, transenna
  - Tier 2 (<250): + flightcase_l, flame, batterista
  - Tier 3 (<450): + trabattello
  - Tier 4 (≥450): + singer
- **Coppie (`PAIR_TYPES`):** speaker, flame, transenna, testa_mobile.
- **Mai accoppiabili (`canPair` esclude):** mic, singer, flightcase_l, batterista, trabattello.

## Geometrie nuovi ostacoli

| type | w | h | note |
|------|---|---|------|
| transenna | 42 | 20 | bassa e larga |
| testa_mobile | 24 | 46 | animata (phase) |
| batterista | 42 | 46 | animata (phase) |
| trabattello | 34 | 58 | alta |

---

### Task 1: Geometrie e tier (`makeObstacle`, `pickObstacleType`, `PAIR_TYPES`, `canPair`)

**Files:** Modify `index.html`

- [ ] **Step 1: Sostituire i rami flightcase in `makeObstacle`**

Rimuovere le righe di `flightcase_s` e `flightcase_m` e aggiungere i nuovi tipi. Il blocco diventa (da `else if (type === 'flightcase_s')` ... fino a `else if (type === 'singer')`):
```javascript
    else if (type === 'flightcase_l') { ob.w = 52; ob.h = 56; ob.y = GROUND_Y - ob.h; }
    else if (type === 'transenna') { ob.w = 42; ob.h = 20; ob.y = GROUND_Y - ob.h; }
    else if (type === 'testa_mobile') { ob.w = 24; ob.h = 46; ob.y = GROUND_Y - ob.h; ob.phase = Math.random() * 6; }
    else if (type === 'batterista') { ob.w = 42; ob.h = 46; ob.y = GROUND_Y - ob.h; ob.phase = 0; }
    else if (type === 'trabattello') { ob.w = 34; ob.h = 58; ob.y = GROUND_Y - ob.h; }
    else if (type === 'mic') { ob.w = 22; ob.h = 32; ob.y = GROUND_Y - 95; ob.phase = Math.random() * 6; }
    else if (type === 'singer') { ob.w = 28; ob.h = 64; ob.y = GROUND_Y - ob.h; ob.phase = 0; }
```
(`speaker`, `flame`, `co2` restano invariati sopra.)

- [ ] **Step 2: Riscrivere `pickObstacleType` con i nuovi tier**

Sostituire l'intero corpo della funzione con:
```javascript
  function pickObstacleType() {
    const r = Math.random();
    const s = state.score;
    if (s < 100) {
      // Tier 1: cassa, CO2, mic, testa mobile, transenna
      if (r < 0.22) return 'speaker';
      if (r < 0.42) return 'co2';
      if (r < 0.60) return 'mic';
      if (r < 0.82) return 'testa_mobile';
      return 'transenna';
    }
    if (s < 250) {
      // Tier 2: + flightcase BLEARRED, fiamma, batterista
      if (r < 0.14) return 'transenna';
      if (r < 0.28) return 'testa_mobile';
      if (r < 0.41) return 'speaker';
      if (r < 0.53) return 'co2';
      if (r < 0.65) return 'mic';
      if (r < 0.77) return 'flightcase_l';
      if (r < 0.89) return 'flame';
      return 'batterista';
    }
    if (s < 450) {
      // Tier 3: + trabattello
      if (r < 0.12) return 'transenna';
      if (r < 0.24) return 'testa_mobile';
      if (r < 0.35) return 'speaker';
      if (r < 0.46) return 'co2';
      if (r < 0.57) return 'mic';
      if (r < 0.68) return 'flightcase_l';
      if (r < 0.79) return 'flame';
      if (r < 0.90) return 'batterista';
      return 'trabattello';
    }
    // Tier 4: + cantante
    if (r < 0.11) return 'transenna';
    if (r < 0.22) return 'testa_mobile';
    if (r < 0.32) return 'speaker';
    if (r < 0.42) return 'co2';
    if (r < 0.52) return 'mic';
    if (r < 0.62) return 'flightcase_l';
    if (r < 0.72) return 'flame';
    if (r < 0.82) return 'batterista';
    if (r < 0.91) return 'trabattello';
    return 'singer';
  }
```

- [ ] **Step 3: Aggiornare `PAIR_TYPES`**

```javascript
  const PAIR_TYPES = ['speaker', 'flame', 'transenna', 'testa_mobile'];
```

- [ ] **Step 4: Aggiornare `canPair` nel loop `update()`**

Sostituire la riga `const canPair = ...` con:
```javascript
      const canPair = ob.type !== 'mic' && ob.type !== 'singer' && ob.type !== 'flightcase_l'
        && ob.type !== 'batterista' && ob.type !== 'trabattello';
```

- [ ] **Step 5: Syntax-check + commit**

Run:
```bash
cd ~/Desktop/CLAUDE\ PROJECTS/Blearred\ RoadieRunner/ && awk '/<script>/{f=1;next} /<\/script>/{f=0} f' index.html > /tmp/rc.js && osascript -l JavaScript -e 'function run(){var a=Application.currentApplication();a.includeStandardAdditions=true;try{Function(a.read(Path("/tmp/rc.js")));return"OK"}catch(e){return"ERR: "+e.message}}'
```
Expected: `OK`. Poi commit.

---

### Task 2: Resa grafica e collisioni

**Files:** Modify `index.html`

- [ ] **Step 1: Aggiornare il dispatch in `drawObstacles`**

Sostituire la riga del flightcase e aggiungere i nuovi tipi:
```javascript
  function drawObstacles() {
    obstacles.forEach(o => {
      if (o.type === 'speaker') drawSpeaker(o);
      else if (o.type === 'flame') drawFlame(o);
      else if (o.type === 'co2') drawCO2(o);
      else if (o.type === 'flightcase_l') drawFlightcase(o);
      else if (o.type === 'transenna') drawTransenna(o);
      else if (o.type === 'testa_mobile') drawMovingHead(o);
      else if (o.type === 'batterista') drawDrummer(o);
      else if (o.type === 'trabattello') drawScaffold(o);
      else if (o.type === 'mic') drawMic(o);
      else if (o.type === 'singer') drawSinger(o);
    });
  }
```

- [ ] **Step 2: Aggiungere le 4 nuove draw functions** (subito prima di `drawObstacles`)

Codice completo nelle sezioni "drawTransenna / drawMovingHead / drawDrummer / drawScaffold" qui sotto (vedi blocco "Codice draw functions").

- [ ] **Step 3: Aggiornare `hitbox`**

Sostituire il ramo flightcase (s/m/l) con flightcase_l + i nuovi tipi:
```javascript
    if (o.type === 'flightcase_l')
      return { x: o.x + 2, y: o.y + 2, w: o.w - 4, h: o.h - 4 };
    if (o.type === 'transenna') return { x: o.x + 2, y: o.y + 2, w: o.w - 4, h: o.h - 3 };
    if (o.type === 'testa_mobile') return { x: o.x + 5, y: o.y + 4, w: o.w - 10, h: o.h - 6 };
    if (o.type === 'batterista') return { x: o.x + 3, y: o.y + 4, w: o.w - 8, h: o.h - 6 };
    if (o.type === 'trabattello') return { x: o.x + 3, y: o.y + 1, w: o.w - 6, h: o.h - 3 };
```

- [ ] **Step 4: Syntax-check + verifica visiva + commit**

Apri nel browser, gioca fino a tier 4 (oppure abbassa temporaneamente le soglie per testare). Verifica che ogni nuovo ostacolo si veda bene, sia riconoscibile e collida in modo equo.

---

## Codice draw functions

```javascript
  function drawTransenna(o) {
    const x = o.x, y = o.y, w = o.w, h = o.h;
    ctx.strokeStyle = '#9aa0a8';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(x, y + 3); ctx.lineTo(x + w, y + 3);
    ctx.moveTo(x, y + h - 4); ctx.lineTo(x + w, y + h - 4);
    ctx.stroke();
    ctx.lineWidth = 1.5;
    for (let i = x + 4; i < x + w - 2; i += 7) {
      ctx.beginPath();
      ctx.moveTo(i, y + 3); ctx.lineTo(i, y + h - 4);
      ctx.stroke();
    }
    ctx.strokeStyle = '#5a5f66';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(x + 3, y + h - 4); ctx.lineTo(x - 1, y + h);
    ctx.moveTo(x + w - 3, y + h - 4); ctx.lineTo(x + w + 1, y + h);
    ctx.stroke();
    ctx.fillStyle = '#ff3860';
    ctx.fillRect(x + w / 2 - 8, y + 6, 16, 6);
  }

  function drawMovingHead(o) {
    o.phase += 0.06;
    const x = o.x, y = o.y, w = o.w, h = o.h;
    const cx = x + w / 2;
    const tilt = Math.sin(o.phase) * 0.5;
    const hue = (state.t * 2 + x * 3) % 360;
    ctx.fillStyle = '#1c1c24';
    ctx.fillRect(x + 2, y + h - 8, w - 4, 8);
    ctx.fillStyle = '#2a2a35';
    ctx.fillRect(x + 4, y + h - 10, w - 8, 3);
    ctx.fillStyle = '#15151c';
    ctx.fillRect(cx - 3, y + 16, 6, h - 26);
    ctx.fillStyle = '#2a2a35';
    ctx.fillRect(cx - 9, y + 14, 4, 12);
    ctx.fillRect(cx + 5, y + 14, 4, 12);
    ctx.save();
    ctx.translate(cx, y + 16);
    ctx.rotate(tilt);
    ctx.fillStyle = '#0a0a0a';
    ctx.fillRect(-8, -8, 16, 16);
    ctx.fillStyle = `hsl(${hue}, 90%, 60%)`;
    ctx.beginPath();
    ctx.arc(0, 0, 5, 0, Math.PI * 2);
    ctx.fill();
    const g = ctx.createLinearGradient(0, 0, 0, -60);
    g.addColorStop(0, `hsla(${hue},90%,60%,0.5)`);
    g.addColorStop(1, `hsla(${hue},90%,60%,0)`);
    ctx.fillStyle = g;
    ctx.beginPath();
    ctx.moveTo(-4, -4); ctx.lineTo(-22, -60); ctx.lineTo(22, -60); ctx.lineTo(4, -4);
    ctx.closePath();
    ctx.fill();
    ctx.restore();
  }

  function drawDrummer(o) {
    o.phase += 0.3;
    const x = o.x, y = o.y, w = o.w, h = o.h;
    const hit = Math.sin(o.phase) * 3;
    ctx.fillStyle = '#14141c';
    ctx.beginPath();
    ctx.arc(x + w / 2, y + h - 12, 13, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = '#ff3860';
    ctx.lineWidth = 2;
    ctx.stroke();
    ctx.fillStyle = '#ff3860';
    ctx.fillRect(x + w / 2 - 5, y + h - 14, 10, 3);
    ctx.strokeStyle = '#5a5f66';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(x + w - 8, y + h - 6); ctx.lineTo(x + w - 8, y + 6);
    ctx.stroke();
    ctx.fillStyle = '#d4af37';
    ctx.beginPath();
    ctx.ellipse(x + w - 8, y + 6 + hit * 0.3, 9, 2.5, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = '#e0b48a';
    ctx.fillRect(x + 6, y, 10, 10);
    ctx.fillStyle = '#1a1a1a';
    ctx.fillRect(x + 5, y - 1, 12, 4);
    ctx.fillStyle = '#222';
    ctx.fillRect(x + 4, y + 10, 14, 14);
    ctx.strokeStyle = '#e0b48a';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(x + 8, y + 13); ctx.lineTo(x + 2, y + 18 + hit);
    ctx.moveTo(x + 14, y + 13); ctx.lineTo(x + w - 10, y + 12 - hit);
    ctx.stroke();
    ctx.strokeStyle = '#caa472';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(x + 2, y + 18 + hit); ctx.lineTo(x - 3, y + 22 + hit);
    ctx.moveTo(x + w - 10, y + 12 - hit); ctx.lineTo(x + w - 6, y + 8 - hit);
    ctx.stroke();
  }

  function drawScaffold(o) {
    const x = o.x, y = o.y, w = o.w, h = o.h;
    ctx.strokeStyle = '#8a9098';
    ctx.lineWidth = 2.5;
    ctx.beginPath();
    ctx.moveTo(x + 3, y + 4); ctx.lineTo(x + 3, y + h - 4);
    ctx.moveTo(x + w - 3, y + 4); ctx.lineTo(x + w - 3, y + h - 4);
    ctx.stroke();
    ctx.strokeStyle = '#6a7078';
    ctx.lineWidth = 1.5;
    const levels = 3;
    const segH = (h - 14) / levels;
    for (let i = 0; i < levels; i++) {
      const yt = y + 4 + i * segH;
      const yb = yt + segH;
      ctx.beginPath();
      ctx.moveTo(x + 3, yt); ctx.lineTo(x + w - 3, yb);
      ctx.moveTo(x + w - 3, yt); ctx.lineTo(x + 3, yb);
      ctx.moveTo(x + 3, yt); ctx.lineTo(x + w - 3, yt);
      ctx.stroke();
    }
    ctx.fillStyle = '#3a2f22';
    ctx.fillRect(x - 1, y, w + 2, 5);
    ctx.fillStyle = '#5a3a1a';
    ctx.fillRect(x - 1, y, w + 2, 2);
    ctx.strokeStyle = '#8a9098';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(x + 1, y); ctx.lineTo(x + 1, y - 8);
    ctx.moveTo(x + w - 1, y); ctx.lineTo(x + w - 1, y - 8);
    ctx.moveTo(x + 1, y - 8); ctx.lineTo(x + w - 1, y - 8);
    ctx.stroke();
    ctx.fillStyle = '#1a1a1a';
    ctx.beginPath(); ctx.arc(x + 3, y + h, 3, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(x + w - 3, y + h, 3, 0, Math.PI * 2); ctx.fill();
  }
```

## Self-Review

- **Spec coverage:** rimozione s/m (Task 1.1), flightcase_l unico (makeObstacle + dispatch + hitbox), 4 nuovi tipi (geometrie/tier/draw/hitbox tutti presenti), tier approvati (1.2), coppie aggiornate (1.3/1.4). ✓
- **Placeholder:** nessuno; tutto il codice draw è incluso. ✓
- **Type consistency:** i nomi tipo (`transenna`, `testa_mobile`, `batterista`, `trabattello`) sono identici in makeObstacle, pickObstacleType, PAIR_TYPES/canPair, dispatch, hitbox e nei nomi funzione dra* corrispondenti. ✓
- **Rischio:** `flightcase_l` mantiene stencil (drawFlightcase usa `o.h >= 36`) e ruote (`o.h >= 50`); h=56 → entrambi ok. Le draw di s/m non vengono più chiamate (tipi non più generati). ✓
