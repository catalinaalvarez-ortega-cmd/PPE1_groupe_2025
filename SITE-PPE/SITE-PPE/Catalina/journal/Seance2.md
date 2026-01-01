## 08/10/25

Aujourd'hui on a du travailler avec un archive zip que je n'ai pu télécharger. Ma solution a été donc, de travailler avec l'archive zip d'une collègue. Je constante que j'ai des difficultés à manipuler les commandes, je vais faire donc, un résumé de ces commandes :

* mkdir <dir> = pour générer un nouveau dossier -> pour créer pkusiers dossier à la fois, sans imbrication = mkdir <dir1> <dir2> <dir3>

* rmdir <dir> = Supprimer un dossier vide ; ne fonctionne pas pour les dossiers contenant du contenu

* touch <file> = Générer un nouveau fichier sans spécifier d’extension

* cp <file1> <file2> <file3> /Users/<dir> = Dupliquer plusieurs fichiers dans un seul dossier

* rm <file> = Supprimer définitivement un fichier : prudence lors de l’utilisation de cette commande

* mv <file> <dir> = Déplacer un fichier dans un nouveau dossier ; permet l’écrasement éventuel de fichiers existants

* EX : mv /Users/catalinaalvarez/cours/exercice_1 ./plurital/ -> Déplacer le dossier "exercice_1" à le dossier "plurital".

* mv *.png ~/<dir> = Déplacer les fichiers portant l’extension PNG du dossier actuel vers un nouveau dossier.

Il faut que je tiens compte à chaque fois de déplacer un dossier, où je suis placée, à savoir, chemin absolu ou chemin relatif.
```
 cp -r ./txt/2016 ./ann/ 
```

Ce qu'a été très utile comme commande de manipulation, a été "*", qui remplace le reste des caractères.
Je l'ai utilisé notamment, au moment de déplacer les fichier qui comportent un nombre ou nom spécifique = ex : mv *_05_*.txt ./05, qui voulait dire les fichier texte avec 05 en milieu des autres caractères, le déplacer au dossier 05. 

* mv *.odt doc -> déplacer tous les fichier "odt" au dossier doc.

> BONNE PRATIQUE : savoir où je suis placée pour manipuler plus facilement les documents. 


## SCRIPT BASH 

### EXERCICE 1 

J'ai du utiliser grape -r comme une recherche récursive dans tous les sous-dossiers, parce que dans la commande cat 2016/*, * cible aussi les dossier, pas seulement les fichiers .ann, j'ai du donc changer ma commande à celle-là : 

- grep -r "Location" 2016/ | wc -l


Pour le reste, il ne faut pas oublier les définitions des commandes ci-dessous: 


- wc - l = compte les lignes trouvées.

- grep = sélectionne les ligne où "mot" apparait

- !/usr/bin/bash = shebang 





 
