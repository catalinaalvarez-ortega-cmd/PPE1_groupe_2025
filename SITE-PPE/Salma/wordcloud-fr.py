from wordcloud import WordCloud
import matplotlib.pyplot as plt
import pandas as pd


CORPORA = {
    "dump": "../PALS/francais_pals/cooc-dump-fr.tsv",
    "contextes": "../PALS/francais_pals/cooc-contextes-fr.tsv"
}

with open('../nuages/stopwords-fr.txt') as f:
    stopwords=f.read().splitlines()

for name, path in CORPORA.items():
    df=pd.read_csv(path, sep='\t', header=0)
    token_cooc=df.set_index('token').to_dict()['co-frequency']
    token_cooc_clean={}
    for token, frequencie in token_cooc.items():
        if token not in stopwords:
            token_cooc_clean[token]=frequencie

    wc = WordCloud(
        width=1400,
        height=700,
        background_color="white",
        collocations=False
    ).generate_from_frequencies(token_cooc_clean)

    img = f"../nuages/nuage_{name}_fr.png"

    plt.figure(figsize=(16, 8))
    plt.imshow(wc, interpolation="bilinear")
    plt.axis("off")
    plt.savefig(img, dpi=150)
    plt.close()

    print(f"Nuage créé : {img}")
