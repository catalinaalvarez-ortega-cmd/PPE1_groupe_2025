import sys
import pandas as pd

in_path = sys.argv[1]
out_path = sys.argv[2]
df=pd.read_csv(in_path,sep='\t', header=0)
with open(out_path,'w') as html_file:
    html_file.write(df.to_html(index=False))
