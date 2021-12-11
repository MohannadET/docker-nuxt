# FROM node:16-alpine as builder
# WORKDIR '/app'
# COPY package.json .
# RUN npm install 
# COPY . . 
# RUN  npm run build

# FROM nginx
# COPY --from=builder /app/ 


### STAGE 1: Build ###
FROM node:16-alpine as build

# update and install dependency
RUN apk update && apk upgrade
RUN apk add git

# create destination directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV PATH /usr/src/app/node_modules/.bin:$PATH


COPY package.json /usr/src/app/package.json

RUN npm install

COPY . /usr/src/app/

# build necessary, even if no static files are needed,
# since it builds the server as well
RUN npm run generate

### STAGE 2: NGINX ###
FROM nginx:stable-alpine
COPY --from=build /usr/src/app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
