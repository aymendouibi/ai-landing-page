#!/bin/sh
set -e

# Run migrations gracefully if database connection is available
php artisan migrate --force || true

# Cache configurations
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Start server on dynamic port provided by host
exec php artisan serve --host=0.0.0.0 --port="${PORT:-8080}"
