from nltk import word_tokenize
from nltk.tokenize import sent_tokenize
from nltk.tokenize import WordPunctTokenizer
import sys

in_path = sys.argv[1]
out_path = sys.argv[2]

tokenizer = WordPunctTokenizer()

tokens = []

try:
    with open(in_path) as f:
        for sentence in sent_tokenize(f.read()):
            tokens.extend(tokenizer.tokenize(sentence))
except:
    pass

with open(out_path, mode='w+') as f:
    f.write('\n'.join(tokens))
