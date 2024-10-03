import pandas as pd
import re

ADF_MAP = {
    "Hf": "Herbflower",
    "Er": "Ergot",
    "Sf": "Shrub/tree flower",
    "Hd": "Honeydew",
    "Sa": "Sap",
    "Dp": "Decaying plant",
    "An": "Animal",
    "Mi": "Mineral",
}


def clean(f_in, **kwargs):
    df = pd.read_excel(f_in, sheet_name=1)
    df = df[["ID", "Taxon", "Family", "ADF"]]
    print(df.head())
    df["ADF"] = df["ADF"].apply(lambda x: re.findall("[A-Z][^A-Z]*", str(x)))
    df = df.assign(ADF=df["ADF"]).explode("ADF")
    df["ADF"] = df["ADF"].replace(ADF_MAP)
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
