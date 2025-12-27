#!/usr/bin/env bash

set -u

export LANG="fr_FR.UTF-8"
export LC_ALL="fr_FR.UTF-8"

ROOT="$HOME/PPE1_groupe_2025"
URLS="$ROOT/URLs/arabe.txt"
OUT="$ROOT/tableaux/orientalisme_filtre.html"

ASP_DIR="$ROOT/aspirations/arabe"
DUMP_DIR="$ROOT/dumps-text/arabe"
CTX_DIR="$ROOT/contextes/arabe"
CONC_DIR="$ROOT/concordances/arabe"

mkdir -p "$ROOT/tableaux" "$ASP_DIR" "$DUMP_DIR" "$CTX_DIR" "$CONC_DIR"

UserAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15"
MOTIFS='استشراق(ي|ية)|مستشرق(ون|ين)'

log(){ printf "[%s] %s\n" "$(date +'%H:%M:%S')" "$*"; }
need(){ command -v "$1" >/dev/null 2>&1 || { log "commande manquante: $1"; exit 1; }; }

need curl; need python3; need sed; need grep; need wc; need tr; need file
command -v lynx >/dev/null 2>&1 || log "lynx absent (brew install lynx)."

[[ -f "$URLS" ]] || { log "Fichier introuvable: $URLS"; exit 1; }
[[ -s "$URLS" ]] || { log "Fichier vide: $URLS"; exit 1; }

html_escape() {
  sed -e 's/&/\&amp;/g' \
      -e 's/</\&lt;/g' \
      -e 's/>/\&gt;/g' \
      -e "s/'/\&#39;/g" \
      -e 's/"/\&quot;/g'
}

urlencode() {
  python3 - <<'PY' "$1"
import sys, urllib.parse
print(urllib.parse.quote(sys.argv[1], safe=":/?&=%#"))
PY
}

filtrer_ar(){ sed 's/ـ//g'; }

detect_charset() {
  local PAGE="$1"
  local INFO CHARSET
  INFO="$(file -i "$PAGE" 2>/dev/null || true)"
  CHARSET="$(printf '%s' "$INFO" | sed -n 's/.*charset=\(.*\)$/\1/p')"
  [[ -n "$CHARSET" ]] || CHARSET="inconnu"
  printf "%s" "$CHARSET"
}

mw_api_extract() {
  python3 - <<'PY' "$1"
import sys, urllib.parse, re, json, subprocess
url=sys.argv[1]
u=urllib.parse.urlparse(url)
host=u.netloc.lower()
path=u.path
is_mw = any(x in host for x in ["wikipedia.org","wiktionary.org","wikibooks.org","wikiquote.org","wikisource.org","wikinews.org"])
if not is_mw:
    sys.exit(1)
m=re.match(r"^/wiki/(.+)$", path)
if not m:
    sys.exit(1)
title=urllib.parse.unquote(m.group(1))
api=f"{u.scheme}://{u.netloc}/w/api.php?action=query&prop=extracts&explaintext=1&format=json&redirects=1&titles=" + urllib.parse.quote(title)
cmd=["curl","-sS","-L","--http1.1","--tlsv1.2","--connect-timeout","10","--max-time","25","-A","Mozilla/5.0", api]
p=subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
if p.returncode!=0 or not p.stdout.strip():
    sys.exit(1)
data=json.loads(p.stdout)
pages=data.get("query",{}).get("pages",{})
for _,page in pages.items():
    extract=page.get("extract","").strip()
    if extract:
        print(extract)
        sys.exit(0)
sys.exit(1)
PY
}

cat > "$OUT" <<'HTML'
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Orientalisme – résultats (arabe)</title>
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
<h1>Orientalisme – résultats (arabe)</h1>
<table>
<tr>
  <th>N°</th><th>URL</th><th>Code</th><th>Encodage</th><th>Occ.</th>
  <th>HTML brute</th><th>Dump</th><th>Concord</th><th>Bigrams</th>
</tr>
HTML

i=1
while IFS= read -r url || [[ -n "$url" ]]; do
  [[ -z "$url" ]] && continue
  [[ "$url" =~ ^# ]] && continue
  [[ "$url" =~ ^https?:// ]] || continue

  PAGE="$ASP_DIR/arabe-$i.html"
  TXT="$DUMP_DIR/arabe-$i.txt"
  CTX="$CTX_DIR/arabe-$i.txt"
  CONC="$CONC_DIR/arabe-$i.html"
  BIG="$CTX_DIR/arabe-$i-bigrams.txt"

  log "→ [$i] $url"

  URL_ENC="$(urlencode "$url")"
  CODE="$(curl -sS -L --compressed --http1.1 --tlsv1.2 --connect-timeout 10 --max-time 35 \
      -A "$UserAgent" -H 'Connection: close' \
      -o "$PAGE" -w "%{http_code}" "$URL_ENC" || echo "000")"

  CHARSET="NA"
  [[ -s "$PAGE" ]] && CHARSET="$(detect_charset "$PAGE")"

  : > "$TXT"
  if mw_api_extract "$url" > "$TXT" 2>/dev/null; then
    true
  else
    if command -v lynx >/dev/null 2>&1 && [[ -s "$PAGE" ]]; then
      lynx -assume_charset=utf-8 -display_charset=utf-8 -dump -nolist "$PAGE" > "$TXT" 2>/dev/null || true
    fi
  fi

  OCC="$(cat "$TXT" 2>/dev/null | filtrer_ar | grep -Eo "$MOTIFS" | wc -l | tr -d ' ' || echo 0)"
  cat "$TXT" 2>/dev/null | filtrer_ar | grep -En "$MOTIFS" > "$CTX" || true

  awk '
    { sub(/^[0-9]+:/,""); for(i=1;i<=NF;i++) w[++n]=$i }
    END{ for(i=1;i<n;i++) print w[i], w[i+1] }
  ' "$CTX" 2>/dev/null | sort | uniq -c | sort -nr > "$BIG" || true

  {
    echo "<!doctype html><html><head><meta charset='utf-8'>"
    echo "<title>Concordance #$i</title>"
    echo "<style>body{font-family:system-ui;padding:1rem} mark{background:#ffe36e;padding:0 .12em;border-radius:.2em} pre{white-space:pre-wrap}</style>"
    echo "</head><body><h2>Concordance #$i</h2>"
    echo "<p class='small'>URL: $(printf '%s' "$url" | html_escape)</p><pre>"
    sed -E "s/($MOTIFS)/<mark>\1<\/mark>/g" "$CTX" \
      | html_escape \
      | sed 's/&lt;mark&gt;/<mark>/g; s/&lt;\/mark&gt;/<\/mark>/g'
    echo "</pre></body></html>"
  } > "$CONC"

  {
    echo "<tr>"
    echo "<td>$i</td>"
    echo "<td class='small'>$(printf '%s' "$url" | html_escape)</td>"
    if [[ "$CODE" == "000" || "$CODE" -ge 400 ]]; then
      echo "<td class='bad'>$CODE</td>"
    else
      echo "<td class='ok'>$CODE</td>"
    fi
    echo "<td>$(printf '%s' "$CHARSET" | html_escape)</td>"
    echo "<td>$OCC</td>"
    echo "<td><a href=\"$PAGE\">page</a></td>"
    echo "<td><a href=\"$TXT\">dump</a></td>"
    echo "<td><a href=\"$CONC\">conc</a></td>"
    echo "<td><a href=\"$BIG\">bigrams</a></td>"
    echo "</tr>"
  } >> "$OUT"

  log "  code=$CODE occ=$OCC dump_bytes=$(wc -c < "$TXT" | tr -d ' ')"
  i=$((i+1))

done < "$URLS"

cat >> "$OUT" <<'HTML'
</table>
</body>
</html>
HTML

log "HTML OK: $OUT"

