import pandas as pd
import re
import numpy as np

diet_dict = {
    "1": "fungivore",
    "2": "detritivore",
    "3": "phytophage",
    "4": "predator",
    "5": "parasitoid",
    "6": "ectoparasite",
    "7": "non-feeding",
    "8": "nectarivore",
}


def clean(f_in, **kwargs):
    df = pd.read_excel(f_in)
    df.columns = [
        "Taxon",
        "Tip name",
        "Extant richness",
        "Larval diet",
        "PS State",
        "Adult diet",
    ]
    df = df.drop(0)

    df_larval = df.drop(columns=["PS State", "Adult diet"]).rename(
        columns={"Larval diet": "diet"}
    )
    df_larval["stage"] = "larval"
    df_ps = df.drop(columns=["Larval diet", "Adult diet"]).rename(
        columns={"PS State": "diet"}
    )
    df_ps["stage"] = "PS"
    df_adult = df.drop(columns=["Larval diet", "PS State"]).rename(
        columns={"Adult diet": "diet"}
    )
    df_adult["stage"] = "adult"

    df_per_stage = [df_larval, df_ps, df_adult]

    for df in df_per_stage:
        df["diet"] = df["diet"].apply(
            lambda x: (re.sub(r"\([^()]*\)", "", str(x))).strip()
        )
        df["diet"] = df["diet"].str.split("&")
    df_per_stage = [df.explode("diet") for df in df_per_stage]

    df = pd.concat(df_per_stage, ignore_index=True)
    df["diet"].replace(diet_dict, inplace=True)

    df["Taxon"] = df["Taxon"].apply(lambda x: x.split(" ")[-1])
    df["Taxon"] = df["Taxon"].replace("\n", " ", regex=False)
    df["Taxon"] = df["Taxon"].replace(
        "Collembola_Brachystomellidae", "Brachystomellidae", regex=False
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
