#!/bin/sh

# Start the PostgreSQL database
echo "Starting Database..."
docker-compose up -d --wait

echo "Database is ready!"
