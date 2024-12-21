#!/bin/bash

# Configuration
SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL:-""}
EMAIL=${ALERT_EMAIL:-""}

check_container() {
    Local container=$1
    if ! docker ps --filter "name=$container" --filter "status-running" --format "{{.Names}}" | grep -q "$container"; then
        return 1
    fi
    return 0
}

check_url() {
    local url=$1
    if ! curl -sf "$url" > /dev/null; then
        return 1
    fi
    return 0
}

send_alert() {
    local message=$1

    # Send to slack if webhook is configured
    if [ ! -z "$SLACK_WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' 
        --data "{\"text\":\"$message\"}" 
        "$SLACK_WEBHOOK_URL"
    fi

    # Send to email if email is configured
    if [ ! -z "$EMAIL" ]; then
        echo "$message" | mail -s "Health Check Alert" "$EMAIL"
    fi
}

# Check core services
services=("mariadb" "postgres" "redis" "traefik")
for service in "${services[@]}"; do
    if ! check_container "$service"; then
        send_alert "🚨 Alert: $service container is not running!"
    fi
done

# Check web services
if ! check_url "http://traefik.localhost"; then
    send_alert "🚨 Alert: Traefik dashboard is not accessible!"
fi

# Check database connections
if ! docker-compose exec -T mariadb mysqladmin ping -h localhost --silent; then
    send_alert "🚨 Alert: MariaDB is not responding!"
fi

if ! docker-compose exec -T postgres pg_isready -q; then
    send_alert "🚨 Alert: PostgreSQL is not responding!"
fi