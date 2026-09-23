# 🚀 Guía para construir y subir imágenes Docker (Flutter, Backend)

Esta guía muestra cómo construir y subir imágenes a Docker Hub usando variables genéricas:

* `TU_USUARIO`
* `lastest`

# 1. Build de todas las imágenes
```bash
docker build -t sebastiandevjs/pet_track_backend:latest        ./pet_track_backend    -f ./pet_track_backend/Dockerfile.prod
docker build -t sebastiandevjs/pet_track_mobile:latest        ./pet_track_mobile    -f ./pet_track_mobile/Dockerfile.prod
```

# 2. Login en Docker Hub
```bash
docker login
```

# 3. Push de todas las imágenes
```bash
docker push sebastiandevjs/pet_track_backend:latest
docker push sebastiandevjs/pet_track_mobile:latest
```