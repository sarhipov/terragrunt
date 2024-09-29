#!/bin/bash
# Update the system packages
dnf update -y

# Install Nginx
dnf install -y nginx

# Create a simple HTML page
cat << EOF > /usr/share/nginx/html/index.html
<html>
  <head>
    <title>Welcome to Nginx on Amazon Linux 2023</title>
  </head>
  <body>
    <h1>Success! Nginx is installed and running on Amazon Linux 2023!</h1>
  </body>
</html>
EOF

sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx-selfsigned.key \
  -out /etc/nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Company/OU=Org/CN=nginx.internal.xyz"

# Create the Nginx configuration to handle both HTTP and HTTPS
cat << EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

 Redirect all HTTP requests to HTTPS
server {
    listen 80;
    server_name public-alb.internal.com;  # from public-alb

    location / {
        return 301 https://$host$request_uri;
    }
}

# Handle HTTPS (port 443) and forward traffic to the internal ALB
server {
    listen 443 ssl;
    server_name public-alb.internal.com;  # from public-alb

    # SSL settings
    ssl_certificate /etc/nginx/ssl/wildcard-cert.crt;
    ssl_certificate_key /etc/nginx/ssl/wildcard-cert.key;
    ssl_trusted_certificate /etc/nginx/ssl/wildcard-chain.pem;

    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    location / {
        proxy_pass https://alb.internal.xyz;  # to private ALB
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
}
EOF

# Start Nginx service
systemctl start nginx

# Enable Nginx to start on boot
systemctl enable nginx