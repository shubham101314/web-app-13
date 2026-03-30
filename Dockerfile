# Stage 1: Prepare (optional build stage)
FROM alpine:3.19 AS builder

WORKDIR /app
COPY . .

# You can add optional steps here like:
# - minify files
# - remove unwanted files
# For now, just copying


# Stage 2: Production (Nginx)
FROM nginx:alpine

# Remove default nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy only necessary files from builder
COPY --from=builder /app /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g","0.0.0.0:80","daemon off;"]
