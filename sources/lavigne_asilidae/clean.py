import os
import pandas as pd
import xlrd
import numpy as np


def clean(f_in, **kwargs):
    df = pd.read_excel(xlrd.open_workbook(f_in))
    df["consumer_name"] = df["PREDATOR"].map(str) + " " + df["PREDSPECIS"].map(str)

    df_res = df[["ORDER", "FAMILY", "GENUS", "SPECIES"]]
    df_res.loc[:, "ORDER"] = df_res.loc[:, "ORDER"].str.capitalize()
    df_res.loc[:, "ORDER"] = df_res.loc[:, "ORDER"].str.strip(":")
    df_res.loc[:, "ORDER"] = df_res.loc[:, "ORDER"].replace(
        '"other insects"', "Insecta"
    )

    for col in ["ORDER", "FAMILY", "GENUS", "SPECIES"]:
        df_res.loc[
            df_res[col].str.contains("undetermined", case=False, na=False, regex=False),
            col,
        ] = np.NaN
        df_res.loc[
            df_res[col].str.contains("unidentified", case=False, na=False, regex=False),
            col,
        ] = np.NaN
        df_res.loc[
            df_res[col].str.contains("?", case=False, na=False, regex=False), col
        ] = np.NaN
        df_res[col] = df_res[col].apply(
            lambda x: x.split("[")[0].strip(" ") if not pd.isna(x) else x
        )
        df_res[col] = df_res[col].apply(
            lambda x: x if not pd.isna(x) and not x.startswith('"') else np.NaN
        )

    df_res["GENUS"] = df_res[["FAMILY", "GENUS"]].apply(
        lambda x: x["GENUS"] if not x.isnull().values.any() else np.nan,
        axis=1,
    )
    df_res["resource_name"] = df_res[["GENUS", "SPECIES"]].apply(
        lambda x: x.str.cat(sep=" ") if not x.isnull().values.any() else np.nan,
        axis=1,
    )
    df_res["resource_name"] = df_res["resource_name"].replace(
        r"^\s*$", np.nan, regex=True
    )

    df_res["resource_name"] = df_res["resource_name"].combine_first(
        df_res["GENUS"].combine_first(df_res["FAMILY"].combine_first(df_res["ORDER"]))
    )

    df["resource_name"] = df_res["resource_name"].str.capitalize()

    df["consumer_name"] = df["consumer_name"].replace("\n", " ", regex=False)
    df["resource_name"] = df["resource_name"].replace("\n", " ", regex=False)

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
