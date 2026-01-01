from wordcloud import WordCloud
import matplotlib.pyplot as plt
import arabic_reshaper
from bidi.algorithm import get_display
import os
import glob

stopwords = {
    "", "", "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "", "", "",
    "", "", "", "", "", ""
}

context_dir = "/Users/benhadjsghaier.my/PPE1_groupe_2025/contextes/arabe"

files = sorted(glob.glob(os.path.join(context_dir, "arabe-*.txt")))
files = [f for f in files if not f.endswith("-bigrams.txt")]

if not files:
    raise FileNotFoundError(f"Aucun fichier arabe-*.txt trouv dans {context_dir}")

text_parts = []
for fp in files:
    with open(fp, "r", encoding="utf-8", errors="ignore") as f:
        text_parts.append(f.read())

text = "\n".join(text_parts)

mots = text.split()
mots_sans_stopwords = [m for m in mots if m not in stopwords]

boost = (
    [""] * 250 +
    [""] * 250 +
    [""] * 200 +
    [""] * 200 +
    [""] * 250 +
    [""] * 250
)

mots_sans_stopwords += boost

text_clean = " ".join(mots_sans_stopwords)

reshaped = arabic_reshaper.reshape(text_clean)
final_text = get_display(reshaped)

font_path = "/Library/Fonts/GeezaPro.ttc"

wc = WordCloud(
    width=1200,
    height=700,
    background_color="white",
    font_path=font_path,
    collocations=False
).generate(final_text)

output_folder = "/Users/benhadjsghaier.my/PPE1_groupe_2025/tableaux/wordcloud"
os.makedirs(output_folder, exist_ok=True)

output_path = os.path.join(output_folder, "arabe.png")
wc.to_file(output_path)

img = wc.to_image()
plt.figure(figsize=(12, 7))
plt.imshow(img)
plt.axis("off")
plt.tight_layout()
plt.show()

print("Nuage enregistr :", output_path)
