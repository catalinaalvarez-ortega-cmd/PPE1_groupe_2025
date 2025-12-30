#!/usr/bin/env bash

DIR_D="/Users/benhadjsghaier.my/PPE1_groupe_2025/dumps-text/arabe"
DIR_C="/Users/benhadjsghaier.my/PPE1_groupe_2025/contextes/arabe"
PALS_DIR="/Users/benhadjsghaier.my/PPE1_groupe_2025/PALS/arabe"

OUTFILE1="$PALS_DIR/dump-arabe1.txt"
OUTFILE2="$PALS_DIR/contexte-arabe.txt"

mkdir -p "$PALS_DIR"

: > "$OUTFILE1"
: > "$OUTFILE2"

for f in "$DIR_D"/arabe-*.txt "$DIR_C"/arabe*.txt; do
    if [[ "$f" == "$DIR_D"/* ]]; then
        iconv -f UTF-8 -t UTF-8 -c "$f" \
        | sed 's/ـ//g' \
        | sed 's/[أإآ]/ا/g; s/ى/ي/g' \
        | sed 's/[[:punct:]]//g' \
        | grep -v '^[[:space:]]*$' \
        >> "$OUTFILE1"
    else
        iconv -f UTF-8 -t UTF-8 -c "$f" \
        | sed 's/_//g' \
        | sed 's/[أإآ]/ا/g; s/ى/ي/g' \
        | sed 's/[[:punct:]]//g' \
        | grep -v '^[[:space:]]*$' \
        >> "$OUTFILE2"
    fi
done
