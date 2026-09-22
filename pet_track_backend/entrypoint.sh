#!/bin/bash
set -e

echo "Esperando a que PostgreSQL este listo..."
while ! python -c "import socket; s = socket.socket(); s.settimeout(1); s.connect(('$DB_HOST', int('$DB_PORT')))" 2>/dev/null; do
  echo "Esperando..."
  sleep 1
done

echo "Ejecutando migraciones..."
python manage.py migrate --noinput

echo "Recolectando archivos estaticos..."
python manage.py collectstatic --noinput

echo "Iniciando servidor..."
exec gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 3
