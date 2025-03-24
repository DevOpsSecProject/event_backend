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