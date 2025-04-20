#!/bin/bash

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails/tmp/pids/server.pid

# Wait for PostgreSQL to be ready
until pg_isready -h db -p 5432 -q -U postgres; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

# Setup the database if it doesn't exist
bundle exec rails db:prepare

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@" 