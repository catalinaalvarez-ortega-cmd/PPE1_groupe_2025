## 19/11/2025

exercices regex :

URLS :

(https?:\/\/|www\.)[^\s]+[a-zA-Z0-9]\/?

numéros 


mots : 
[A-zA-Zéèêàùîï]*


\p = propriété unicode 
> \p{l}*

> \p{Ll}*




sed 'suive d'une expression régulière'
man sed

's/ ... / ... /'
on peut le mettre dans un pipeline 

cat pg...txt |  grep moulins | sed 's/moulins/MOULINS/'

cat pg...txt |  grep moulins | sed 's/moulins (...\) /MOULINS/'




# APPRENDRE À CORRIGER DES ERREURS (GITHUB)


* git reset
revient à la version "HEAD" du dépôt

> git reset <commit> 

* git stash :
les mofifications courants 
> git stash list 


* git checkout

téleporter à un état donné 


* git checkout commit 




fetch avant le push 

recuperer meta donnes du dépot

pour voir si l'on a de commit en retard 

SYNTAXE : 

HEAD 
tag 
