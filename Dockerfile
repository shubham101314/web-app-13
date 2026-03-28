# Use the official Nginx image as the base
FROM nginx:alpine

# Set a working directory inside the container
WORKDIR /usr/share/nginx/html

# Remove the default Nginx static files
RUN rm -rf ./*

# Copy your HTML website files from the host to the container
COPY ./cake-main/ .

# Expose port 80 for the web server
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
