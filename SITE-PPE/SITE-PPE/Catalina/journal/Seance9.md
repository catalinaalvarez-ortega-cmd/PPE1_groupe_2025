# 10/12/2015
cat chinois.txt  iconv -f UTF-8 --t GB2312 | iconv -f GB312 -t 



echo "héhéÿ" iconv -f UTF-8 --t GB2312 | iconv -f GB312 -t 

vérifier l'encodage et s'assurer avec iconv |
