#!/bin/bash

echo "🛑 Stopping FlowTrace Docker Services"
echo "====================================="

# Stop all services
docker-compose -f docker-compose.dev.yml down

# Optional: Remove volumes (uncomment if you want to reset data)
# docker-compose -f docker-compose.dev.yml down -v

echo "✅ All services stopped!"
echo ""
echo "To remove all data (database, cache, etc.):"
echo "docker-compose -f docker-compose.dev.yml down -v"
