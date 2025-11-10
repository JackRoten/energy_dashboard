import logging
from datetime import datetime
from tkinter import END
from dateutil.relativedelta import relativedelta
import json
import requests
import boto3

logging.basicConfig(
    level=logging.INFO,
    style='{',
    format='{asctime} | {levelname:<8s} | {name}:{lineno:5} | {message}'
)

# What data is of interest to us in this case?
secret_name = "api_postgres_secret"
region_name = "us-west-2"
api_secret_name = "eia_api_secret"

# Get DB credentials from Secrets Manager
session = boto3.session.Session()
client = session.client("secretsmanager", region_name=region_name)
secret = json.loads(client.get_secret_value(SecretId=secret_name)["SecretString"])
api_secret = json.loads(client.get_secret_value(SecretId=api_secret_name)["SecretString"])

# Setup URL
API_URL = f"https://api.eia.gov/v2"
ENDPOINT = f"/electricity/electric-power-operational-data/data"
URL = API_URL + ENDPOINT

# Setup params and headers
start = (datetime.today() - relativedelta(months=3)).strftime("%Y-%m")
end = (datetime.today() - relativedelta(months=2)).strftime("%Y-%m")

params = {"api_key": api_secret["api_key"]}
header = {
    "frequency": "monthly",
    "data": [
        "consumption-for-eg"
    ],
    "facets": {
        "location": [
            "CA"
        ]
    },
    "start": start,
    "end": end,
    "sort": [
        {
            "column": "period",
            "direction": "desc"
        }
    ],
    "offset": 0,
    "length": 5000
}

response = requests.get(URL, params=params, headers={"X-Params": json.dumps(header)})

if response.status_code != 200:
    logging.warning(f"Error in response: {response.status_code}")
    raise ValueError(f"Error in response: {response.status_code}")
else:
    logging.info(f"Response code: {response.status_code}, getting data")

response_json = response.json()
data = response_json['response']['data']

if not data:
    logging.warning(f"data for electric power operational {start} through {end} is empty")
    raise ValueError(f"data for electric power operational {start} through {end} is empty")
else:
    logging.info(f"data avalaible for {start} through {end}")


for record in data:

    # id must be unique
    # FOR TESTING OUTPUT
    id = record["period"] + "_" + record["location"] + "_" + record["fueltypeid"] + "_" + record["sectorid"]
    print(
        """
        INSERT INTO electric_power_operational (id, period, location, stateDescription, 
        sectorid, sectorDescription, fueltypeid, fuelTypeDescription, 
        consumption-for-eg, consumption-for-eg-units)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (id) DO UPDATE SET period = EXCLUDED.period, location = EXCLUDED.location, 
        stateDescription = EXCLUDED.stateDescription, sectorid = EXCLUDED.sectorid,
        sectorDescription = EXCLUDED.fueltypeid, fuelTypeDescription = EXCLUDED.fuelTypeDescription,
        consumption-for-eg = EXCLUDED.consumption-for-eg, consumption-for-eg-units = EXCLUDED.consumption-for-eg-units
        """,
        (id, record["period"], record["location"], record["stateDescription"], 
        record["sectorid"], record["sectorDescription"], record["fueltypeid"], 
        record["fuelTypeDescription"], record["consumption-for-eg"], record["consumption-for-eg-units"])
    )
