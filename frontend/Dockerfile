# Use a lightweight base image with Nginx
FROM nginx:alpine

# Copy Nginx configuration file
COPY frontend/nginx.conf /etc/nginx/nginx.conf

# Copy the pre-built React app into the Nginx directory
COPY frontend/build/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80
EXPOSE 443

# Command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]