FROM node:12.6.0-alpine
COPY . /app
WORKDIR /app
RUN npm install
EXPOSE 8080
ENTRYPOINT [ "node", "app.js" ]