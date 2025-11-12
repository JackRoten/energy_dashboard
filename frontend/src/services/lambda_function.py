import json
import psycopg2
import os

def handler(event, context):
    state = event.get("pathParameters", {}).get("state", None)
    
    conn = psycopg2.connect(
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        host=os.environ["DB_HOST"],
        port="5432"
    )
    
    cur = conn.cursor()
    if state:
        cur.execute("SELECT * FROM electricity_usage WHERE state = %s;", (state,))
    else:
        cur.execute("SELECT * FROM electricity_usage;")
    
    rows = cur.fetchall()
    cur.close()
    conn.close()
    
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(rows, default=str)
    }
