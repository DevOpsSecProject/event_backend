#!/bin/bash
set -e
# Reference for nginx configuration: https://medium.com/@muaad/how-to-setup-a-letsencrypt-ssl-certificate-for-your-rails-app-on-nginx-fb2164b501a0
# Reference for script inspiration: https://natemacinnes.github.io/rails-rubber-letsencrypt-configuration.html
SECRET_KEY_BASE="$1"
SSL_DOMAIN="${2:-localhost}"
SSL_EMAIL="$3"
RAILS_ENV="${4:-production}"

echo "Starting deployment for domain: $SSL_DOMAIN in $RAILS_ENV environment"

# Setup SSL directory
SSL_DIR="/var/www/ssl"
if [ ! -d "$SSL_DIR" ]; then
  sudo mkdir -p "$SSL_DIR"
  sudo chown $USER:$USER "$SSL_DIR"
fi

setup_lets_encrypt(){
  local domain="$1"
  local email="$2"

  echo "Setting up Lets Encrypt certificates for $domain"

  # Install certbot if not already installed
  if ! command -v certbot &> /dev/null; then
    echo "Install Certbot..."
    sudo apt-get update
    sudo apt-get install -y certbot
  fi

  # Temporarily stop any web server to free port 80
  sudo systemctl stop nginx 2>/dev/null || true
  sudo pkill -f puma || true

  # Request certificate
  if [ -z "$email" ]; then
    sudo certbot certonly --standalone --non-interactive --agree-tos \
      -d "$domain" --register-unsafely-without-email
  else
    sudo certbot certonly --standalone --non-interactive --agree-tos \
      -d "$domain" --email "$email"
  fi
  # Reference to implementation inspirations: https://gorails.com/guides/free-ssl-with-rails-and-nginx-using-let-s-encrypt
  # Check if certificate was obtained successfully
  if sudo find /etc/letsencrypt/live/ -name "$domain*" -type d | grep -q .; then
    echo "Certificate obtained successfully"

    CERT_DIR=$(sudo find /etc/letsencrypt/live/ -name "$domain*" -type d | head -n 1)

    echo "Using certificate directory: $CERT_DIR"
    # Copy the certificates to application SSL directory
    sudo cp "$CERT_DIR/fullchain.pem" "$SSL_DIR/certificate.crt"
    sudo cp "$CERT_DIR/privkey.pem" "$SSL_DIR/private.key"
    sudo chown $USER:$USER "$SSL_DIR/certificate.crt" "$SSL_DIR/private.key"
    sudo chmod 644 "$SSL_DIR/certificate.crt"
    sudo chmod 600 "$SSL_DIR/private.key"

    # Set up auto renewal cron job
    echo "Setting up certificate auto renewal.."
    (crontab -l 2>/dev/null || echo "") | grep -v "certbot renew" | \
    { cat; echo "0 3 * * * sudo certbot renew --quiet --post-hook 'sudo cp $CERT_DIR/fullchain.pem $SSL_DIR/certificate.crt && sudo cp $CERT_DIR/privkey.pem $SSL_DIR/private.key && sudo systemctl restart rails-app.service'"; } | \
    crontab -

    return 0

  else
    echo "Failed to obtain Let's Encrypt certificate"
    return 1
  fi
}

# Handle SSL certs base on environment
if [ "$RAILS_ENV" = "production" ] && [ "$SSL_DOMAIN" != "localhost" ]; then
  # For production with a real domain by using Let's Encryp
  setup_lets_encrypt "$SSL_DOMAIN" "$SSL_EMAIL"
else

  # for testing purposes, create a self signed certificate
  echo "Generating self-signed SSL certificate for development/testing"
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/private.key" \
    -out "$SSL_DIR/certificate.crt" \
    -subj "/CN=$SSL_DOMAIN" \
    -addext "subjectAltName=DNS:$SSL_DOMAIN"

  sudo chmod 600 "$SSL_DIR/private.key"
  echo "Self signed SSL certificate generated"
fi

# Clone repo if it doesn't exist otherwise pull latest changes
if [ ! -d '/var/www/event_backend' ]; then
  sudo mkdir -p /var/www/event_backend
  sudo chown $USER:$USER /var/www/event_backend
  git clone https://github.com/DevOpsSecProject/event_backend.git /var/www/event_backend
else
  cd /var/www/event_backend
  git pull origin main
fi

# Install Dependencies
cd /var/www/event_backend
bundle config set --local path 'vendor/bundle'
bundle install

# Create SSL configuration for Puma
mkdir -p config
cat > config/puma.rb << EOF
# Puma configuration file with SSL support

# Specify environment
environment ENV.fetch("RAILS_ENV") {"development"}

# Set application directory
directory "/var/www/event_backend"

# Set port for HTTP
port ENV.fetch("PORT") { 3000 }

# Bind to SSL
ssl_bind '0.0.0.0', '3443', {
  key: "$SSL_DIR/private.key",
  cert: "$SSL_DIR/certificate.crt",
  verify_mode: 'none'
}

# Set number of workers
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Set the number of threads
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Preload the application
preload_app!

# Allow puma to be restarted by systemd
plugin :tmp_restart
EOF

echo "Puma SSL configuration created"

# Configure Rails to force SSL into production
if [ "$RAILS_ENV" = "production" ]; then
  if grep  -q "config.force_ssl = true" config/environments/production.rb; then
    echo "SSL already configured in RAILS"
  else
    sed -i '/do$/a\ config.force_ssl = true' config/environments/production.rb
    echo "Rails configured to force SSL into the production environment"
  fi
fi

# Run migrations
export SECRET_KEY_BASE="$SECRET_KEY_BASE"
RAILS_ENV=production bundle exec rails db:migrate

# Setup systemd service file for Puma
sudo bash -c "cat > /etc/systemd/system/rails-app.service" <<EOF
[Unit]
Description=Rails Event Backend Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/var/www/event_backend
Environment=RAILS_ENV=$RAILS_ENV
Environment=SECRET_KEY_BASE=$SECRET_KEY_BASE
ExecStart=$(which bundle) exec puma -C /var/www/event_backend/config/puma.rb
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Systemd service created for Event Management Application"

# Reload systemd, enable and restart service
sudo systemctl daemon-reload
sudo systemctl enable rails-app.service

# Restart Rails server (kill the current process running)
pkill -f puma || true

# Start service
sudo systemctl restart rails-app.service
sleep 3
sudo systemctl status rails-app.service --no-pager

# Start server as background proccess
if sudo systemctl is-active --quiet rails-app.service; then
  echo "Rails application has started successfully with HTTPS"
  echo "You can access the application at:"
  echo "- HTTPS: https://$SSL_DOMAIN:3443"
  if [ "$RAILS_ENV" != "production" ]; then
    echo "- HTTP: http://$SSL_DOMAIN:3000 for non production environments"
  fi

  echo " In production HTTP traffic is redirected to HTTPS"
  echo "For standard HTTPS port (443) a Nginx revers proxy is configured"
else
  echo "ERROR: Rails application failed to start"
  echo "sudo journalctl -u rails-app.service -n 50 --no-pager"
fi
echo "Deployment completed successfully"