# Design — Online + classifica globale (RoadieRunner)

**Data:** 2026-06-05
**Stato:** approvato (decisioni raccolte), in attesa setup Firebase

## Obiettivo

1. Pubblicare il gioco a un **link condivisibile** (GitHub Pages, sottodominio gratuito).
2. Aggiungere una **classifica globale** dove i giocatori inseriscono il **nickname**.

## Decisioni (confermate)

- **Hosting:** GitHub Pages (project page: `https://<utente>.github.io/<repo>/`).
- **Backend classifica:** Firebase **Firestore**.
- **Nome:** nickname libero, max ~12 caratteri.
- **Quando:** il nome è chiesto/riusato **a ogni game over** e il punteggio viene inviato.
- **Anti-cheat:** "casual" — accettiamo punteggi falsificabili; le regole impediscono
  modifica/cancellazione altrui; le voci farlocche si cancellano dalla console Firebase.

## Architettura

Il gioco resta **un solo `index.html`**, ma acquisisce:
- una **dipendenza esterna** (Firebase JS SDK via CDN, ES module);
- un **backend** (Firestore) con cui parla via internet.

### Dati (Firestore)

- Collezione `scores`, documento: `{ name: string(1..12), score: int(>=0), ts: serverTimestamp }`.
- Lettura classifica: `orderBy('score','desc'), limit(10)`.

### Regole di sicurezza Firestore

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /scores/{id} {
      allow read: if true;
      allow create: if request.resource.data.keys().hasOnly(['name','score','ts'])
        && request.resource.data.name is string
        && request.resource.data.name.size() >= 1
        && request.resource.data.name.size() <= 12
        && request.resource.data.score is int
        && request.resource.data.score >= 0
        && request.resource.data.score <= 1000000;
      allow update, delete: if false;
    }
  }
}
```

Nota: la **config web di Firebase NON è un segreto** (apiKey inclusa) — è pensata per
stare nel client. La sicurezza è data dalle regole sopra, non dal nascondere la config.

### Frontend (integrazione in `index.html`)

- **Overlay HTML** sopra il canvas (non disegnato nel canvas, per gestire bene
  l'input di testo): pannello classifica **Top 10** + riga inserimento nickname.
- **`<script type="module">`** che inizializza Firebase ed espone:
  `window.LB.submit(name, score)` e `window.LB.top(n)` (Promise).
- **Hook nel gioco:** al game over il gioco emette un evento; l'overlay:
  1. precompila il nickname da `localStorage` (`roadie_name`),
  2. invia il punteggio,
  3. mostra la Top 10 con evidenziata la voce del giocatore.
- **Pulsante "Classifica"** nella schermata iniziale per vedere la Top 10.
- **Guardia input:** mentre l'overlay è aperto, i tap/tasti non fanno saltare il
  roadie (e digitare nel campo nome non avvia il gioco).
- **Degradazione elegante:** se Firebase non è raggiungibile/configurato, il gioco
  resta **pienamente giocabile**; la classifica mostra "non disponibile".

## Sequenza di lavoro

1. **Firebase (utente):** crea progetto → crea Firestore (modalità produzione) →
   incolla le regole → registra una "Web App" → copia la config nel blocco dedicato
   di `index.html`.
2. **Codice (io):** integro overlay + module Firebase + hook, con verifica locale.
3. **GitHub Pages (utente, guidato):** crea repo → push → abilita Pages → link.
4. **Test:** link pubblico + invio punteggio reale da due dispositivi.

## Fuori scope (YAGNI)

Login giocatori, anti-cheat forte, classifiche multiple/temporali, avatar, commenti.
Tutto aggiungibile in seguito.
