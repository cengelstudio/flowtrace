#!/bin/bash

echo "🐳 FlowTrace Docker Development Environment"
echo "=========================================="
echo ""

# Clean up any existing containers
echo "🧹 Cleaning up existing containers..."
docker-compose -f docker-compose.dev.yml down

# Build and start services
echo "🔨 Building Docker images..."
docker-compose -f docker-compose.dev.yml build

echo ""
echo "🚀 Starting services..."
echo "Backend: http://localhost:5609"
echo "Frontend: http://localhost:5601"
echo "Database: localhost:5432"
echo "Redis: localhost:6379"
echo ""
echo "Press Ctrl+C to stop all services"
echo "=================================="

# Start all services
docker-compose -f docker-compose.dev.yml up
