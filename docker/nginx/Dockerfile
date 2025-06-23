FROM nginx:alpine

# Copy nginx configuration
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Create directories
RUN mkdir -p /app/public

# Expose ports
EXPOSE 80 443
