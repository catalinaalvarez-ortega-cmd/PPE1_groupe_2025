## 22/10/2025

Dans la première heure du cours, on a analysé le code suivant : 

```
# !/ usr / bin / bash

if [ $ # - ne 1 ]
then
   echo " ce p ro g ra mm e demande un argument "
      exit
fi

F I C H I E R _ U R L S = $1
OK =0
NOK =0
while read -r LINE ;
do
   echo " la ligne : $LINE "
   if [[ $LINE =∼ ^ https ?:// ]]
   then
      echo " ressemble à une URL valide "
      OK = $ ( expr $OK + 1)
   else
      echo " ne ressemble pas à une URL valide "
      NOK = $ ( expr $NOK + 1)
   fi
   
done < $ F I C H I E R _ U R L S
echo " $OK URLs et $NOK lignes douteuses "

```

Voici les point clés : 

* read = fonction qui prend comme argument, un nom de variable et qu'elle va également stocker ce qu'elle reçoit sur l'entrée standard dans cette variable-là. (ça permet de lire la réponse de l'utilisateur)

* apres boucle while on attend une condition = 

* dans le cas où on change le code : 
```
cat $FICHIER URLS |  while read line; do ((OK++)); done
echo "$OK"   # → 0
```
 - ici le cat ne change pas la logique de lecture (les lignes sont identiques), mais change le contexte d'éxécution - les compteurs ou variables internes ne suivront pas à la boucle. préférence : done < "$fichier"
 

## interagir avec l'internet avec le terminal  

**HTML** = langage de balisage hypertexte; rajouter de la structure autour de quelque chose. Permet de structuré l'information avec les différents balises.

> http n'est pas sécurisé, htpps est securisé

**LYNX** = navigateur web qui va fonctionner avec le terminal. 

- aller sur un site web = lynx <adresse du site web> 
    - naviguer avec les flechès haut et bas (page suivante) et on rentre dans les liens avec droite et gauche. 
    
> Commande + Q pour fermer un programme  

**Exercice** 

deux option pour récuperer le cotenu d'une page pour l'afficher sur l'écran :

- récupérer le contenu textuel d’une page pour l’afficher (sans navigation)
   - chercher les options pour une commande, comment faire ? **R =** head ou man, lynx --help. (chercher sur le manuel)
   
   → option -dump
   
> -v : qui inverse ce qui est capturé ou pas.


- retirer la liste des liens d’une page à l’affichage
   → option -nolist
   
     - réperer ce qui est régulier dans la partie de la page, (expression regulière) = 
     ```=∼ ^ https ?://``` 
     
     **option grep** si je mets rien, il va, par exemple, chercher les occurence de HTTP
     
       ```lynx "les options" <url> ```
      

**CURL** 

curl <URL>

Où <URL> est une URL vers une page sur le web.
Quelques options utiles :
• -i : va donner des informations sur l’interaction avec le serveur
• -L : suit les redirections
• -o <fichier> : indique un <fichier> de sortie
• d’autres options à voir par vous-même : -I, -w, -s

> "tiret i majuscule", équivalent à l’option "head"
    

 


## Questions miniprojet :

1. Pourquoi ne pas utiliser cat ?
**R =** cat va simplement afficher tout le contenu du fichier dans le terminal, alors que nous souhaitons lire et/ou modifier les urls les unes après les autres, ce qui est possible avec la boucle while et la commande echo.

2. Comment transformer "urls/fr.txt" en paramètre du script ?
**R =** On va affecter une variable avec en valeur le chemin du répertoire, et nous pouvons ensuite tester l'existe du fichier.
Également, nous pouvons définir un argument le chemin du fichier qui sera utilisé pour l'éxecution.

2.1 Valider l’argument : ajouter le code nécessaire pour s’assurer qu’on donne bien un argument au script, sinon on s’arrête.
**R =** cf script

3. Comment afficher le numéro de ligne avant chaque URL (sur la même ligne) ?
• Bien séparer les valeurs par des tabulations

**R =** il faut utiliser un compteur dans la boucle while, c'est-à-dire qu'on attribue une valeur à une variable qui ajoutera 1 à chaque itération de boucle, ceci nous permettra d'afficher le numéro de la ligne, une tabulation et l'url.






fichier | while read -r LINE;
do
echo $LINE;
done    "afficher le contenu du fichier" 


if [ ! -f $1]
then
    echo "vous indiquez un fichier"
    exit 
fi



