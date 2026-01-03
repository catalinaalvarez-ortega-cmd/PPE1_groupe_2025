#!/usr/bin/env bash


if [ $# -ne 2 ]; then
  echo "Argument 1 : <langue> (français, espagnol, arabe), argument 2 : <dossier> (contextes, dumps-text)"
  exit 1
fi

lang=$1
dossier=$2

# choix conditionnel des regex en fonction de la langue pour la tokenisation
if [ "$lang" = "arabe" ]; then
  sent='[.!?؟]'
  reg='\p{Arabic}\p{M}'
elif [ "$lang" = "français" ]; then
  sent='[.!?]'
  reg='\p{Latin}\p{M}'
elif [ "$lang" = "espagnol" ]; then
  sent='[.!?]'
  reg='\p{Latin}\p{M}'
else
  echo "Langue non prise en charge : $lang" >&2
  exit 1
fi

# On crée le dossiers de sortie s'ils n'existent pas
if [ ! -d "../pals/cooccurrent/$dossier" ]; then
    mkdir -p ../pals/cooccurrent/$dossier
fi

# Fichier de sortie
out="../pals/cooccurrent/$dossier/$dossier-$lang.txt"

# Mise en place de la tokenisation
# Boucle sur les fichiers textes du dossier
# avec sed nous substituons les ponctuations de fin de phrase par des sauts de ligne
# la solution avec tr affichait des caractères inconnus en fichier de sortie, d'où l'utilisation de perl
# ce qui nous permet d'utiliser une regex en fonction de la langue, tout ce qui n'est pas dans l'ensemnle autorisé est remplacé par un saut de ligne
# puis awk pour supprimer les lignes vides consécutives
for file in ../$dossier/"$lang"/"$lang"-*.txt; do

  sed -E "s/${sent}/\n\n/g" "$file" | perl -CSDA -pe "s/[^\n${reg}]+/\n/g" | awk ' NF { print; blank=0; next } !blank { print ""; blank=1 } ' >> "$out"

done

# Exemple d'appel de cooccurrents.py
# python3 cooccurrents.py ../pals/cooccurrent/contextes/contextes-espagnol.txt --target "orient.*" --match-mode regex -N 20 -s i > contextes.tsv

