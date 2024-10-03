import os
import pandas as pd

def clean(f_in, **kwargs):
    df = pd.read_excel(f_in, header=[1])
    df["nutrition bacterivore"] = df["nutrition bacterivore"].where(df["nutrition bacterivore"] != 1, "bacterivore")
    df["nutrition omnivore"] = df["nutrition omnivore"].where(df["nutrition omnivore"] != 1, "omnivore")
    df["nutrition eukaryvore"] = df["nutrition eukaryvore"].where(df["nutrition eukaryvore"] != 1, "eukaryvore")
    df["nutrition plant parasite"] = df["nutrition plant parasite"].where(df["nutrition plant parasite"] != 1, "plant parasite")
    df["nutrition parasite (not plant)"] = df["nutrition parasite (not plant)"].where(df["nutrition parasite (not plant)"] != 1, "parasite")
    df["nutrition unknown"] = df["nutrition unknown"].where(df["nutrition unknown"] != 1, "unknown")
    df["trophic.group"] = df[["nutrition bacterivore", "nutrition omnivore", "nutrition eukaryvore", "nutrition plant parasite", "nutrition parasite (not plant)", "nutrition unknown"]].apply(lambda x: [s for s in x if not pd.isnull(s)][-1], axis=1)
    df["Species"] = df["Species"].apply(lambda x: ' '.join(x.split("_")))
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
