# Roadie Runner — condivisione agli eventi (QR + PWA leggera)

_Spec — 2026-07-15_

## Obiettivo

Rendere Roadie Runner immediato da dare a clienti/colleghi **agli eventi**:
inquadri un **QR code** e giochi subito, senza installare nulla. Chi vuole lo
"installa" con **Aggiungi a Home** e ottiene un'app Blearred a **schermo intero**
con **icona brandizzata**.

Deciso esplicitamente di **non** andare sull'App Store (attrito alto per il
cliente, solo iPhone, 99€/anno Apple, rischio rifiuto wrapper, Xcode non ci sta
sul disco). Il QR verso la web app già online copre l'obiettivo meglio: zero
installazione, iPhone **e** Android, costo zero, fattibile subito.

## Non-obiettivi (YAGNI)

- Niente App Store, Xcode, Apple Developer Program.
- **Niente service worker / offline** (rimosso su richiesta per semplicità).
- Nessun backend nuovo: la classifica Firebase resta invariata.
- Nessun redesign del gameplay.
- Il gioco resta essenzialmente il singolo `index.html`.

## Componenti

### 1. Installabilità (PWA leggera)
Rendere l'"Aggiungi a Home" pulito su iOS (primario) e installabile su Android.
Lo stato attuale del `<head>` ha già: `apple-mobile-web-app-capable`,
`apple-mobile-web-app-status-bar-style=black-translucent`, `viewport-fit=cover`.
Da aggiungere in `index.html`:
- `<link rel="apple-touch-icon" ...>` con l'icona (iOS usa questa per la Home).
- `<meta name="apple-mobile-web-app-title" content="Roadie Runner">`.
- `<meta name="theme-color" content="#0a0a0f">`.
- `<link rel="manifest" ...>` per l'installabilità Android (nome, colori,
  `display: standalone`, `orientation: portrait`, icone 192/512 + maskable).

Preferenza: mantenere il più possibile il **singolo file**. L'`apple-touch-icon`
e il manifest possono essere inline (data URI) per iOS; se l'installazione
Android con manifest inline risultasse inaffidabile in test, si ammette un
piccolo `manifest.json` + PNG icone come file separati (decisione in fase di
piano/verifica). iOS-first: l'icona apple-touch inline è la priorità.

### 2. Icona app Blearred (disegnata su misura)
Stile coerente col gioco: palco scuro (`#0a0a0f`), silhouette del roadie che
corre / faro, accento del brand (`#ff3860` magenta + oro), leggibile a piccole
dimensioni. Nessun file logo esterno necessario.
- Sorgente vettoriale (SVG) → export PNG nelle misure: **180×180**
  (apple-touch-icon), **192×192** e **512×512** (manifest), **512 maskable**
  (safe area per Android). Fondo pieno (no trasparenza) per iOS.

### 3. QR code + "cartolina" stampabile
- **QR code** che punta a `https://blearredadmin.github.io/roadie-runner/`.
- Una **pagina "cartolina"** brandizzata ("Inquadra e gioca a Roadie Runner",
  QR grande, brand Blearred) esportabile/stampabile per stand, badge, biglietti
  da visita. Asset locale, **non** deployato (serve solo a Ivan per stampare).

### 4. Deploy
Le modifiche vivono nel repo GitHub Pages `blearredadmin/roadie-runner`.
Problema noto: l'upload manuale via web risulta "disabled" (probabile
login/permessi) ed è comunque scomodo. Serve **sistemare il push git una volta
sola** (installare `gh` oppure configurare un remote HTTPS con Personal Access
Token), così si pubblica con un comando. Richiede un accesso GitHub di Ivan al
momento del setup.
Nota: anche il precedente `index.html` (classifica Top 10) è ancora da
pubblicare — con il push sistemato va online insieme al resto.

## Rischi / note

- **Cache versioni**: senza service worker il rischio cache è minore, ma
  GitHub Pages/CDN può servire una versione vecchia → hard refresh
  (Cmd+Shift+R) dopo il deploy; eventualmente query-string di versione sugli
  asset se necessario.
- **Manifest inline su Android**: da verificare in test; fallback a file
  separati se l'installazione non scatta.
- **Deploy dipende dall'accesso GitHub**: potrebbe servire creare un token.

## Criteri di successo

1. Aprendo il link su iPhone e facendo "Aggiungi a Home": compare l'**icona
   Blearred**, il titolo "Roadie Runner", e l'app parte a **schermo intero**.
2. Esiste un **QR code** stampabile che, inquadrato, apre il gioco.
3. Tutto è **pubblicato online** (versione aggiornata live), con un metodo di
   deploy ripetibile con un comando.
