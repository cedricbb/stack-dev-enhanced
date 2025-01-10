FROM node:20-alpine

WORKDIR /projects

RUN apk add --no-cache git

# Installation des CLI globaux
RUN npm install -g npm@latest
RUN npm install -g @angular/cli@latest

# Configuration pour le hot reload
ENV CHOKIDAR_USEPOLLING=true
ENV WATCHPACK_POLLING=true

CMD ["sh"]