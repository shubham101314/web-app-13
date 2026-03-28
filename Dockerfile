# Stage 1: Build (optional if no build step)
FROM node:18-alpine AS builder

WORKDIR /app
COPY . .

# If you have package.json (React/Vite/etc)
RUN npm install && npm run build

# Stage 2: Serve using Nginx
FROM nginx:alpine

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built files (or raw files if no build step)
COPY --from=builder /app/dist /usr/share/nginx/html

# If no build step, use:
# COPY . /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g","0.0.0.0:5000" ,"daemon off;"]
