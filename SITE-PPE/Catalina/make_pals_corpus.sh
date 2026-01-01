#!/usr/bin/env bash

BASE="/Users/catalinaalvarez/cours/plurital/PPE1_groupe_2025"
PALS_DIR="/Users/catalinaalvarez/cours/plurital/PPE1_groupe_2025/PALS"
STOP_ES="/Users/catalinaalvarez/cours/plurital/PPE1_groupe_2025/nuages/stopwords_es.txt"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <langue> <dossier>" >&2
  echo "  langue : arabe | français | espagnol" >&2
  echo "  dossier: contextes | dumps-text" >&2
  exit 1
fi

lang=$1
dossier=$2

case "$dossier" in
  contextes|dumps-text) ;;
  *) echo "Dossier invalide: $dossier" >&2; exit 1 ;;
esac

case "$lang" in
  arabe)    sent='[.!?؟]' ;;
  français) sent='[.!?]'  ;;
  espagnol) sent='[.!?]'  ;;
  *) echo "Langue non prise en charge: $lang" >&2; exit 1 ;;
esac

mkdir -p "$PALS_DIR/cooccurrent/$dossier"
out="$PALS_DIR/cooccurrent/$dossier/$dossier-$lang.txt"
: > "$out"

# Conversion robuste vers UTF-8 (important si certains fichiers ne sont pas UTF-8 strict)
to_utf8() {
  local f="$1"
  if iconv -f UTF-8 -t UTF-8 "$f" >/dev/null 2>&1; then
    cat "$f"
  elif iconv -f WINDOWS-1252 -t UTF-8 "$f" >/dev/null 2>&1; then
    iconv -f WINDOWS-1252 -t UTF-8 "$f"
  elif iconv -f ISO-8859-1 -t UTF-8 "$f" >/dev/null 2>&1; then
    iconv -f ISO-8859-1 -t UTF-8 "$f"
  else
    iconv -f UTF-8 -t UTF-8 -c "$f"
  fi
}

count_files=0
count_skipped_empty=0

for file in "$BASE/$dossier/$lang/$lang"-*.txt; do
  [ -e "$file" ] || continue

  if [ ! -s "$file" ]; then
    count_skipped_empty=$((count_skipped_empty+1))
    continue
  fi

  count_files=$((count_files+1))

  # Segmentation + tokenisation Unicode safe:
  # - transforme fin de phrase en ligne vide (\n\n)
  # - conserve toutes les lettres Unicode + diacritiques (accents)
  # - le reste devient \n
  to_utf8 "$file" \
    | perl -CSDA -pe "s/${sent}/\n\n/g; s/[^\n\p{L}\p{M}]+/\n/g" \
    | {
        if [ "$lang" = "espagnol" ] && [ -f "$STOP_ES" ]; then
          STOP_ES="$STOP_ES" perl -CSDA -MUnicode::Normalize=NFKC -ne '
            BEGIN {
              open my $fh, "<:encoding(UTF-8)", $ENV{STOP_ES} or die "Stopwords introuvable\n";
              while (<$fh>) {
                chomp; s/\r$//;
                my $w = lc NFKC($_);
                $sw{$w} = 1 if $w ne "";
              }
            }
            chomp; s/\r$//;
            if ($_ eq "") { print "\n"; next }   # garder séparateurs de phrases
            my $t = lc NFKC($_);

            next if length($t) < 2;              # retire bruit 1-char
            next if $sw{$t};                     # stopwords
            print "$t\n";
          '
        else
          cat
        fi
      } \
    | awk 'NF { print; blank=0; next } !blank { print ""; blank=1 }' \
    >> "$out"

  echo >> "$out"
done

echo "Corpus PALS généré: $out" >&2
echo "Fichiers traités: $count_files ; fichiers vides ignorés: $count_skipped_empty" >&2
