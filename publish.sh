#!/bin/bash
# Pubblica il gioco su GitHub Pages (repo pubblico blearredadmin/roadie-runner)
# copiando SOLO i file pubblici in un clone dedicato (.deploy/), così le note
# interne (docs/, spec, STATO-LAVORO) restano private.
set -e
cd "$(dirname "$0")"
REPO_URL="https://github.com/BlearredADMIN/roadie-runner.git"
DEPLOY=".deploy"

# Clone del repo pubblico al primo uso (clone pubblico: non serve auth)
if [ ! -d "$DEPLOY/.git" ]; then
  echo "Primo deploy: clono $REPO_URL ..."
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
  echo "Niente da pubblicare (gia' aggiornato)."
else
  git commit -m "deploy: aggiornamento gioco ($(date '+%Y-%m-%d %H:%M'))"
  git push origin main
  echo "Pubblicato. Attendi ~1 min, poi hard-refresh (Cmd+Shift+R) sul link."
fi
