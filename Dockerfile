# Author. Hwanseok Kang, tttkhs96@gmail.com
FROM node:14.15.1-alpine3.12 AS build

RUN apk update && apk add curl bash
RUN curl -sfL https://gobinaries.com/tj/node-prune | bash -s -- -b /usr/local/bin

COPY package*.json /build/

WORKDIR /build

RUN npm ci

ARG NODE_ENV
ENV NODE_ENV ${NODE_ENV}

COPY . /build
RUN npm run build

RUN npm prune --production && \
 rm -rf node_modules/rxjs/src/ \
 node_modules/rxjs/bundles/ \
 node_modules/rxjs/_esm5/ \
 node_modules/rxjs/_esm2015/ \
 node_modules/swagger-ui-dist/*.map
 
RUN /usr/local/bin/node-prune

FROM gcr.io/distroless/nodejs:14

WORKDIR /app

ARG NODE_ENV
ENV NODE_ENV ${NODE_ENV}

COPY --from=build /build/node_modules /app/node_modules
COPY --from=build /build/dist /app/dist

EXPOSE 4000

CMD [ "./dist/main.js" ] 
