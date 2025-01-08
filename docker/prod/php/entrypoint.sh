#!/bin/sh
set -e

# Attendre la base de données si nécessaire
if [ "$WAIT_FOR_DB" = "true" ]; then
    until nc -z ${DATABASE_HOST:-mariadb} ${DATABASE_PORT:-3306}; do
        echo "Waiting for database..."
        sleep 1
    done
fi

# Warmup du cache
php bin/console cache:warmup --env=prod

# Exécuter les migrations si nécessaire
if [ "$RUN_MIGRATIONS" = "true" ]; then
    php bin/console doctrine:migrations:migrate --no-interaction --env=prod
fi

exec "$@"