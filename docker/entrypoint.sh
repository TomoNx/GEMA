#!/bin/sh
set -e

echo "🚀 Starting GEMA Application..."

# 1. Environment file check
if [ ! -f /var/www/html/.env ]; then
    echo "📄 .env file not found. Creating from .env.example..."
    cp /var/www/html/.env.example /var/www/html/.env
fi

# Sync environment variables from Cloud Run into .env file
[ -n "$APP_NAME" ]           && sed -i "s|^APP_NAME=.*|APP_NAME=$APP_NAME|" /var/www/html/.env
[ -n "$APP_ENV" ]            && sed -i "s|^APP_ENV=.*|APP_ENV=$APP_ENV|" /var/www/html/.env
[ -n "$APP_DEBUG" ]          && sed -i "s|^APP_DEBUG=.*|APP_DEBUG=$APP_DEBUG|" /var/www/html/.env
[ -n "$DB_CONNECTION" ]      && sed -i "s|^DB_CONNECTION=.*|DB_CONNECTION=$DB_CONNECTION|" /var/www/html/.env
[ -n "$DB_DATABASE" ]        && sed -i "s|^DB_DATABASE=.*|DB_DATABASE=$DB_DATABASE|" /var/www/html/.env
[ -n "$DB_USERNAME" ]        && sed -i "s|^DB_USERNAME=.*|DB_USERNAME=$DB_USERNAME|" /var/www/html/.env
[ -n "$DB_PASSWORD" ]        && sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=$DB_PASSWORD|" /var/www/html/.env

# Handle Database Socket (Cloud SQL) or Host
if [ -n "$DB_SOCKET" ]; then
    echo "🔌 Using Cloud SQL Unix Socket ($DB_SOCKET)..."
    if grep -q "^DB_SOCKET=" /var/www/html/.env; then
        sed -i "s|^DB_SOCKET=.*|DB_SOCKET=$DB_SOCKET|" /var/www/html/.env
    else
        echo "DB_SOCKET=$DB_SOCKET" >> /var/www/html/.env
    fi
    # Clear DB_HOST so Laravel uses DB_SOCKET exclusively
    sed -i "s|^DB_HOST=.*|DB_HOST=|" /var/www/html/.env
elif [ -n "$DB_HOST" ]; then
    sed -i "s|^DB_HOST=.*|DB_HOST=$DB_HOST|" /var/www/html/.env
    sed -i "s|^DB_PORT=.*|DB_PORT=${DB_PORT:-3306}|" /var/www/html/.env
fi

# Sync LiveKit credentials if present
[ -n "$LIVEKIT_API_KEY" ]    && sed -i "s|^LIVEKIT_API_KEY=.*|LIVEKIT_API_KEY=$LIVEKIT_API_KEY|" /var/www/html/.env
[ -n "$LIVEKIT_API_SECRET" ] && sed -i "s|^LIVEKIT_API_SECRET=.*|LIVEKIT_API_SECRET=$LIVEKIT_API_SECRET|" /var/www/html/.env
[ -n "$LIVEKIT_HOST" ]       && sed -i "s|^LIVEKIT_HOST=.*|LIVEKIT_HOST=$LIVEKIT_HOST|" /var/www/html/.env
[ -n "$LIVEKIT_WS_URL" ]     && sed -i "s|^LIVEKIT_WS_URL=.*|LIVEKIT_WS_URL=$LIVEKIT_WS_URL|" /var/www/html/.env

# 2. Application Key check & injection
if [ -n "$APP_KEY" ] && [ "$APP_KEY" != "" ]; then
    echo "🔑 Using APP_KEY from environment..."
    sed -i "s|^APP_KEY=.*|APP_KEY=$APP_KEY|" /var/www/html/.env
else
    if ! grep -q "^APP_KEY=base64:" /var/www/html/.env; then
        echo "🔑 Generating fresh Laravel application key..."
        NEW_KEY=$(php -r 'echo "base64:" . base64_encode(random_bytes(32));')
        sed -i "s|^APP_KEY=.*|APP_KEY=$NEW_KEY|" /var/www/html/.env
        export APP_KEY="$NEW_KEY"
    fi
fi

php artisan config:clear --ansi > /dev/null 2>&1 || true
php artisan cache:clear --ansi > /dev/null 2>&1 || true

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
