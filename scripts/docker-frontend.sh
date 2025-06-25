#!/bin/bash

echo "🐳 FlowTrace Frontend (Docker)"
echo "=============================="

# Start frontend
echo "🎨 Starting frontend on port 5601..."
echo "API calls will be proxied to http://localhost:5609"
docker-compose -f docker-compose.dev.yml up frontend
