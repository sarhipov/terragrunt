#!/bin/bash
# Update the system packages
dnf update -y

# Install nodejs
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
dnf install -y nodejs

# Initialize a new Node.js application
npm init -y

# Create a Node.js server
cat << 'EOF' > app.js
const http = require('http');

const hostname = '0.0.0.0'; // Listen on all network interfaces
const port = 3000; // Port number

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello, World!\n');
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});
EOF