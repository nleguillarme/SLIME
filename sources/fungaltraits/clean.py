import os
import pandas as pd


def clean(f_in, **kwargs):
    df = pd.read_excel(f_in, sheet_name="V.1.2")
    df["primary_lifestyle"] = df["primary_lifestyle"].str.replace("_", " ")
    df["Secondary_lifestyle"] = df["Secondary_lifestyle"].str.replace("_", " ")
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
