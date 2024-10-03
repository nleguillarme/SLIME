import pandas as pd
import re


def clean(f_in, **kwargs):
    df = pd.read_csv(f_in, encoding="latin1")
    print(df.head())
    df["consumer_name"] = df[["Genus", "Species"]].agg(" ".join, axis=1)
    df = df.drop(df[df["Diet"] == "Not in paper"].index)
    df["Diet"] = df["Diet"].apply(lambda x: str(x)[:-4])
    df["Diet"] = df["Diet"].apply(lambda x: str(x).split(" + "))
    df = df.assign(Diet=df["Diet"]).explode("Diet")
    df["Diet"] = df["Diet"].str.capitalize()
    return df


import argparse
from pathlib import Path

parser = argparse.ArgumentParser()

parser.add_argument("--integraph_filepath")
parser.add_argument("--integraph_outputdir")

args = parser.parse_args()

filepath = Path(args.integraph_filepath)
outputdir = Path(args.integraph_outputdir)
output_filepath = outputdir / filepath.name
output_filepath.parent.mkdir(parents=True, exist_ok=True)

df = clean(filepath)

df.to_csv(output_filepath, sep=",")

print(output_filepath)
