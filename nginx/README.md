# 🚀 Guía para construir y subir imágenes Docker (Flutter, Backend)

Esta guía muestra cómo construir y subir imágenes a Docker Hub usando variables genéricas:

* `TU_USUARIO`
* `1.0.0`

# 1. Build de todas las imágenes
```bash
docker build -t sebastiandevjs/pet_track_backend:1.0.0         ./pet_track_backend    -f ./pet_track_backend/Dockerfile.prod
```

# 2. Login en Docker Hub
```bash
docker login
```

# 3. Push de todas las imágenes
```bash
docker push sebastiandevjs/pet_track_backend:1.0.0
```