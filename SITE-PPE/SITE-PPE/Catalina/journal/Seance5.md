## 05/11/2025

then
     echo "le script attend exactement ..."
     
     exit
     


lineno = 1

while read -r line;
do
     
     echo -e "${lineno} \t${line}";
     lineno =$(expr $lineno + 1)

done < $FICHIER_URL;


BASH/PROGRAMMES/MINIPROJET/

ls -l (lire/afficher le nombre de lignes)

mkdir a\*isborn

ls un dossier n'est pas le même que ls un\dossier (éviter les spaces)


# EXERCICE 2:

RÉCUPERER LE CODE HTTP, ENCODAGE, ET NOMBRE DE MOTS 

curl -i  -w (a la fin tu va m'affciher des choses en plus) "%{http_code}" h\n% http:// ...

(avoir le reflexe de lire le manuel (ex : man curl))
content-type : text./

-s (silence)

\ = option + maj + / 

head -1 metadata.tmp
 récuperer le chart
 
 content_type=$(head -1) 
 cut -d = -f2 récuperer la deuxième colonne 
 
 echo "text/html"  | cur -d = -f2
 
 echo $content_type | grep -E -o "charset=.*" | cut -d= -f2
 
 
 -stdin recuperer la page html 
 
 lynx --help
 
 
 
 compte les mots : 
 
 cat tmp.txt | lynx -dump -stdin -nolist | wc -w 
 

## HTML

table = la balise racine du tableau
tr = table row, une ligne (se place dans table)
th = table header, une cellule d'entête
td = table data une cellule classique 
 
 
