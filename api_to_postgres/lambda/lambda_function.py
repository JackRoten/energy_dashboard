import logging
import os
from datetime import datetime
from dateutil.relativedelta import relativedelta
import json
import psycopg2
import requests
import boto3

logging.basicConfig(
    level=logging.INFO,
    style='{',
    format='{asctime} | {levelname:<8s} | {name}:{lineno:5} | {message}'
)

def lambda_handler(event, context):
    region_name = os.environ["REGION_NAME"]
    db_secret_name = os.environ["DB_SECRET_NAME"]
    api_secret_name = os.environ["EIA_SECRET_NAME"]
    
    # Get DB credentials from Secrets Manager
    session = boto3.session.Session()
    client = session.client("secretsmanager", region_name=region_name)
    db_secret = json.loads(client.get_secret_value(SecretId=db_secret_name)["SecretString"])
    api_secret = json.loads(client.get_secret_value(SecretId=api_secret_name)["SecretString"])

    conn = psycopg2.connect(
        host=db_secret["host"],
        database=db_secret["dbname"],
        user=db_secret["username"],
        password=db_secret["password"],
        port=db_secret.get("port", 5432),
    )
    cursor = conn.cursor()

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
        id = record["period"] + "_" + record["location"] + "_" + record["fueltypeid"] + "_" + record["sectorid"]
        cursor.execute(
            """
            INSERT INTO electric_power_operational (id, period, location, state_description, 
            sectorid, sector_description, fueltypeid, fuel_type_description, 
            consumption_for_eg, consumption_for_eg_units)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO UPDATE SET period = EXCLUDED.period, location = EXCLUDED.location, 
            state_description = EXCLUDED.state_description, sectorid = EXCLUDED.sectorid,
            sector_description = EXCLUDED.sector_description, fueltypeid = EXCLUDED.fueltypeid,
            fuel_type_description = EXCLUDED.fuel_type_description, consumption_for_eg = EXCLUDED.consumption_for_eg, 
            consumption_for_eg_units = EXCLUDED.consumption_for_eg_units
            """,
            (id, record["period"], record["location"], record["stateDescription"], 
            record["sectorid"], record["sectorDescription"], record["fueltypeid"], 
            record["fuelTypeDescription"], record["consumption-for-eg"], record["consumption-for-eg-units"])
        )
        logging.info(f"Insert row for {id}")
        conn.commit()
    
    cursor.close()
    conn.close()
