#!/bin/bash
fichier="$1"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 fichier_urls.txt"
    exit 1
fi

mkdir -p Aspirations dump-text

indice=1
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"

echo "<table border='1'>
<tr>
<th>#</th><th>URL</th><th>HTTP</th><th>charset</th>
<th>mots</th><th>occurrences</th>
<th>page aspirée</th><th>dump UTF-8</th>
</tr>" > orientalismefr.html

while IFS= read -r url || [[ -n "$url" ]]; do
    echo "Traitement $indice : $url"

    html="Aspirations/fr-$indice.html"
    dump="dump-text/fr-$indice.txt"

    http_code=$(curl -L -A "$USER_AGENT" \
        --connect-timeout 10 \
        --max-time 20 \
        -s \
        -o "$html" \
        -w "%{http_code}" \
        "$url")

    if [[ "$http_code" != "200" ]]; then
        echo "Erreur HTTP $http_code"
        rm -f "$html"
        ((indice++))
        sleep 2
        continue
    fi

    encodage=$(file --mime-encoding --brief "$html")

    if [[ "$encodage" == "utf-8" ]]; then
        lynx "$html" -dump -nolist > "$dump"
    else
        iconv -f "$encodage" -t UTF-8 "$html" 2>/dev/null \
        | lynx -stdin -dump -nolist > "$dump"
    fi

    MOTS=$(wc -w < "$dump")
    ORIENTALISME_OCCURRENCE=$(grep -Eio '\borient\w*' "$dump" | wc -l)

    echo "<tr>
<td>$indice</td>
<td>$url</td>
<td>$http_code</td>
<td>$encodage</td>
<td>$MOTS</td>
<td>$ORIENTALISME_OCCURRENCE</td>
<td><a href='$html'>HTML</a></td>
<td><a href='$dump'>TXT</a></td>
</tr>" >> orientalismefr.html

    ((indice++))
    sleep 2

done < "$fichier"

echo "</table>" >> orientalismefr.html
echo "Terminé"
