# api_gateway_lambda
import json
import psycopg2
import os
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

secrets_client = None

def get_secrets():
    """Cache Secrets Manager client for reuse across Lambda invocations."""
    global secrets_client
    if secrets_client is None:
        secrets_client = boto3.client("secretsmanager", region_name=os.environ["REGION_NAME"])
    secret_string = secrets_client.get_secret_value(SecretId=os.environ["DB_SECRET_NAME"])["SecretString"]
    return json.loads(secret_string)


def parse_api_gateway_event(event):
    """
    Normalize input so Lambda works for both:
    - API Gateway REST API (v1)
    - HTTP API (v2)
    """
    logger.info(f"Incoming event: {json.dumps(event)[:500]}")

    # REST API (v1)
    if "queryStringParameters" in event: 
        state = event.get("queryStringParameters", {}).get("state")
    elif "pathParameters" in event:
        state = event.get("pathParameters", {}).get("state")
    # HTTP API (v2)
    elif "rawPath" in event:
        route_params = event.get("pathParameters", {})
        state = route_params.get("state")
    else:
        state = None
    return state


def lambda_handler(event, context):

    state = parse_api_gateway_event(event)
    secrets = get_secrets()

    conn = psycopg2.connect(
        host=secrets["host"],
        database=secrets["dbname"],
        user=secrets["username"],
        password=secrets["password"],
        port=secrets.get("port", 5432),
    )

    cur = conn.cursor()

    if state:
        logger.info(f"Querying for state: {state}")
        cur.execute("""
            SELECT location, period, state_description, fueltypeid, sectorid, consumption_for_eg
            FROM electric_power_operational
            WHERE location = %s;
        """, (state,))
    else:
        logger.info("Querying all states")
        cur.execute("""
            SELECT location, period, state_description, fueltypeid, sectorid, consumption_for_eg
            FROM electric_power_operational;
        """)

    rows = cur.fetchall()
    cur.close()
    conn.close()

    # Format as list of dicts
    columns = ["location", "period", "state_description", "fueltypeid", "sectorid", "consumption_for_eg"]
    records = [dict(zip(columns, row)) for row in rows]

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",          # CORS
            "Access-Control-Allow-Methods": "GET",
            "Access-Control-Allow-Headers": "Content-Type",
        },
        "body": json.dumps(records)
    }
