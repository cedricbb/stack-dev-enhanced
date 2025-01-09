FROM node:18-alpine

WORKDIR /projects

RUN apk add --no-cache git

# Installation des CLI globaux
RUN npm install -g @angular/cli npm@latest

# Configuration pour le hot reload
ENV CHOKIDAR_USEPOLLING=true
ENV WATCHPACK_POLLING=true

CMD ["sh"]