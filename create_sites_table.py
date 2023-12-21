"""

"""
import pandas as pd

if __name__ == "__main__":

    data = pd.read_csv("app/data.csv")

    sites = pd.DataFrame(
        index=["Piedemonte Casanare", "Rio Tillava"],
        data={
            "lat": [5.0956, 3.80056],
            "lon": [-72.8055, -71.41203],
            "departamento": ["Casanare", "Meta"],
            "collector": ["", ""],
            "organization_name": ["Fundación Cunaguaro", "Gaica"]
        }
    )

    for i, site in enumerate(sites.index):

        df = data[data["site_name"] == site]

        sites.loc[site, "n"] = len(df)
        sites.loc[site, "ospMamiferos"] = df[df["class"] == "Mammalia"]["sp_binomial"].nunique()
        sites.loc[site, "ospAves"] = df[df["class"] == "Aves"]["sp_binomial"].nunique()
        # sites.loc[site, "ospMamiferos"] = df[df["class"] == "Mammalia"]["sp_binomial"].count()
        # sites.loc[site, "ospAves"] = df[df["class"] == "Aves"]["sp_binomial"].count()
        sites.loc[site, "ndepl"] = df["deployment_name"].nunique()
        sites.loc[site, "start_date"] = pd.to_datetime(df["sensor_start_date_and_time"]).min()
        sites.loc[site, "end_date"] = pd.to_datetime(df["sensor_end_date_and_time"]).max()
        sites.loc[site, "ospTot"] = df["sp_binomial"].nunique()
        # sites.loc[site, "ospTot"] = len(df)
        # sites.loc[site, "nspMamiferosCol"] = 94
        # sites.loc[site, "nspAvesCol"] = 110
        sites.loc[site, "row"] = i

        sites.loc[site, "nspMamiferos"] = sites.loc[site, "ospMamiferos"]
        sites.loc[site, "nspAves"] = sites.loc[site, "ospAves"]
        sites.loc[site, "nspTot"] = sites.loc[site, "ospTot"]

        deployments = df.drop_duplicates("deployment_name").copy()
        deployments["start"] = pd.to_datetime(deployments["sensor_start_date_and_time"])
        deployments["end"] = pd.to_datetime(deployments["sensor_end_date_and_time"])
        deployments["days"] = pd.to_timedelta(deployments["end"] - deployments["start"]).dt.days
        sites.loc[site, "effort"] = deployments["days"].sum()

    sites["rank_onsp"] = sites["ospTot"].rank(method="max", ascending=False)
    sites["rank_onMamiferos"] = sites["ospMamiferos"].rank(method="max", ascending=False)
    sites["rank_onAves"] = sites["ospAves"].rank(method="max", ascending=False)
    sites["rank_effort"] = sites["effort"].rank(method="max", ascending=False)
    sites["rank_images"] = sites["n"].rank(method="max", ascending=False)
    sites["rank_ndepl"] = sites["ndepl"].rank(method="max", ascending=False)

    sites.to_csv("app/sites.csv", index_label="site_name")
