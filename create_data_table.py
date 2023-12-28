"""

"""
import os
import glob

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

        # replace with your folder's path
    folder_path = 'data'

    all_files = os.listdir(folder_path)
    # Filter out non-CSV files
    images_files = [f for f in all_files if 'images' in f]
    csv_files = [f for f in images_files if f.endswith('.csv')]

    # Create a list to hold the dataframes
    df_list = []

    for csv in csv_files:
        file_path = os.path.join(folder_path, csv)
        try:
            # Try reading the file using default UTF-8 encoding
            df = pd.read_csv(file_path)
            df_list.append(df)
        except UnicodeDecodeError:
            try:
                # If UTF-8 fails, try reading the file using UTF-16 encoding with tab separator
                df = pd.read_csv(file_path, sep='\t', encoding='utf-16')
                df_list.append(df)
                
            except Exception as e:
                print(f"Could not read file {csv} because of error: {e}")
        except Exception as e:
            print(f"Could not read file {csv} because of error: {e}")

    # Concatenate all data into one DataFrame
    big_df = pd.concat(df_list, ignore_index=True)

    # Save the final result to a new CSV file
    big_df.to_csv(os.path.join(folder_path, 'images.csv'), index=False)


    # Create data table 

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
