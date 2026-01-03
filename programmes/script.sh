#!/bin/bash

#-------------------------------------------
# Executer script.sh depuis la racine du projet PPE
# bash ./programmes/script.sh
#-------------------------------------------

# rend le fichier executable pour construire les concordanciers 
chmod +x "./programmes/concordance.sh"

# variables prédéfinies
dossier="./URLs"
tab="tableau"

# Saisie des arguments
#read -r -p "Donnez le nom du dossier contenant les fichiers de liens http : " dossier
#read -r -p "Donnez le nom du fichier html où stocker ces liens dans des tableaux : " tab
#read -r -p "Donnez le motif recherché sur les pages en arabe : " motif1
#read -r -p "Donnez le motif recherché sur les pages en espagnol : " motif2
#read -r -p "Donnez le motif recherché sur les pages en français : " motif3

motif1=مستشرقين
motif2=orient
motif3=oriental
      
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
if [[ ! -d "./aspirations/$lang" && ! -d "./dumps-text/$lang" && ! -d "./contextes/$lang" && ! -d "./concordances/$lang" ]] && ! -d "./aspirations/$lang" && ! -d "./dumps-text/$lang" && ! -d "./contextes/$lang" && ! -d "./concordances/$lang" ]]; then
        mkdir "./aspirations/$lang";
        mkdir "./dumps-text/$lang";
        mkdir "./contextes/$lang";
        mkdir "./concordances/$lang";
    fi
    

    # initialise un compteur de lignes
    line=0

    out_file="./tableaux/$tab-$lang.html"

    cat > "$out_file" <<EOF
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Tableaux | PPE Orientalisme</title>

    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
      rel="stylesheet"
    />
    <link href="PPE.css" rel="stylesheet" />

    <style>
      /* Ajustements locaux pour un rendu table lisible sur fond sombre (sans impacter le reste du site) */
      .ppe-table {
        --bs-table-color: var(--ink);
        --bs-table-bg: transparent;
        --bs-table-striped-color: var(--ink);
        --bs-table-striped-bg: rgba(255, 255, 255, 0.045);
        --bs-table-border-color: rgba(255, 248, 220, 0.16);
      }
      .ppe-table thead th {
        border-bottom-color: rgba(255, 248, 220, 0.22);
        opacity: 0.95;
        font-weight: 700;
        white-space: nowrap;
      }
      .ppe-table td,
      .ppe-table th {
        vertical-align: middle;
      }
      .ppe-table .table-danger > * {
        --bs-table-bg: rgba(220, 53, 69, 0.14);
        --bs-table-striped-bg: rgba(220, 53, 69, 0.16);
        --bs-table-color: var(--ink);
      }
      .ppe-table td a {
        word-break: break-word;
      }
    </style>
  </head>

  <body class="corps">
    <div class="wow-bg" aria-hidden="true"></div>

    <header class="py-3">
      <nav class="navbar navbar-expand-lg navbar-dark mt-3">
        <div class="container">
          <div class="collapse navbar-collapse" id="mainNav">
            <ul class="navbar-nav ms-auto">
              <li class="nav-item">
                <a class="nav-link" rel="_blank" href="../SITE-PPE/index.html"
                  >Accueil</a
                >
              </li>
              <li class="nav-item">
                <a class="nav-link" rel="_blank" href="../tableaux/tableau-arabe.html"
                  >Tableau Arabe</a
                >
              </li>
              <li class="nav-item">
                <a class="nav-link" rel="_blank" href="../tableaux/tableau-espagnol.html"
                  >Tableau Espagnol</a
                >
              </li>
              <li class="nav-item">
                <a class="nav-link" rel="_blank" href="../tableaux/orientalisme.html"
                  >Tableau Français</a
                >
              </li>
            </ul>
          </div>
        </div>
      </nav>
    </header>

    <main class="container py-4">
      <section class="hero mb-4 reveal">
        <div class="hero-bg" aria-hidden="true"></div>
        <div class="hero-content p-4 p-md-5">
          <div class="glass p-3 p-md-4 text-center">
            <h1 class="h3 mb-1"><strong>Tableau n°$indice : langue $lang</strong></h1>
            <p class="mb-0 opacity-75">
              Résultats d’aspiration, dumps, contextes et concordances.
            </p>
          </div>
        </div>
      </section>

      <section class="reveal">
        <div class="modern-card p-3 p-md-4">
          <div class="table-responsive">
            <table class="table table-striped table-sm align-middle ppe-table">
              <thead>
                <tr>
                  <th><abbr title="Index">index</abbr></th>
                  <th>url</th>
                  <th><abbr title="Code">http code</abbr></th>
                  <th><abbr title="Encoding">encodage</abbr></th>
                  <th><abbr title="html page">page aspirée</abbr></th>
                  <th><abbr title="Dump">dumps utf-8</abbr></th>
                  <th><abbr title="Dump utf-8">dumps convertis</abbr></th>
                  <th class="text-center"><abbr title="Words">occurences</abbr></th>
                  <th><abbr title="Context">contexte</abbr></th>
                  <th><abbr title="Concordance">concordance</abbr></th>
                </tr>
              </thead>
              <tbody>
EOF
    while read -r url; do
        ((line++))

        # nous stockons les chemins des fichiers à enregistrer dans des variables
        aspiration="./aspirations/"$lang"/"$lang"-$line.html"
        dump_text="./dumps-text/"$lang"/"$lang"-$line.txt"
        dump_text_iconv="./dumps-text/"$lang"/"$lang"-$line-utf8.txt"
        contexte="./contextes/"$lang"/"$lang"-$line.txt"
        concordance="./concordances/"$lang"/"$lang"-$line.html"
        # Valeurs par défaut
        http_code="N/A"
        encoding="N/A"
        occurrences="-"
        row_class=""

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
        
          # les pages html aspirées et sauvegardées dans ./aspirations
          # le résultat est testé, si la commande curl a échoué le script continue sur la prochaine itération
          
            # les DUMPS des pages aspirées obtenus avec lynx
            # vérifie si le fichier aspiré n'est pas vide
            [ -s "$aspiration" ] && \
            lynx -dump -nolist -display_charset="$encoding" "$aspiration" \
            > "$dump_text"

            # remplir la colonne dumps iconv
            dump_text_iconv="./dumps-text/"$lang"/-"

            # compter les occurrences du mot dans la page
            occurrences=$(grep -o -i "$motif" "$dump_text" | wc -l)

            # les contextes obtenus avec egrep
            egrep -i "$motif" "$dump_text" > "$contexte"

            # les concordances en appelant le script concordance.sh
            ./programmes/concordance.sh "$motif" "$contexte" "$concordance"

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

            row_class="table-warning"

          #-------------------------------------------
			    # Sinon on ne fait rien
			    #-------------------------------------------
          else
            row_class="table-danger"
            http_code="N/A"
            encoding="N/A"
            occurrences="-"
            aspiration="aspirations/"$lang"/-"
            dump_text="dumps-text/"$lang"/-"
            dump_text_iconv="dumps-text/"$lang"/-"
            contexte="contextes/"$lang"/-"
            concordance="concordances/"$lang"/-"
          fi
        fi

    cat >> "$out_file" <<EOF
                <tr class="$row_class">
                  <th scope="row" class="text-nowrap">$line</th>
                  <td style="text-overflow: ellipsis; overflow: hidden; max-width: 12rem">
                    <a href="$url" target="_blank" rel="noopener noreferrer">$url</a>
                  </td>
                  <td>$http_code</td>
                  <td>$encoding</td>
                  <td>
                    <a href=".$aspiration" target="_blank" rel="noopener noreferrer">html</a>
                  </td>
                  <td>
                    <a href=".$dump_text" target="_blank" rel="noopener noreferrer">"$(basename "$dump_text")"</a>
                  </td>
                  <td>
                    <a href=".$dump_text_iconv" target="_blank" rel="noopener noreferrer">"$(basename "$dump_text_iconv")"</a>
                  </td>
                  <td class="text-center">$occurrences</td>
                  <td>
                    <a href=".$contexte" target="_blank" rel="noopener noreferrer">"$(basename "$contexte")"</a>
                  </td>
                  <td>
                    <a href=".$concordance" target="_blank" rel="noopener noreferrer">"$(basename "$concordance")"</a>
                  </td>
                </tr>
EOF
    done < $fichier
cat >> "$out_file" <<EOF
              </tbody>
            </table>
          </div>
        </div>
      </section>
    </main>

    <footer class="footer text-center py-3">PPE • 2025-2026</footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  </body>
</html>
EOF
done	
    