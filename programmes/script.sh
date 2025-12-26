#!/bin/bash

# TODO
# lecture multilingue
# gestion des code 403 et fichiers vides dans les tableaux
DIR="$(pwd)"

# rend le fichier executable pour construire les concordanciers
chmod +x "$DIR/programmes/concordance.sh"

# variables prédéfinies
dossier="$DIR/URLs"
tab="tableau.html"

# Saisie des arguments
#read -r -p "Donnez le nom du dossier contenant les fichiers de liens http : " dossier
#read -r -p "Donnez le nom du fichier html où stocker ces liens dans des tableaux : " tab
#read -r -p "Donnez le motif recherché sur les pages en arabe : " motif1
#read -r -p "Donnez le motif recherché sur les pages en espagnol : " motif2
#read -r -p "Donnez le motif recherché sur les pages en français : " motif3

motif1=مستشرقين
motif2=orient
motif3=oriental

echo "<html>
  <head>
    <meta charset=\"UTF-8\" />
    <title>Programmation et Projet Encadré</title>
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
    <link
      rel=\"stylesheet\"
      href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css\"
    />
  </head>
  <body>
    <div class=\"container is-fluid\">
      <div class=\"box my-6\"><span class=\"is-size-1\">Tableaux HTML</span></div>
      <nav class=\"navbar mb-6\" role=\"navigation\" aria-label=\"main navigation\">
        <div id=\"navbarBasicExample\" class=\"navbar-menu\">
          <div class=\"navbar-start\">
            <a class=\"navbar-item\" href=\"../../index.html\"> Accueil </a>
            <a class=\"navbar-item\"> Script </a>
            <a class=\"navbar-item has-background-info-light\"> Tableaux </a>
          </div>
        </div>
      </nav>"  > "$DIR/tableaux/$tab"

# initialise un compteur de fichiers
indice=0
for fichier in "$dossier"/*.txt; do
    ((indice++))

    # assigne une langue à partir du nom du fichier
    lang=$(basename "$fichier" .txt)

    motif=""

    # reconnaissance de la langue et assigne le bon motif à rechercher
    if [ "$lang" = "arabe" ]; then
      motif=$motif1
    elif [ "$lang" = "espagnol" ]; then
      motif=$motif2
    elif [ "$lang" = "français" ]; then
      motif=$motif3
    else
      echo "Langue : "$lang", ignorée"
      continue
    fi

    echo "... Lecture des URls en $lang ... recherche du motif $motif ..."


    # créons les sous-dossiers de sortie
    mkdir "$DIR/aspirations/$lang";
    mkdir "$DIR/dumps-text/$lang";
    mkdir "$DIR/contextes/$lang";
    mkdir "$DIR/concordances/$lang";

    # initialise un compteur de lignes
    line=0

    echo -e "
        <span class=\"tag is-dark is-large\">Tableau n° $indice, langue : $lang</span>
        <table class=\"table mx-auto is-striped is-narrow my-6\">
        <thead>
          <tr>
            <th><abbr title=\"Index\">index</abbr></th>
            <th>url</th>
            <th><abbr title=\"Code\">http code</abbr></th>
            <th><abbr title=\"Encoding\">encodage</abbr></th>
            <th><abbr title=\"html page\">page aspirée</abbr></th>
            <th><abbr title=\"Dump\">dumps utf-8</abbr></th>
            <th><abbr title=\"Dump utf-8\">dumps convertis</abbr></th>
            <th class=\"has-text-centered\"><abbr title=\"Words\">occurences</abbr></th>
            <th><abbr title=\"Context\">contexte</abbr></th>
            <th><abbr title=\"Concordance\">concordance</abbr></th>
          </tr>
        </thead>
        <tbody>" >> "$DIR/tableaux/$tab"
    while read -r url; do
        ((line++))

        # nous stockons les chemins des fichiers à enregistrer dans des variables
        aspiration="$DIR/aspirations/"$lang"/"$lang"-$line.html"
        dump_text="$DIR/dumps-text/"$lang"/"$lang"-$line.txt"
        dump_text_iconv="$DIR/dumps-text/"$lang"/"$lang"-$line-utf8.txt"
        contexte="$DIR/contextes/"$lang"/"$lang"-$line.txt"
        concordance="$DIR/concordances/"$lang"/"$lang"-$line.html"

        # commande curl pour récupérer le code HTTP et le content type/charset + la page aspirée
        data=$(curl -sS -L -w "%{http_code}\n%{content_type}" -A "Mozilla/5.0 (compatible; curl-test)" --cookie cookies.txt -o "$aspiration" "$url")

        http_code=$(echo "$data" | head -1)
        encoding=$(echo "$data" | tail -1 | grep -Eio 'charset=[^;[:space:]]+' | cut -d"=" -f2 | tr '[:upper:]' '[:lower:]')

        if [ -z "${encoding}" ]; then
            encoding="N/A"
        fi

        #-------------------------------------------
		    # On continue en tenant compte de l'encodage fourni par curl
		    #-------------------------------------------
        if [[ "$encoding" == "utf-8" ]]; then

          # les pages html aspirées et sauvegardées dans ./aspirations
          # le résultat est testé, si la commande curl a échoué le script continue sur la prochaine itération

            # les DUMPS des pages aspirées obtenus avec lynx
            # vérifie si le fichier aspiré n'est pas vide
            [ -s "$aspiration" ] && \
            lynx -dump -nolist -display_charset="$encoding" "$aspiration" \
            > "$dump_text"

            # remplir la colonne dumps iconv
            dump_text_iconv=""$DIR"/dumps-text/"$lang"/-"

            # compter les occurrences du mot dans la page
            occurrences=$(grep -o -i "$motif" "$dump_text" | wc -l)

            # les contextes obtenus avec egrep
            egrep -i "$motif" "$dump_text" > "$contexte"

            # les concordances en appelant le script concordance.sh
            ./programmes/concordance.sh "$motif" "$contexte" "$concordance"

            echo -e "<tr>" >> "$DIR/tableaux/$tab"
        #-------------------------------------------
		    # Si le charset extrait est connu de iconv
		    #-------------------------------------------
        else
		      verif_encoding=$(iconv -l | egrep -io $encoding | sort -u);
          if [[ $verif_encoding != "" ]]; then

            [ -s "$aspiration" ] && \
            lynx -dump -nolist -display_charset="$encoding" "$aspiration" \
            > "$dump_text"
            iconv -f $encoding -t utf-8 "$dump_text" > "$dump_text_iconv"

            occurrences=$(grep -o -i "$motif" "$dump_text_iconv" | wc -l)

            egrep -i "$motif" "$dump_text_iconv" > "$contexte"

            ./PROGRAMMES/concordance.sh "$motif" "$contexte" "$concordance"

            echo -e "<tr class="has-background-info-light">" >> "$DIR/tableaux/$tab"

          #-------------------------------------------
			    # Sinon on ne fait rien
			    #-------------------------------------------
          else
            http_code="N/A"
            encoding="N/A"
            occurrences="-"
            aspiration="aspirations/"$lang"/-"
            dump_text="dumps-text/"$lang"/-"
            dump_text_iconv="dumps-text/"$lang"/-"
            contexte="contextes/"$lang"/-"
            concordance="concordances/"$lang"/-"

            echo -e "<tr class="has-background-danger-light">" >> "$DIR/tableaux/$tab"
          fi
        fi

        echo -e "
                <th>$line</th>
                <td style=\"text-overflow: ellipsis; overflow: hidden; max-width: 12rem\"><a href=\"$url\" target="_blank" rel="noopener noreferrer">$url</a></td>
                <td>$http_code</td>
                <td>$encoding</td>
                <td><a href=\"$aspiration\" target=\"_blank\" rel=\"noopener noreferrer\">html</a></td>
                <td><a href=\"$dump_text\" target=\"_blank\" rel=\"noopener noreferrer\">\"$(basename $dump_text)\"</a></td>
                <td><a href=\"$dump_text_iconv\" target=\"_blank\" rel=\"noopener noreferrer\">\"$(basename $dump_text_iconv)\"</a></td>
                <td class=\"has-text-centered\">$occurrences</td>
                <td><a href=\"$contexte\" target=\"_blank\" rel=\"noopener noreferrer\">\"$(basename $contexte)\"</a></td>
                <td><a href=\"$concordance\" target=\"_blank\" rel=\"noopener noreferrer\">\"$(basename $concordance)\"</a></td>
            </tr>" >> "$DIR/tableaux/$tab"
    done < $fichier
    echo "
      </tbody>
        </table>" >> "$DIR/tableaux/$tab"
done

echo "
    </div>
  </body>
</html>" >> "$DIR/tableaux/$tab"
