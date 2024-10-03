import pandas as pd


def clean(f_in, **kwargs):
    df = pd.read_csv(f_in)
    df = df.dropna(
        subset=[
            "SoleHostplantFamily",
            "PrimaryHostplantFamily",
            "SecondaryHostplantFamily",
        ],
        how="all",
    )
    df["host"] = df[
        ["SoleHostplantFamily", "PrimaryHostplantFamily", "SecondaryHostplantFamily"]
    ].apply(lambda x: ",".join(x.dropna().astype(str)).split(","), axis=1)
    df = df.explode("host")
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
