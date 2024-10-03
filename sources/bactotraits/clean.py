import pandas as pd


def clean(f_in, **kwargs):
    df = pd.read_csv(f_in, header=[2], sep=";", encoding_errors="ignore")
    df = df.rename(
        columns={
            "TT_heterotroph": "heterotroph",
            "TT_autotroph": "autotroph",
            "TT_organotroph": "organotroph",
            "TT_lithotroph": "lithotroph",
            "TT_chemotroph": "chemotroph",
            "TT_phototroph": "phototroph",
            "TT_copiotroph_diazotroph": "diazotroph",
            "TT_methylotroph": "methylotroph",
            "TT_oligotroph": "oligotroph",
        }
    )
    df["copiotroph"] = df["diazotroph"]
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
