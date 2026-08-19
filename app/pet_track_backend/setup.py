#!/usr/bin/env python
"""
Script de configuración inicial del backend.
Ejecutar después de instalar las dependencias: python setup.py
"""
import os
import sys
import subprocess


def run_command(command, description):
    print(f"\n{'='*60}")
    print(f"  {description}")
    print(f"{'='*60}")
    result = subprocess.run(command, shell=True, cwd=os.path.dirname(os.path.abspath(__file__)))
    if result.returncode != 0:
        print(f"Error al ejecutar: {command}")
        sys.exit(1)
    return result


def main():
    print("\n" + "="*60)
    print("  CONFIGURACIÓN INICIAL - PET TRACK BACKEND")
    print("="*60)

    if not os.path.exists('.env'):
        print("\nError: No se encontró el archivo .env")
        sys.exit(1)

    run_command(
        f"{sys.executable} -m pip install -r requirements.txt",
        "Instalando dependencias..."
    )

    run_command(
        f"{sys.executable} manage.py migrate",
        "Ejecutando migraciones..."
    )

    os.environ['DJANGO_SUPERUSER_USERNAME'] = 'colegio'
    os.environ['DJANGO_SUPERUSER_EMAIL'] = 'colegio@gmail.com'
    os.environ['DJANGO_SUPERUSER_PASSWORD'] = 'password'

    run_command(
        f"{sys.executable} manage.py createsuperuser --noinput",
        "Creando superusuario..."
    )

    print(f"\n{'='*60}")
    print("  ¡CONFIGURACIÓN COMPLETADA!")
    print(f"{'='*60}")
    print("\nPara iniciar el servidor:")
    print("  python manage.py runserver")
    print("\nEndpoints disponibles:")
    print("  - Admin: http://localhost:8000/admin/")
    print("  - Health: http://localhost:8000/api/health/")
    print("  - Swagger: http://localhost:8000/api/docs/")
    print("  - ReDoc: http://localhost:8000/api/redoc/")


if __name__ == '__main__':
    main()
