"""

"""
import pandas as pd

from pathlib import Path
from PIL import Image


if __name__ == "__main__":
    

    data = pd.read_csv("app/data.csv")

    projects = pd.read_csv('data/projects.csv')
    deployments = pd.read_csv('data/deployments.csv')

    projects = projects[['project_id','project_short_name',
                            'project_admin', 
                        'project_admin_organization', 'country_code']]

    deployments = deployments[['subproject_name','project_id', 'placename','latitude','longitude']]

    sites = pd.merge(projects, deployments, on='project_id')

    # Select first place
    sites = sites.drop_duplicates(subset=['project_id']).set_index('project_id')

    sites = sites.rename(columns={'latitude':'lat' , 
                                'longitude':'lon',
                                'country_code':'departamento',
                                'project_admin':'collector',
                                'project_admin_organization':'organization_name'})

    for row, site in enumerate(data['project_id'].unique()):

        df = data[data["project_id"] == site]

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
        sites.loc[site, "row"] = row

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
    sites['site_name'] = sites.index
    
    sites.to_csv("app/sites.csv", index_label="site_name")


    n_resized = 0
    for image_path in Path('app/www/favorites').rglob('*.jpg'):
        try:
            im = Image.open(image_path)
            original_width, original_height = im.size
            new_image = im.resize((390, int(original_height/(original_width/390))))
            new_image.save(image_path)
            n_resized += 1
        except:
            pass
    print('Resized images:', n_resized)
