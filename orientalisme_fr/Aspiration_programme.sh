#!/bin/bash

fichier=$1
indice=1

if [ $# -ne 1 ]
then
    echo "le script attend exactement un argument: le chemin vers le fichier d'url. "
    exit
fi

while read -r url ;
do

    curl $url > "Aspirations/fr-$indice.html"
    error_code=$?
    indice=$( expr $indice + 1);
done < $fichier;
