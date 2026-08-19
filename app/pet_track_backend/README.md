```shell
python manage.py runserver 0.0.0.0:8000 --nostatic # Entrar a localhost:8000 o sino usar el 3000 y compartir los archivos estaticos

python manage.py run # hace todo lo del comando anterior 

python manage.py makemigrations

python manage.py migrate

python manage.py createsuperuser

python manage.py shell < code_python.py # para correr python scripts

python manage.py reset_db # Elimina las tablas de la base de datos

python manage.py flush # Borrar los registros pero no las tablas

# para migrar el esquema compartido (solo crear tablas de public)
python manage.py migrate_schemas --shared

# para crear un tenant (se puede usar la shell)
python manage.py create_tenant --domain-domain=newtenant.net --schema_name=new_tenant --name=new_tenant --description="New tenant"

# para crear un superusuario en un tenant especifico
python manage.py create_tenant_superuser --username=colegio --email=colegio@gmail.com --schema=public

# para eliminar un tenant
python manage.py delete_tenant --schema=simon_pedro_ii

# para clonar un tennant
python manage.py clone_tenant --clone_from=simon_pedro_ii --name=simon_pedro_iii

# para renombrar un tennant
python manage.py rename_schema --rename_from old_name --rename_to new_name


### COMANDOS PERSONALIZADOS
python manage.py seed


### flujo para borrar y reconstruir la base de datos
## !importante¡ antes desconectarse de la base de datos osea desconectar -> (Dbeaver)
python manage.py reset_db

python manage.py migrate_schemas --shared

python manage.py seed

# porque --nostatic para poder servir los archivos estaticos sin usar wsgi o nginx
python manage.py runserver 0.0.0.0:8000 --nostatic

python manage.py run # hace todo lo del comando anterior
```

```bash 
# Para inicializar un tenant y crear un superusuario
# si quisieramos usar script en bash script
echo "Creando el Esquema principal..."
python manage.py create_tenant \
 --domain-domain=$MAIN_SCHEMA_DOMAIN_DOMAIN \
 --schema_name=$MAIN_SCHEMA_DOMAIN \
 --name=$MAIN_SCHEMA_NAME \
 --paid_until=$MAIN_SCHEMA_PAID_UNTIL \
 --on_trial=$MAIN_SCHEMA_ON_TRIAL \
 --domain-is_primary=True

echo "Creando super usuario...$DJANGO_SUPERUSER_USERNAME"
DJANGO_SUPERUSER_USERNAME=$DJANGO_SUPERUSER_USERNAME
DJANGO_SUPERUSER_EMAIL=$DJANGO_SUPERUSER_EMAIL
DJANGO_SUPERUSER_PASSWORD=$DJANGO_SUPERUSER_PASSWORD

echo "Creando super usuario"
export DJANGO_SUPERUSER_USERNAME
export DJANGO_SUPERUSER_EMAIL
export DJANGO_SUPERUSER_PASSWORD
python manage.py createsuperuser --noinput
```