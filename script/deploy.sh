#!/bin/bash
set -e

# Clone repo if it doesn't exist otherwise pull latest changes
if [ ! -d '/var/www/event_backend' ]; then

  sudo mkdir -p /var/www/event_backend
  sudo chown ${EC2_USER}:${EC2_USER} /var/www/event_backend
  git clone https://github.com/DevOpsSecProject/event_backend.git /var/www/event_backend
else
  cd /var/www/event_backend
  git pull origin main
fi

# Install Dependencies
cd /var/www/event_backend
bundle config set --local path 'vendor/bundle'
bundle install

# Run migrations
SECRET_KEY_BASE=${SECRET_KEY_BASE} RAILS_ENV=production bundle exec rails db:migrate
# Restart Rails server (kill the current process running)
pkill -f puma || true

# Start server as background proccess
cd /var/www/event_backend
SECRET_KEY_BASE=${SECRET_KEY_BASE} RAILS_ENV=production bundle exec rails server -b 0.0.0.0 -p 3000 > /var/www/event_backend/server.log 2>&1 &

echo "Deployment completed successfully"