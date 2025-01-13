# docs/Dockerfile
FROM python:3.11-alpine

WORKDIR /docs

# Installation des dépendances
RUN pip install --no-cache-dir \
    mkdocs \
    mkdocs-material \
    pymdown-extensions \
    mkdocs-material-extensions \
    mkdocs-git-revision-date-plugin \
    mkdocs-minify-plugin

EXPOSE 8000
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]