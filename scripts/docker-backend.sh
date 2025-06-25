#!/bin/bash

echo "🐳 FlowTrace Backend (Docker)"
echo "============================="

# Start database and redis first
echo "🗄️ Starting database and Redis..."
docker-compose -f docker-compose.dev.yml up -d db redis

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Start backend
echo "🔧 Starting backend on port 5609..."
docker-compose -f docker-compose.dev.yml up backend
