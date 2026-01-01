## 26/11/2025

pip
venv
uv

Activate with: source venvs/plurital/bin/activate

commande = source $HOME/venvs/plurital/bin/activate

source (...) à chaque fois que tu veux activer ton environement 

uv pip --help 

  994  cd PPE1-2526
  995  git status
  996  open 
  997  cd ..
  998  open PPE1-2526
  999  cd PPE1-2526
 1000  git pull
 1001  ls
 1002  brew install uv
 1003  clear
 1004  uv
 1005  uv venv $HOME/venvs/plurital
 1006  source $HOME/venvs/plurital/bin/activate
 1007  where is python3
 1008  uv pip install wordcloud
 1009  wordcloud_cli --help
 
 /Users/catalinaalvarez/cours/plurital/PPE1-2526/docs
 
 echo le
 
 stopwords file
 
  1023  wordcloud_cli --text pg16066.txt
 1024  wordcloud_cli --text pg16066.txt--imagefile pg16066.png
 1025  open pg16066.png
 1026  wordcloud_cli --text pg16066.txt--imagefile pg16066.png
 1027  wordcloud_cli --text pg16066.txt --imagefile pg16066.png
 1028  open pg16066.png
 1029  wordcloud_cli --text pg16066.txt --imagefile pg16066.png --stopwords stopwords.txt
 1030  open pg16066.png
 1031  open pg16066.png
 1032  wordcloud_cli --text  /Users/catalinaalvarez/cours/plurital/PPE1-2526/docs/pg16066.txt --imagefile pg16066.png --stopwords stopwords.txt
 1033  wordcloud_cli --text  /Users/catalinaalvarez/cours/plurital/PPE1-2526/docs/pg16066.txt --imagefile pg16066.png
 1034  open pg16066.png
 1035  wordcloud_cli --text pg16066.txt --imagefile pg16066.png --stopwords stopwords.txt
 1036  wordcloud_cli --text pg16066.txt --imagefile nuage.png --stopcords stopwords.txt
 1037  wordcloud_cli --text pg16066.txt --imagefile nuage.png --stopwords stopwords.txt




which python3 = pour savoir quel environement python travailler 


 1003  git pull
 1004  cd ressources
 1005  cd tokenization
 1006  ls
 1007  cd Chinois
 1008  ls
 1009  cat chinois.txt
 1010  cd requirements.txt
 1011  uv pip install -r requirements.txt
 1012  ls
 1013  cd requirements.txt
 1014  uv pip install -r requirements.txt
 1015  source $HOME/venvs/plurital/bin/activate
 1016  uv pip install -r requirements.txt
 1017  python tokenise_chinese.py chinois.txt > chinois_seg.txt
 1018  cat chinois.txt | python tokenize_chinese.py > chinois_seg.txt
 
 
## PALS

python3 ./cooccurrents.py --target robot fr-*.txt -N 10 

python3 ./cooccurrents.py --target "robot" fr-*.txt -N 10 -s i 

enumerer l'ensemble de fichier dans un corpus pour faire l'execice de cooccurents  = fr-*.txt prendre l'ensemble de fichier .txt > fichier.tsv <- pour stocker
