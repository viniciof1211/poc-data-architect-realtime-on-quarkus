from fastapi import FastAPI
import os
import asyncio
from kafka import KafkaConsumer, KafkaProducer
import json
import psycopg2
from pymongo import MongoClient

app = FastAPI(title="OMURA Data Architect POC")

# Configuration from environment
KAFKA_BOOTSTRAP_SERVERS = os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'kafka:9092')
POSTGRES_URL = os.getenv('POSTGRES_URL', 'postgresql://omura_user:omura_pass@postgres:5432/omura')
MONGO_URI = os.getenv('MONGO_URI', 'mongodb://mongodb:27017/omura')

@app.get("/")
async def root():
    return {"message": "OMURA Data Architect POC is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "omura-poc"}

@app.get("/kafka/topics")
async def list_kafka_topics():
    try:
        consumer = KafkaConsumer(
            bootstrap_servers=[KAFKA_BOOTSTRAP_SERVERS],
            auto_offset_reset='earliest',
            value_deserializer=lambda x: json.loads(x.decode('utf-8'))
        )
        topics = consumer.topics()
        consumer.close()
        return {"topics": list(topics)}
    except Exception as e:
        return {"error": str(e)}

@app.get("/postgres/test")
async def test_postgres():
    try:
        conn = psycopg2.connect(
            host="postgres",
            database="omura",
            user="omura_user",
            password="omura_pass"
        )
        cur = conn.cursor()
        cur.execute("SELECT version();")
        version = cur.fetchone()
        cur.close()
        conn.close()
        return {"postgres_version": version[0]}
    except Exception as e:
        return {"error": str(e)}

@app.get("/mongo/test")
async def test_mongo():
    try:
        client = MongoClient(MONGO_URI)
        db = client.omura
        result = db.command("ping")
        client.close()
        return {"mongo_ping": result}
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)