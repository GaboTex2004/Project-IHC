# Flujo v3.0 — Contactar al responsable de un reporte

## Tarea

Contactar mediante mensajería al responsable de un reporte para intercambiar información relacionada con una mascota.

## Objetivo del usuario

Poder comunicarse rápidamente con la persona que publicó un reporte sin salir de Pet Track.

## Actor principal

Usuario interesado en contactar al responsable de un reporte.

## Precondiciones

- El usuario debe haber iniciado sesión.
- Debe existir un reporte publicado por otro usuario.
- El reporte debe estar activo para poder iniciar una nueva conversación.

## Flujo principal

Inicio  
↓  
Visualizar listado de reportes  
↓  
Seleccionar un reporte  
↓  
Visualizar detalle del reporte  
↓  
Seleccionar **"Contactar"**  
↓  
Verificar si existe una conversación previa  
↓  
Crear o recuperar la conversación  
↓  
Abrir el chat  
↓  
Escribir mensaje  
↓  
Seleccionar **"Enviar"**  
↓  
Guardar mensaje  
↓  
Mostrar mensaje en la conversación  
↓  
Esperar o recibir respuesta del responsable  
↓  
Continuar conversación

## Flujo alternativo 1 — La conversación ya existe

Inicio  
↓  
Visualizar reporte  
↓  
Seleccionar **"Contactar"**  
↓  
El sistema detecta una conversación existente  
↓  
Abrir conversación existente  
↓  
Mostrar historial de mensajes  
↓  
Continuar conversación

## Flujo alternativo 2 — Consultar conversaciones desde Mensajes

Inicio  
↓  
Seleccionar **"Mensajes"** en la navegación inferior  
↓  
Visualizar lista de conversaciones  
↓  
Seleccionar una conversación  
↓  
Abrir chat  
↓  
Visualizar historial de mensajes  
↓  
Enviar o leer mensajes

## Flujo alternativo 3 — El usuario intenta contactar su propio reporte

Inicio  
↓  
Visualizar uno de sus propios reportes  
↓  
Abrir detalle  
↓  
La opción **"Contactar"** no se muestra  
↓  
Fin

## Flujo alternativo 4 — Reporte resuelto

Inicio  
↓  
Visualizar un reporte resuelto  
↓  
No permitir iniciar una nueva conversación  
↓  
Fin

Si ya existía una conversación antes de que el reporte fuera resuelto:

Mensajes  
↓  
Seleccionar conversación existente  
↓  
Visualizar historial  
↓  
Continuar consultando la conversación

## Flujo alternativo 5 — Error al enviar mensaje

Chat abierto  
↓  
Escribir mensaje  
↓  
Seleccionar **"Enviar"**  
↓  
Ocurre un error de comunicación  
↓  
Mostrar mensaje de error  
↓  
Mantener al usuario en el chat  
↓  
Permitir volver a intentar

## Resultado esperado

El usuario logra establecer comunicación con el responsable del reporte y la conversación queda asociada al reporte correspondiente para poder consultarla posteriormente.