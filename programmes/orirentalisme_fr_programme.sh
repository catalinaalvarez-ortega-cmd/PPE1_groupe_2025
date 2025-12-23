#!/bin/bash

# Vérification du nombre d'arguments
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 url_orientalismefr.txt"
    exit 1
fi

fichier="$1"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"

indice=1

HTML_OUT="../tableaux/orientalismefr.html"
echo "<table border='1'>
<tr>
<th>#</th><th>URL</th><th>HTTP</th><th>Encodage</th>
<th>Mots</th><th>Occurrences orient*</th>
<th>HTML</th><th>TXT UTF-8</th><th>Contextes</th>
</tr>" > "$HTML_OUT"

# Lecture du fichier URL ligne par ligne
    while read -r url; do
    echo "Traitement $indice : $url"

    html="../aspirations/fr-$indice.html"
    dump="../dumps-text/fr-$indice.txt"
    contexte="../contextes/fr-$indice.txt"

    # Téléchargement de la page
    http_code=$(curl -L -A "$USER_AGENT" -s \
        --connect-timeout 10 --max-time 20 \
        -o "$html" -w "%{http_code}" "$url")

    # Vérification du code HTTP
    if [[ "$http_code" != "200" ]]; then
        echo "Erreur HTTP $http_code pour $url"
        rm -f "$html"
        ((indice++))
        continue
    fi

    # Détection de l'encodage
    encodage=$(file --mime-encoding --brief "$html")

    # Extraction du texte
    if [[ "$encodage" =~ utf-8|us-ascii ]]; then
        lynx -dump -nolist "$html" > "$dump"
    else
        if iconv -f "$encodage" -t UTF-8 "$html" 2>/dev/null \
            | lynx -stdin -dump -nolist > "$dump"; then
            :
        else
            echo "Impossible de convertir $html en UTF-8"
            ((indice++))
            continue
        fi
    fi

    # Comptage des mots et occurrences
    MOTS=$(wc -w < "$dump")
    OCC=$(grep -Eio '\borient\w*' "$dump" | wc -l)

    # Extraction des contextes autour des mots recherchés
    egrep -Ei -C 5 '\borient\w*' "$dump" > "$contexte"

    # Ajout d'une ligne dans le tableau HTML
    echo "<tr>
<td>$indice</td>
<td><a href=\"$url\">$url</a></td>
<td>$http_code</td>
<td>$encodage</td>
<td>$MOTS</td>
<td>$OCC</td>
<td><a href=\"$html\">HTML</a></td>
<td><a href=\"$dump\">TXT</a></td>
<td><a href=\"$contexte\">Contextes</a></td>
</tr>" >> "$HTML_OUT"

    ((indice++))
    sleep 2
done < "$fichier"

# Fermeture du tableau HTML
echo "</table>" >> "$HTML_OUT"
echo "Terminé"
