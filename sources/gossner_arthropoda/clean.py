import pandas as pd

guild_dict = {
    "h": "herbivore",
    "c": "carnivore",
    "f": "fungivore",
    "d": "detritivore",
    "o": "omnivore",
}


def clean(f_in, **kwargs):
    df = pd.read_csv(f_in, sep="\t", encoding_errors="replace")
    df["Feeding_guild"] = df["Feeding_guild"].str.replace("[\(\)]", "", regex=True)
    df["Feeding_guild"] = df["Feeding_guild"].str.split("-")
    df = df.explode("Feeding_guild")
    df["Feeding_guild"] = df["Feeding_guild"].map(guild_dict)
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
