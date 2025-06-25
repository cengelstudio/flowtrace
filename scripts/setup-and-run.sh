#!/bin/bash

echo "🚀 FlowTrace Setup ve Backend Başlatma"
echo "======================================"

# rbenv setup
eval "$(rbenv init -)"

echo "✅ Ruby version: $(ruby --version)"
echo "✅ rbenv version: $(rbenv version)"

# Bundler install
echo "📦 Installing bundler..."
gem install bundler

# Bundle install
echo "📦 Installing gems..."
bundle install

# Check Rails
echo "✅ Rails version: $(bundle exec rails --version)"

# Database setup
echo "🗄️ Setting up database..."
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed

echo ""
echo "✅ Setup complete!"
echo "🚀 Starting Rails server on port 5609..."
echo ""

# Start server
export PORT=5609
bundle exec rails server -p 5609 -b 0.0.0.0
