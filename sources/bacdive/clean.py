import pandas as pd


def clean(f_in, **kwargs):
    names = [
        "strains.ID_strains",
        "strains.Culture collection no.",
        "strains.Domain",
        "strains.Phylum",
        "strains.Class",
        "strains.Order",
        "strains.Family",
        "strains.Genus",
        "strains.Species",
        "strains.Full Scientific Name",
        "strains.Strain Designation",
        "strains.Variant",
        "strains.Type strain",
        "strains_tax_PNU.Species",
        "strains_tax_PNU.Full Scientific Name (LPSN)",
        "strains_tax_PNU.ID_reference",
        "strains_taxid.tax_id",
        "strains_taxid.tax_level",
        "nutrition_type.Nutrition type",
        "nutrition_type.ID_reference",
        "origin.Host species",
        "origin.Geographic location (country and/or sea region)",
        "origin.Country",
        "origin.Continent",
        "origin.Geographic location (latitude)",
        "origin.Geographic location (longitude)",
        "origin.ID_reference",
        "risk_assessment.Pathogenicity (human)",
        "risk_assessment.Pathogenicity (animal)",
        "risk_assessment.Pathogenicity (plant)",
        "risk_assessment.ID_reference",
    ]
    df = pd.read_csv(
        f_in,
        header=None,
        sep=",",
        skiprows=11,
        names=names,
        dtype={"strains_taxid.tax_id": "Int64"},
    )
    species_id_map = {}
    df_drop = df.dropna(subset=["strains_taxid.tax_id"])
    for _, row in df_drop.iterrows():
        species_id_map[row["strains.Species"]] = row["strains_taxid.tax_id"]

    df["strains_taxid.tax_id"] = df["strains_taxid.tax_id"].fillna(
        df["strains.Species"].map(species_id_map)
    )
    df = df.dropna(subset=["nutrition_type.Nutrition type"])
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
