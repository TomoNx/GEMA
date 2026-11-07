#!/bin/sh
set -e

echo "🚀 Starting GEMA Application..."

# 1. Environment file check
if [ ! -f /var/www/html/.env ]; then
    echo "📄 .env file not found. Creating from .env.example..."
    cp /var/www/html/.env.example /var/www/html/.env
fi

# 2. Application Key check
if [ -z "$APP_KEY" ] && ! grep -q "^APP_KEY=base64:" /var/www/html/.env; then
    echo "🔑 Generating Laravel application key..."
    php artisan key:generate --force
fi

# Run package discover to ensure all service providers are registered
php artisan package:discover --ansi > /dev/null 2>&1 || true

# 3. Wait for Database
MAX_TRIES=15
TRIES=0
until php -r "
  try {
    \$socket = getenv('DB_SOCKET');
    \$db     = getenv('DB_DATABASE') ?: 'gema';
    \$user   = getenv('DB_USERNAME') ?: 'root';
    \$pass   = getenv('DB_PASSWORD') ?: '';
    if (\$socket) {
        \$dsn = \"mysql:unix_socket=\$socket;dbname=\$db\";
    } else {
        \$host = getenv('DB_HOST') ?: '127.0.0.1';
        \$port = getenv('DB_PORT') ?: '3306';
        \$dsn  = \"mysql:host=\$host;port=\$port;dbname=\$db\";
    }
    \$pdo = new PDO(\$dsn, \$user, \$pass, [PDO::ATTR_TIMEOUT => 2]);
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
    echo "   Database not ready yet ($TRIES/$MAX_TRIES), waiting 1s..."
    sleep 1
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
