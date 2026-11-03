#!/bin/sh
set -e

echo "🚀 Starting GEMA Application..."

# 1. Environment file check
if [ ! -f /var/www/html/.env ]; then
    echo "📄 .env file not found. Creating from .env.example..."
    cp /var/www/html/.env.example /var/www/html/.env
fi

# 2. Application Key check
if ! grep -q "^APP_KEY=base64:" /var/www/html/.env; then
    echo "🔑 Generating Laravel application key..."
    php artisan key:generate --force
fi

# Run package discover to ensure all service providers are registered
php artisan package:discover --ansi > /dev/null 2>&1 || true

# 3. Wait for Database
echo "⏳ Waiting for database connection ($DB_HOST:$DB_PORT)..."
MAX_TRIES=30
TRIES=0
until php -r "
  try {
    \$host = getenv('DB_HOST') ?: 'db';
    \$port = getenv('DB_PORT') ?: '3306';
    \$db   = getenv('DB_DATABASE') ?: 'gema';
    \$user = getenv('DB_USERNAME') ?: 'gema_user';
    \$pass = getenv('DB_PASSWORD') ?: 'gema_secret';
    \$pdo = new PDO(\"mysql:host=\$host;port=\$port;dbname=\$db\", \$user, \$pass, [PDO::ATTR_TIMEOUT => 2]);
    exit(0);
  } catch (\Throwable \$e) {
    exit(1);
  }
"; do
    TRIES=$((TRIES + 1))
    if [ $TRIES -ge $MAX_TRIES ]; then
        echo "❌ Timed out waiting for database."
        break
    fi
    echo "   Database not ready yet ($TRIES/$MAX_TRIES), waiting 2s..."
    sleep 2
done

echo "✅ Database is ready!"

# 4. Run Migrations
echo "📦 Running database migrations..."
php artisan migrate --force

# 5. Run Seeders if database has no users
USER_EXISTS=$(php -r "
  require 'vendor/autoload.php';
  \$app = require_once 'bootstrap/app.php';
  \$kernel = \$app->make(Illuminate\Contracts\Console\Kernel::class);
  \$kernel->bootstrap();
  echo \App\Models\User::count();
" 2>/dev/null || echo "0")

if [ "$USER_EXISTS" = "0" ] || [ -z "$USER_EXISTS" ]; then
    echo "🌱 Seeding initial database (guide user: guide@gema.test / password)..."
    php artisan db:seed --force
else
    echo "ℹ️  Database already seeded ($USER_EXISTS users present)."
fi

# 6. Ensure Storage & Cache Directories and Permissions
mkdir -p /var/www/html/storage/framework/cache/data \
         /var/www/html/storage/framework/sessions \
         /var/www/html/storage/framework/views \
         /var/www/html/storage/logs \
         /var/www/html/bootstrap/cache

chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

echo "✨ GEMA App is ready to serve requests!"

exec "$@"
