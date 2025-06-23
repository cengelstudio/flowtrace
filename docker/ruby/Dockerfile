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
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy package.json
COPY package.json ./

# Install node modules (this will create package-lock.json)
RUN npm install

# Copy the rest of the application
COPY . .

# Create directory for QR codes
RUN mkdir -p /app/public/qr_codes

# Expose port
EXPOSE 3000

# Default command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
