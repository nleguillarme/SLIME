import pandas as pd


def clean(f_in, **kwargs):
    df = pd.read_excel(
        f_in, sheet_name=["TabS1B_complete_dataset", "TabS1C_references_used"]
    )
    df_data = df["TabS1B_complete_dataset"]
    df_ref = df["TabS1C_references_used"]
    df_data["feeding"] = df_data["feeding"].str.split("_or_")
    df_data = df_data.explode("feeding")
    df_data["reference"] = df_data["reference"].str.replace(" ", "")
    df_data["reference"] = df_data["reference"].str.split(";")
    df_data = df_data.explode("reference")
    df_data = df_data.drop_duplicates(
        subset=["feeding", "reference", "scientific_ncbi"]
    )

    ref_dict = pd.Series(
        df_ref.reference_full.values, index=df_ref.reference_id
    ).to_dict()

    df_data["reference"] = df_data["reference"].map(ref_dict)

    return df_data


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
