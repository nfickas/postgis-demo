# pull official base image
FROM node:13.12.0-alpine

# set working directory
RUN adduser node root
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# install app dependencies
COPY package.json ./
COPY package-lock.json ./
RUN mkdir -p /app/node_modules/.cache
RUN npm install --silent
RUN npm install react-scripts@3.4.1 -g --silent

RUN chmod -R 775 /app
RUN chown -R node:root /app

# add app
COPY . ./

EXPOSE 3000
USER 1000

# start app
CMD ["npm", "start"]