FROM node:18-alpine

WORKDIR /projects

RUN apk add --no-cache git

# Outils de développement
RUN npm install -g npm@latest

# Configuration pour le hot reload
ENV CHOKIDAR_USEPOLLING=true
ENV WATCHPACK_POLLING=true

CMD ["sh"]