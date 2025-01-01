FROM python:3.11-alpine

# Installation des dépendances système nécessaires
RUN apk add --no-cache \
    git \
    make

# Installation des dépendances Python
RUN pip install --no-cache-dir \
    mkdocs==1.5.3 \
    mkdocs-material==9.4.6 \
    mkdocs-material-extensions==1.3 \
    pymdown-extensions==10.3 \
    mkdocs-minify-plugin==0.7.1 \
    markdown>=3.2 \
    mkdocs-git-revision-date-localized-plugin==1.2.0

WORKDIR /docs

# Exposition du port
EXPOSE 8000

# Configuration de l'environnement
ENV PYTHONUNBUFFERED=1

# Commande par défaut
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000", "--dev-addr", "0.0.0.0:8000"]