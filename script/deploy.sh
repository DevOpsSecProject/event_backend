#!/bin/bash
set -e
# Store the secret key passed as the first argument

SECRET_KEY_BASE="$1"

APP_DIR="/var/www/event_backend"
# Clone repo if it doesn't exist otherwise pull latest changes
if [ ! -d  "$APP_DIR" ]; then

  sudo mkdir -p "$APP_DIR"
  sudo chown $USER:$USER "$APP_DIR"
  git clone https://github.com/DevOpsSecProject/event_backend.git "$APP_DIR"
else
  cd "$APP_DIR"
  git pull origin main
fi

# Install Rails Dependencies
cd "$APP_DIR"
bundle config set --local path 'vendor/bundle'
bundle install

# Run migrations
export SECRET_KEY_BASE="$SECRET_KEY_BASE"
RAILS_ENV=production bundle exec rails db:migrate

if ! command -v node &> /dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

if ! command -v npm &> /dev/null; then
  sudo apt-get install -y npm
fi

mkdir -p "$APP_DIR/bin"

# Install npm packages for proxy server
cd "$APP_DIR"
npm init -y || true
npm install express http-proxy-middleware

# Create SSL directory certificate directory
mkdir -p "$APP_DIR"
sudo mkdir -p /etc/ssl/private
sudo mkdir -p /etc/ssl/certs
sudo chown -R $USER:$USER /etc/ssl/private
sudo chown -R $USER:$USER /etc/ssl/certs

# Create or update server.js file in bin directory
cat > "$APP_DIR/bin/server.js" << 'EOL'
const express = require('express');
const { createProxyMiddleware} = require('http-proxy-middleware');
const http = require('http');
const https = require('https');
const fs = require('fs');


// Create Express app
const app = express();

// Configuration
const HTTP_PORT = process.env.HTTP_PORT || 80;
const HTTPS_PORT = process.env.HTTPS_PORT || 443;
const TARGET = 'http://localhost:3000'
const ENV = process.env.NODE_ENV || 'development'

// Set up Rails proxy backend
app.use('/', createProxyMiddleware({
    target: TARGET,
    changeOrigin: true,
    ws: true

}))

// Normalise port function
function normalisePort(val) {
    const port = parseInt(val, 10);
    if (isNaN(port)) return val;
    if (port >= 0) return port;
    return false;
}

// For error handling
function onError(error, port){
    if (error.syscall !== 'listen'){
        throw error;
    }

    const bind = typeof port == 'string'
        ? 'Pipe ' + port
        : 'Port ' + port;

    switch(error.code){
        case 'EACCES':
            console.error(bind + ' requires elevated privileges')
            process.exit(1)
            break;
        case 'EADDRINUSE':
            console.error(bind + ' is already in use')
            process.exit(1)
            break;
        default:
            throw error;

    }
}

// Listening handler function
function onListening(server) {
    const addr = server.address();
    const bind = typeof addr === 'string'
        ? 'pipe ' + addr
        : 'port ' + addr.port
    console.log('Listening on ' + bind)
}

if  (ENV !== 'development'){
    // Production for HTTPS server with HTTP redirection
    try{
        // Read SSL certificate
        if(fs.existsSync('/var/www/event_backend/private.pem') &&
            fs.existsSync('/var/www/event_backend/certificate.pem')){

            // Read SSL certificates
            const privateKey = fs.readFileSync('/var/www/event_backend/private.pem', 'utf-8');
            const certificate = fs.readFileSync('/var/www/event_backend/certificate.pem', 'utf-8')

            const credentials = {
                key: privateKey,
                cert: certificate
            };

            // Create HTTPS server
            const httpsServer = https.createServer(credentials, app);
            httpsServer.listen(HTTPS_PORT);
            httpsServer.on('error', (error) => onError(error, HTTPS_PORT));
            httpsServer.on('listening', () => {
                onListening(httpsServer);
                console.log(`HTTPS Server running on port ${HTTPS_PORT}`)
            });

            // Create HTTP server that redirects to HTTPS
            http.createServer((req, res) => {
                res.writeHead(301, {
                    'Location': `https://${req.headers.host.split(':')[0]}:${HTTPS_PORT}${req.url}`
                })
                res.end()
            }).listen(HTTP_PORT, () => {
                console.log(`HTTP redirect server running on port ${HTTP_PORT}`)
            })
        }else {
            console.log("SSL certificates not found, falling back to HTTP only")
            const httpServer = http.createServer(app)
            httpServer.listen(HTTP_PORT);
            httpServer.on('error', (error) => onError(error, HTTP_PORT));
            httpServer.on('listening', () => {
                onListening(httpServer);
                console.log(`HTTP server running on port ${HTTP_PORT} in production mode`)
            });
        }
    }catch (error){
        console.error('Failed to start HTTPs server:', error)
        const httpServer = http.createServer(app);
        httpServer.listen(HTTP_PORT);
        httpServer.on('error', (error) => onError(error, HTTP_PORT));
        httpServer.on('listening', () => {
            onListening(httpServer)
            console.log(`HTTP server running on port ${HTTP_PORT} in ${ENV}  (fallback)`)
        })
    }
} else{
    const httpServer = http.createServer(app);
    httpServer.listen(HTTP_PORT);
    httpServer.on('error', (error) => onError(error, HTTP_PORT))
    httpServer.on('listening', () => {
        onListening(httpServer);
        console.log(`HTTP server running on port ${HTTP_PORT} in ${ENV} mode`)
    })
}
EOL

sudo tee /etc/systemd/system/rails-app.service > /dev/null << EOL
[Unit]
Description=Rails API backend
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$APP_DIR
Environment=RAILS_ENV=production
Environment=SECRET_KEY_BASE=${SECRET_KEY_BASE}
ExecStart=$(which bundle) exec rails server -b 127.0.0.1 -p 3000
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Creating systemmd service for Node.js proxy
sudo tee /etc/systemd/system/node-proxy.service > /dev/null << EOL
[Unit]
Description=Node.js Proxy Server
After=network.target rails-app.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$APP_DIR
Environment=NODE_ENV=production
ExecStart=$(which node) bin/server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOL
# Making sure port 443 and 80 are available
sudo apt-get update
sudo apt-get install -y authbind
sudo touch /etc/authbind/byport/80
sudo touch /etc/authbind/byport/443
sudo chmod 500 /etc/authbind/byport/80
sudo chmod 500 /etc/authbind/byport/443
sudo chown $USER /etc/authbind/byport/80
sudo chown $USER /etc/authbind/byport/443

# Reload systemd and enable services
sudo systemctl daemon-reload
sudo systemctl enable rails-app.service node-proxy.service
sudo systemctl restart rails-app.service
sudo systemctl restart node-proxy.service

echo "Deployment completed successfully"