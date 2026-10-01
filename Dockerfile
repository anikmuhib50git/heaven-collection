FROM nginx:alpine

COPY website/heaven-collection.html /usr/share/nginx/html/index.html

EXPOSE 80
