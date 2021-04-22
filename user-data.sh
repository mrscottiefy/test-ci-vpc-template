#!/bin/bash
sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx.service
sudo sed -i 's+ *root */usr/share/nginx/html;+location / { proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme;  proxy_set_header Upgrade $http_upgrade; proxy_pass http://${jenkins_internal_alb}; proxy_max_temp_file_size 0; sendfile off;  client_max_body_size 10m; client_body_buffer_size 128k; }+g' /etc/nginx/nginx.conf
sudo systemctl restart nginx.service
