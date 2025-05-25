# docker/connect/Dockerfile
FROM debezium/connect:2.1

# Copy your two JSONs into the image
COPY ../connectors/debezium-connector-postgres.json /kafka/connectors/
COPY ../connectors/mongo-sink-connector.json            /kafka/connectors/

# Default entrypoint
ENTRYPOINT ["/docker-entrypoint.sh", "connect"]
