import os
import json
import psycopg2
import requests
import boto3

def lambda_handler(event, context):
    secret_name = os.environ["DB_SECRET_NAME"]
    region_name = os.environ["REGION_NAME"]

    # Get DB credentials from Secrets Manager
    session = boto3.session.Session()
    client = session.client("secretsmanager", region_name=region_name)
    secret = json.loads(client.get_secret_value(SecretId=secret_name)["SecretString"])

    conn = psycopg2.connect(
        host=secret["host"],
        database=secret["dbname"],
        user=secret["username"],
        password=secret["password"],
        port=secret.get("port", 5432),
    )

    cursor = conn.cursor()
    response = requests.get("https://api.example.com/data")
    data = response.json()

    for record in data:
        cursor.execute(
            """
            INSERT INTO my_table (id, value, timestamp)
            VALUES (%s, %s, %s)
            ON CONFLICT (id) DO UPDATE SET value = EXCLUDED.value, timestamp = EXCLUDED.timestamp
            """,
            (record["id"], record["value"], record["timestamp"])
        )

    conn.commit()
    cursor.close()
    conn.close()
    return {"status": "success", "records_inserted": len(data)}
