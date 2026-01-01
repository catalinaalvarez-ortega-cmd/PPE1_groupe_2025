correction feuille d'exercices

echo "argument donne : $1"

echo "nombre de lieux en 2016 :"
cat "$CHEMIN/2016/"* | grep location | xc -l 


CHEMIN= il faut donner le chemin vers les fichiers 

EXERCICE 2:

DATADIR = $1 
ANNEE = $2
TYPE = $3

cat $ANNEE/*.ann ??? | grep "$TYPE" | wc -l 

cd $DATADIR
echo "Nous sommes ici" :
pdw

* créer des varibales pour stocker la variable pour récuperer les résultat
$()

* commande ou pipeline, va être stocker dans la variable. 
A=$(bash ./compte.sh $DATADIR 2016 $TYPE)

> || => "ou"
> && => "et"


EXERCICE 3. 

sort = trier, ordre alphabetique
uniq -c = evite la répetition 

1. vérifier le bon nombre d'arguments : et puis le tester

condition :

if [$# -ne 4] 'nombre d'arguments passé au programme'
then 
     echo "probleme !"
     exit
fi 

2. verifier que DATADIR est bien le fichier de données

if [ ! -d $DATADIR]
then 
    echo "$DATADIR n'est pas un dossier"
    exit
fi

3.

if [! -d $DATADIR/2016 ]
then
     echo "$DATADIR n'est probablement pas le bon dossier"
     exit
fi




B=$(bash ./compte.sh $DATADIR 2017 $TYPE)



Validation des arguments

Les boucles 

N=0

for ELEMENT in a b c d
do
   N=$(expr $N + 1)
   echo "le $N ieme élément est $ELEMENT"
done


## commenter l'exercice 4 : 

shebang 

On a une condition qui test si le nombre d'argument est égal à 1 lors de l'execution du script. Si la condition n'est pas respecté, la commande exit arrête l'execution du script. 

Ensuite, on a trois variables : fichier_urls défini par l'argument 1, les variables OK et NOK définies par 0. 

La boucle while utilise la commande "read", pour lire ligne par ligne le fichier. A chaque tour de boucle la commande echo permet d'afficher la ligne dans la sortie standard. Nous avons ensuite, une condition à double crochets, qui permet de vérifier, à l'aide d'une expression régulière, si la ligne commence par http:// ou https://, en outre si la condition est validée, le script affiche en sortie standard : ressemble à une URL valide et la varible OK s'incremente de 1. Cependant, si la condition n'est pas validée, les script affiche : "ne ressemble pas à une URL valide" et la varible NOK s'increment de 1. finalement, "done" termine la boucle while quand toutes les lignes sont lues, de même le script affiche les nombres des URls considérées comme correctes et "lignes douteuses"


 
                              
