FROM node:14.17.5-alpine

WORKDIR /usr/src/app

COPY userapi . 

RUN npm install

EXPOSE 3000

CMD [ "npm", "start" ]