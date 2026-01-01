#!/bin/bash

# message d'erreur si le nombre d'arguments est incorrect
if [[ $# -ne 3 ]]; then
    echo "Arguments manquants <motif_a_rechercher> <chemin_du_fichier_dump> <chemin_du_fichier_concordance>"
    exit 1
fi

# definition des variables
motif=$1
context=$2
concordancier_html=$3
concordancier_basename=$(basename "$concordancier_html")

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
<div class=\"box\"><span class=\"is-size-1\">Tableau de concordance : \"$concordancier_basename\"</span></div>
<nav class=\"navbar mb-6\" role=\"navigation\" aria-label=\"main navigation\">
    <div id=\"navbarBasicExample\" class=\"navbar-menu\">
    <div class=\"navbar-start\">
        <a class=\"navbar-item\" href=\"../../index.html\"> Accueil </a>
        <a class=\"navbar-item\"> Script </a>
        <a class=\"navbar-item has-background-info-light\"> Tableaux </a>
    </div>
    </div>
</nav>
<span class=\"tag is-dark is-large\">Concordancier autour du mot $motif</span>
<table class=\"table mx-auto is-striped is-narrow is-fullwidth my-6\">
  <thead>
    <tr>
      <th class="has-text-right">Contexte gauche</th>
      <th class="has-text-centered">Cible</th>
      <th>Contexte droit</th>
    </tr>
  </thead>
  <tbody>" > "$concordancier_html"

grep -a -o ".\{0,30\}$motif.\{0,30\}" "$context" | while read -r line; do
    gauche=$(echo "$line" | sed -E "s/(.*)$motif.*/\1/")
    droite=$(echo "$line" | sed -E "s/.*$motif(.*)/\1/")

    echo -e "    <tr>
      <td class=\"has-text-right\">$gauche</td>
      <td class=\"has-text-success has-text-centered\">$motif</td>
      <td>$droite</td>
    </tr>" >> "$concordancier_html"
done

echo "  </tbody>
</table>
</div>
</body>
</html>" >> "$concordancier_html"
