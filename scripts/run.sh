#!/bin/sh

# Build the application
echo "Building Budget App..."
mvn clean package -DskipTests

# Run the application
echo "Starting Budget App..."
java -Duser.timezone=UTC -jar target/budgetapp.jar server config/postgresql.yml
