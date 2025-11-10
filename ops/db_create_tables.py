import logging
import psycopg2
import boto3, json #, os

logging.basicConfig(
    level=logging.INFO,
    style='{',
    format='{asctime} | {levelname:<8s} | {name}:{lineno:5} | {message}'
)

secret_name = "api_postgres_secret"
region_name = "us-west-2"

session = boto3.session.Session()
client = session.client("secretsmanager", region_name=region_name)
secret = json.loads(client.get_secret_value(SecretId=secret_name)["SecretString"])

logging.info(f"Starting Connection to DB {secret['dbname']}.")

conn = psycopg2.connect(
    host=secret["host"],
    database=secret["dbname"],
    user=secret["username"],
    password=secret["password"],
    port=secret["port"]
)

logging.info("Begining table 'electric_power_operational' creation.")
cursor = conn.cursor()
cursor.execute("""
CREATE TABLE IF NOT EXISTS electric_power_operational (
    id SERIAL PRIMARY KEY,
    period VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    state_description VARCHAR(100) NOT NULL,
    sectorid VARCHAR(100) NOT NULL,
    sector_description VARCHAR(100) NOT NULL, 
    fueltypeid VARCHAR(100) NOT NULL,
    fuel_type_description VARCHAR(100) NOT NULL, 
    consumption_for_eg VARCHAR(100) NOT NULL,
    consumption_for_eg_units VARCHAR(100) NOT NULL
);
""")
conn.commit()
cursor.close()
conn.close()
logging.info("✅ Table created!")
