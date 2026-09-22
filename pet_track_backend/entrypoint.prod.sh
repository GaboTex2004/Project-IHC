#!/bin/bash
set -e

echo "=== MODO PRODUCCION ==="

echo "Esperando a que PostgreSQL este listo..."
while ! python -c "import socket; s = socket.socket(); s.settimeout(1); s.connect(('$DB_HOST', int('$DB_PORT')))" 2>/dev/null; do
  echo "Esperando a la base de datos..."
  sleep 1
done

echo "Ejecutando migraciones..."
python manage.py migrate --noinput

echo "Recolectando archivos estaticos para Nginx..."
python manage.py collectstatic --noinput

echo "Iniciando servidor Gunicorn..."
exec gunicorn config.wsgi:application --bind 0.0.0.0:${SERVER_PORT:-8000} --workers 3