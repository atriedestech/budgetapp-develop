#!/bin/sh
set -e

# Log the original URL (masked password if possible, but for now just raw)
echo "Starting Budget App..."
echo "Original DB_URL: $DB_URL"

# Transform postgres:// to jdbc:postgresql://
if echo "$DB_URL" | grep -q "^postgres:"; then
    export DB_URL=$(echo "$DB_URL" | sed 's/^postgres:/jdbc:postgresql:/')
    echo "Transformed DB_URL to JDBC format successfully."
else
    echo "DB_URL does not start with postgres:, using original value."
fi

# Initial check for expected env vars
if [ -z "$DB_URL" ]; then
    echo "WARNING: DB_URL is empty!"
fi

# Start the application
exec java -Xmx384m -Xms192m -XX:+UseSerialGC -Djava.security.egd=file:/dev/./urandom -jar budgetapp.jar server config.yml
