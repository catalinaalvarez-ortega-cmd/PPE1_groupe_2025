from wordcloud import WordCloud
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.colors import ListedColormap

CORPORA = {
    "dump": "/Users/catalinaalvarez/cours/plurital/PPE1_groupe_2025/PALS/espagnol_pals/dumps-text.tsv",
    "contextes": "/Users/catalinaalvarez/cours/plurital/PPE1_groupe_2025/PALS/espagnol_pals/contextes.tsv",
}

with open('/Users/catalinaalvarez/cours/plurital/PPE1_groupe_2025/nuages/stopwords_es.txt', encoding="utf-8") as f:
    stopwords = set(line.strip().lower() for line in f if line.strip())

palette = ["#0e1a40", "#222f5b", "#5d5d5d", "#946b2d", "#000000"]
my_cmap = ListedColormap(palette)

for name, path in CORPORA.items():
    df = pd.read_csv(path, sep='\t', header=0)

    # IMPORTANT : adaptez si l'en-tête n'utilise pas "frequency"
    weight_col = "frequency"

    token_weights = df.set_index('token').to_dict()[weight_col]

    token_clean = {}
    for token, w in token_weights.items():
        t = str(token).strip().lower()
        if t and t not in stopwords:
            token_clean[t] = w

    wc = WordCloud(
        width=1400,
        height=700,
        background_color="white",
        collocations=False,
        colormap=my_cmap,
        random_state=42
    ).generate_from_frequencies(token_clean)

    img = f"/Users/catalinaalvarez/cours/plurital/PPE1_groupe_2025/nuages/nuage_{name}_es.png"

    plt.figure(figsize=(16, 8))
    plt.imshow(wc, interpolation="bilinear")
    plt.axis("off")
    plt.savefig(img, dpi=150)
    plt.close()

    print(f"Nuage créé : {img}")
