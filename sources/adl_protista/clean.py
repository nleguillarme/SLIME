import os
import pandas as pd

def clean(f_in, **kwargs):
    df = pd.read_csv(f_in, sep="\t")
    df["taxid"] = df["taxid"].str.replace("_", ":")
    df["consumer_name"] = df["full.taxonomic.path"].apply(
        lambda x: x.split(";")[-2].strip()
    )
    df = df.drop(df[df.consumer_name == "Incertae Sedis"].index)
    df["trophic.group"] = df["trophic.group"].str.split("|")
    df = (
        df.assign(trophic_group=df["trophic.group"])
        .explode("trophic.group")
        .drop(columns=["trophic_group"])
        .dropna(subset=["trophic.group"])
    )
    df["trophic.group"] = df["trophic.group"].apply(
        lambda x: str(x) + "e" if x.endswith("phag") or x.endswith("or") else str(x)
    )
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
