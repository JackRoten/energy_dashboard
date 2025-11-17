# api_gateway_lambda
import json
import psycopg2
import os
import logging
import boto3
from decimal import Decimal


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


def decimal_to_str_encoder(obj):
        if isinstance(obj, Decimal):
            return str(obj)
        raise TypeError(f"Object of type {obj.__class__.__name__} is not JSON serializable")

def get_all_state_records(cur):
    """
    Get all records of all states
    """
    logger.info("Querying all states")
    cur.execute("""
        SELECT location, state_description, period, fueltypeid, sectorid, consumption_for_eg
        FROM electric_power_operational;
    """)
    return cur

def get_all_records_by_state(cur, state):
    """
    Get all records by state
    """
    logger.info(f"Querying state {state}")
    cur.execute("""
            SELECT location, state_description, period, fueltypeid, sectorid, consumption_for_eg
            FROM electric_power_operational
            WHERE location = %s;
        """, (state,))
    return cur

def get_groupby_all_records(cur): 
    """
    Get groupby state and amount values of all records of all states
    """
    logger.info(f"Querying all states and grouping")
    cur.execute(f"""
    SELECT 
        state_description,
        SUM(CAST(consumption_for_eg AS DECIMAL)) amount
        FROM electric_power_operational
        WHERE consumption_for_eg IS NOT NULL
        AND CAST(TRIM(consumption_for_eg) AS DECIMAL) <> 0
        GROUP BY state_description
        ORDER BY state_description DESC
        ;
    """)
    return cur

def get_groupby_fule_type_records(cur):
    """
    Get groupby state and amount values of all records of all states
    """
    logger.info(f"Querying all states and grouping")
    cur.execute(f"""
    SELECT 
        state_description,
        fuel_type_description, 
        consumption_for_eg_units,
        SUM(CAST(consumption_for_eg AS DECIMAL)) amount
        FROM electric_power_operational
        WHERE consumption_for_eg IS NOT NULL
        AND CAST(TRIM(consumption_for_eg) AS DECIMAL) <> 0
        GROUP BY state_description, fuel_type_description, consumption_for_eg_units
        ORDER BY state_description DESC
        ;
    """)
    return cur


def lambda_handler(event, context):
    """
    For use with API Gateway
    
    """
    secrets = get_secrets()
    status_code = 200
    rows = []
    columns = []

    conn = psycopg2.connect(
        host=secrets["host"],
        database=secrets["dbname"],
        user=secrets["username"],
        password=secrets["password"],
        port=secrets.get("port", 5432),
    )

    cur = conn.cursor()
    
    if "groupby" in event.get("queryStringParameters"):
        if "all" in event.get("queryStringParameters").get("groupby"):
            endpoint_result = event.get("queryStringParameters", {}).get("groupby")
            cur = get_groupby_all_records(cur)
            columns = ["state_description", "amount"]
        elif "fuel_type" in event.get("queryStringParameters").get("groupby"):
        # Setup to return one path parameter
            endpoint_result = event.get("queryStringParameters", {}).get("groupby")
            cur = get_groupby_fule_type_records(cur)
            columns = ["state_description", "fuel_type_description", "consumption_for_eg_units", "amount"]      
    elif "state" in event.get("queryStringParameters"):
        # TODO: Add additional relavent queries
        # Setup to query by state only
        endpoint_result = event.get("queryStringParameters", {}).get("state")
        cur = get_all_records_by_state(cur, endpoint_result)
        columns = ["location", "state_description", "period", "fueltypeid", "sectorid", "consumption_for_eg"]
    else:
        endpoint_result = None
        status_code = 404
        
    rows = cur.fetchall()
    cur.close()
    conn.close()

    records = [dict(zip(columns, row)) for row in rows]
    
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",          # CORS
            "Access-Control-Allow-Methods": "GET",
            "Access-Control-Allow-Headers": "Content-Type",
        },
        "body": json.dumps(records, default=decimal_to_str_encoder)
    }
