#!/bin/bash
set -e

echo "Esperando a que PostgreSQL este listo..."
while ! pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME; do
  sleep 1
done

echo "Ejecutando migraciones..."
python manage.py migrate --noinput

echo "Recolectando archivos estaticos..."
python manage.py collectstatic --noinput

echo "Iniciando servidor..."
exec gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 3
