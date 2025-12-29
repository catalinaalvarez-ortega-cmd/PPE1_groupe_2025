#!/bin/bash

stop_es="/Users/catalinaalvarez/cours/plurital/PPE1_groupe_2025/stopwords_es.txt"

for file in /Users/catalinaalvarez/cours/plurital/PPE1_groupe_2025/$dossier/"$lang"/"$lang"-*.txt; do
  [ -e "$file" ] || continue

  if [ "$lang" = "espagnol" ]; then
    iconv -f UTF-8 -t UTF-8 -c "$file" \
      | sed -E "s/${sent}/\n\n/g" \
      | perl -CSDA -pe "s/[^\n${reg}]+/\n/g" \
      | awk 'BEGIN{while((getline<ARGV[1])>0) sw[tolower($0)]=1; ARGV[1]=""}
             NF && sw[tolower($0)] { next }
             { print }' "$stop_es" \
      | awk 'NF { print; blank=0; next } !blank { print ""; blank=1 }' \
      >> "$out"
  else
    iconv -f UTF-8 -t UTF-8 -c "$file" \
      | sed -E "s/${sent}/\n\n/g" \
      | perl -CSDA -pe "s/[^\n${reg}]+/\n/g" \
      | awk 'NF { print; blank=0; next } !blank { print ""; blank=1 }' \
      >> "$out"
  fi
done




