"""

"""
import glob
import os

import pandas as pd


MAP = {
    "deployment_id": "deployment_name",
    "timestamp": "photo_datetime",
    "start_date": "sensor_start_date_and_time",
    "end_date": "sensor_end_date_and_time",
    "scientific_name": "sp_binomial"
}

COLS = [
    "site_name",
    "deployment_name",
    "latitude",
    "longitude",
    "photo_datetime",
    "genus",
    "species",
    "sensor_start_date_and_time",
    "sensor_end_date_and_time",
    "project_admin",
    "project_admin_organization",
    "class",
    "sp_binomial"
]

if __name__ == "__main__":

    data = pd.DataFrame()

    for path in glob.glob("data/*/"):
        name = path.split("/")[-2]
        images = pd.read_csv(os.path.join(path, "images.csv"))
        deployments = pd.read_csv(os.path.join(path, "deployments.csv"))

        df = pd.merge(images, deployments, on="deployment_id", how="left")
        df = df.dropna(subset=["genus", "species"], how="any")

        mask1 = df["genus"].isin(["No CV Result", "Unknown"])
        mask2 = df["species"].isin(["No CV Result", "Unknown"])
        df = df[~mask1 & ~mask2]

        df["scientific_name"] = df["genus"] + " " + df["species"]

        df["site_name"] = name
        df["project_admin"] = ""
        df["project_admin_organization"] = "Instituto Humboldt"

        df = df.rename(columns=MAP)
        df = df[COLS]

        data = data.append(df)

    data.to_csv("app/data.csv", index=False)
