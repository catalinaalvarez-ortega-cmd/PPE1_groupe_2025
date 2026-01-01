#!/bin/bash

# Vérification du nombre d'arguments
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 urls_fr.txt"
    exit 1
fi

URL_FILE="$1"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"
INDICE=1
HTML_OUT="../tableaux/orientalismefr.html"

# Création du tableau HTML principal
echo "<html><body><table border='1'>
<tr>
<th>#</th><th>URL</th><th>HTTP</th><th>Encodage</th>
<th>Mots</th><th>Occurrences orient*</th>
<th>HTML</th><th>TXT UTF-8</th><th>Contextes</th>
<th>Concordance</th><th>Dump-token</th>
<th>Contexte-token</th>


</tr>" > "$HTML_OUT"


# Lecture du fichier URL ligne par ligne
while read -r URL; do
    echo "Traitement $INDICE : $URL"

    HTML_FILE="../aspirations/francais_aspiration/fr-$INDICE.html"
    DUMP_FILE="../dumps-text/francais_dump/fr-$INDICE.txt"
    CONTEXTE_FILE="../contextes/francais_contexte/fr-$INDICE.txt"
    CONCORD_HTML="../concordances/francais_concordance/fr-$INDICE.html"
    Token_dump="../Token/dump/fr-$INDICE.txt"
    Token_contexte="../Token/contextes/fr-$INDICE.txt"

    # Téléchargement de la page
    HTTP_CODE=$(curl -L -A "$USER_AGENT" -s \
        --connect-timeout 10 --max-time 20 \
        -o "$HTML_FILE" -w "%{http_code}" "$URL")

    # Vérification du code HTTP
    if [[ "$HTTP_CODE" != "200" ]]; then
        echo "Erreur HTTP $HTTP_CODE pour $URL"
        rm -f "$HTML_FILE"
        ((INDICE++))
        continue
    fi

    # Détection de l'encodage
    ENCODAGE=$(file --mime-encoding --brief "$HTML_FILE")

    # Lecture uniquement si UTF-8 ou ASCII
    if [[ "$ENCODAGE" =~ utf-8|us-ascii ]]; then
        lynx -dump -nolist "$HTML_FILE" > "$DUMP_FILE"
    else
        echo "Page $URL non UTF-8, ignorée."
        ((INDICE++))
        continue
    fi

    # Comptage des mots et occurrences
    MOTS=$(wc -w < "$DUMP_FILE")
    OCC=$(grep -Eio '\borient\w*' "$DUMP_FILE" | wc -l)

    # Extraction des contextes autour des mots recherchés
    egrep -Ei -C 5 '\borient\w*' "$DUMP_FILE" > "$CONTEXTE_FILE"

    ./concordance.sh "[oO]rient" "$CONTEXTE_FILE" "$CONCORD_HTML"

 #python3 tsv_to_html_table.py "$DUMP_FILE" "$CONCORD_HTML"

    #Tokenization dump/ contexte
    python3 tokenizer.py  "$DUMP_FILE" "$Token_dump"
    python3 tokenizer.py  "$CONTEXTE_FILE" "$Token_contexte"

    # Ajout d'une ligne danspals_corpus le tableau principal
    echo "<tr>
<td>$INDICE</td>
<td><a href=\"$URL\">$URL</a></td>
<td>$HTTP_CODE</td>
<td>$ENCODAGE</td>
<td>$MOTS</td>
<td>$OCC</td>
<td><a href=\"$HTML_FILE\">HTML</a></td>
<td><a href=\"$DUMP_FILE\">TXT</a></td>
<td><a href=\"$CONTEXTE_FILE\">Contextes</a></td>
<td><a href=\"$CONCORD_HTML\">Concordance</a></td>
<td><a href=\"$Token_dump\">Dump-token</a></td>
<td><a href=\"$Token_contexte\">Contexte-token</a></td>

</tr>" >> "$HTML_OUT"

    ((INDICE++))
    sleep 2
done < "$URL_FILE"

# Fermeture du tableau HTML principal
echo "</table></body></html>" >> "$HTML_OUT"
echo "Terminé"


#analyse des resultats 1 partition 2cooc

python3 partition_pals.py  -i ../Token/dump/fr-*.txt >../frequences/francais/d-freq-fr.tsv
python3 tsv_to_html_table.py "../frequences/francais/d-freq-fr.tsv" "../frequences/francais/d-freq-fr.html"

python3 partition_pals.py  -i ../Token/contextes/fr-*.txt >../frequences/francais/c-freq-fr.tsv
python3 tsv_to_html_table.py "../frequences/francais/c-freq-fr.tsv" "../frequences/francais/c-freq-fr.html"

python3 cooccurrents.py ../Token/dump/fr-*.txt --target ".*[oO]rient.*" --match-mode regex >../PALS/francais_pals/cooc-dump-fr.tsv
python3 tsv_to_html_table.py "../PALS/francais_pals/cooc-dump-fr.tsv" "../PALS/francais_pals/cooc-dump-fr.html"

python3 cooccurrents.py ../Token/contextes/fr-*.txt --target ".*[oO]rient.*" --match-mode regex >../PALS/francais_pals/cooc-contextes-fr.tsv
python3 tsv_to_html_table.py "../PALS/francais_pals/cooc-contextes-fr.tsv" "../PALS/francais_pals/cooc-contextes-fr.html"


python3 wordcloud.py
