FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

# COPY ONLY CONTENT, not wrapper folder
COPY cake-main/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
