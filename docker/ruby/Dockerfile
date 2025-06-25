FROM ruby:3.2.0

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    npm \
    postgresql-client \
    build-essential \
    libpq-dev \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Set working directory
WORKDIR /app

# Copy Gemfile first for better caching
COPY Gemfile ./

# Install gems
RUN bundle install

# Copy package.json and package-lock.json first for better caching
COPY package.json package-lock.json* ./

# Install node modules
RUN npm install

# Copy the rest of the application
COPY . .

# Build frontend assets with Vite
RUN npm run build

# Precompile Rails assets
RUN bundle exec rails assets:precompile RAILS_ENV=production || true

# Create directory for QR codes
RUN mkdir -p /app/public/qr_codes

# Expose port
EXPOSE 3000

# Default command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
