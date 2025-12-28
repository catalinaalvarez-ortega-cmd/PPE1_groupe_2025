#!/usr/bin/env bash
set -euo pipefail

# --- Réglages ---
ROOT="$HOME/PPE1_groupe_2025"
URLS="$ROOT/URLs/arabe.txt"

ASP_DIR="$ROOT/aspirations/arabe"
DUMP_DIR="$ROOT/dumps-text/arabe"
CTX_DIR="$ROOT/contextes/arabe"
CONC_DIR="$ROOT/concordances/arabe"
OUT="$ROOT/tableaux/orientalisme_ar_simple.html"

mkdir -p "$ASP_DIR" "$DUMP_DIR" "$CTX_DIR" "$CONC_DIR" "$ROOT/tableaux"

# Motifs à repérer
MOTIFS='استشراق(ي|ية)|مستشرق(ون|ين)'

# User-Agent simple pour limiter certains blocages
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15"

# --- Petites fonctions ---
need(){ command -v "$1" >/dev/null 2>&1 || { echo "Commande manquante: $1" >&2; exit 1; }; }
need curl; need lynx; need grep; need sed; need wc; need tr

html_escape() {
  sed -e 's/&/\&amp;/g' \
      -e 's/</\&lt;/g' \
      -e 's/>/\&gt;/g' \
      -e 's/"/\&quot;/g' \
      -e "s/'/\&#39;/g"
}

# Nettoyage minimal arabe: on enlève juste le tatweel
filtrer_ar(){ sed 's/ـ//g'; }

# --- En-tête HTML ---
cat > "$OUT" <<'HTML'
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Orientalisme – Arabe (pipeline simple)</title>
<style>
body { font-family: system-ui; padding: 1rem; }
table { border-collapse: collapse; width: 100%; }
td, th { border: 1px solid #ddd; padding: .45em .55em; vertical-align: top; }
th { background: #f6f6f6; }
pre { white-space: pre-wrap; margin: 0; }
mark { background: #ffe36e; padding: 0 .12em; border-radius: .2em; }
.small { font-size: .9em; color: #444; }
.bad { color: #a40000; font-weight: 700; }
.ok  { color: #0b6b0b; font-weight: 700; }
</style>
</head>
<body>
<h1>Orientalisme – Arabe (pipeline simple)</h1>
<table>
<tr>
  <th>N°</th><th>URL</th><th>Code</th><th>Occ.</th>
  <th>HTML</th><th>Dump</th><th>Concordance</th>
</tr>
HTML

# --- Traitement URL par URL ---
i=1
while IFS= read -r url || [[ -n "$url" ]]; do
  [[ -z "$url" ]] && continue
  [[ "$url" =~ ^# ]] && continue
  [[ "$url" =~ ^https?:// ]] || continue

  PAGE="$ASP_DIR/arabe-$i.html"
  TXT="$DUMP_DIR/arabe-$i.txt"
  CTX="$CTX_DIR/arabe-$i.txt"
  CONC="$CONC_DIR/arabe-$i.html"

  echo "[INFO] [$i] $url" >&2

  # 1) Télécharger HTML
  CODE="$(curl -sS -L --connect-timeout 10 --max-time 35 -A "$UA" \
          -o "$PAGE" -w "%{http_code}" "$url" || echo "000")"

  # 2) Extraire texte brut (lynx)
  : > "$TXT"
  if [[ -s "$PAGE" ]]; then
    lynx -assume_charset=utf-8 -display_charset=utf-8 -dump -nolist "$PAGE" > "$TXT" 2>/dev/null || true
  fi

  # 3) Compter occurrences du motif
  OCC="$(cat "$TXT" | filtrer_ar | grep -Eo "$MOTIFS" | wc -l | tr -d ' ' || echo 0)"

  # 4) Extraire lignes-contexte (avec numéros de ligne)
  cat "$TXT" | filtrer_ar | grep -En "$MOTIFS" > "$CTX" || true

  # 5) Générer une page concordance (surlignage)
  {
    echo "<!doctype html><html><head><meta charset='utf-8'>"
    echo "<title>Concordance #$i</title>"
    echo "<style>body{font-family:system-ui;padding:1rem} mark{background:#ffe36e;padding:0 .12em;border-radius:.2em} pre{white-space:pre-wrap}</style>"
    echo "</head><body><h2>Concordance #$i</h2>"
    echo "<p class='small'>URL: $(printf '%s' "$url" | html_escape)</p><pre>"
    # on surligne dans le texte, puis on échappe, puis on réactive <mark>
    sed -E "s/($MOTIFS)/<mark>\1<\/mark>/g" "$CTX" \
      | html_escape \
      | sed 's/&lt;mark&gt;/<mark>/g; s/&lt;\/mark&gt;/<\/mark>/g'
    echo "</pre></body></html>"
  } > "$CONC"

  # 6) Ajouter une ligne au tableau HTML principal
  {
    echo "<tr>"
    echo "<td>$i</td>"
    echo "<td class='small'>$(printf '%s' "$url" | html_escape)</td>"
    if [[ "$CODE" == "000" || "$CODE" -ge 400 ]]; then
      echo "<td class='bad'>$CODE</td>"
    else
      echo "<td class='ok'>$CODE</td>"
    fi
    echo "<td>$OCC</td>"
    echo "<td><a href=\"$(basename "$PAGE")\">page</a></td>"
    echo "<td><a href=\"$(basename "$TXT")\">dump</a></td>"
    echo "<td><a href=\"$(basename "$CONC")\">conc</a></td>"
    echo "</tr>"
  } >> "$OUT"

  i=$((i+1))
done < "$URLS"

# --- Pied HTML ---
cat >> "$OUT" <<'HTML'
</table>
</body>
</html>
HTML

echo "[OK] Résultats: $OUT" >&2

