#Image pulling
FROM node:19-alpine3.17 AS builder

#Creating envs
ENV APP_DIR=/app

#Application directory
WORKDIR $APP_DIR

#Copy application requirements
ADD its-testtask-node/package.json $APP_DIR

#Installing application requirements
RUN npm install

#Copy source directory
ADD its-testtask-node $APP_DIR

RUN chmod a+x /app/script.sh

#Open port
EXPOSE 3000

#Run a container
ENTRYPOINT ["/app/script.sh"]

