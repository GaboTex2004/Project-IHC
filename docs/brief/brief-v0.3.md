# Brief v0.3 — Contacto mediante mensajería

## Descripción

Pet Track es una aplicación móvil orientada a facilitar la búsqueda y recuperación de mascotas perdidas, así como el reporte de mascotas encontradas o sin hogar.

En esta versión se incorpora un sistema de mensajería que permite que los usuarios interesados en un reporte puedan comunicarse directamente con la persona que lo publicó.

Esta funcionalidad busca evitar que el usuario tenga que abandonar la aplicación para establecer contacto y permite mantener la conversación relacionada con una mascota específica dentro de Pet Track.

## Problema

Cuando una persona encuentra una mascota que podría corresponder con un reporte publicado, necesita una forma rápida de comunicarse con el responsable del reporte.

Depender únicamente de información de contacto externa puede dificultar la comunicación, generar confusión o hacer que el usuario tenga que utilizar otras aplicaciones.

Además, es importante que la conversación pueda relacionarse directamente con el reporte de la mascota correspondiente.

## Objetivo

Permitir que un usuario pueda contactar desde Pet Track al responsable de un reporte mediante un sistema de mensajería interno.

La conversación debe estar asociada al reporte seleccionado y únicamente debe ser accesible para los dos usuarios involucrados.

## Usuarios involucrados

### Usuario interesado

Persona que visualiza un reporte publicado y desea comunicarse con su responsable porque tiene información sobre la mascota o está interesada en ayudar.

### Responsable del reporte

Usuario que creó el reporte de una mascota perdida, encontrada o sin hogar y puede recibir mensajes relacionados con dicho reporte.

## Necesidades del usuario

El usuario necesita:

- Visualizar la información de una mascota reportada.
- Identificar si puede contactar al responsable.
- Iniciar una conversación desde el detalle del reporte.
- Enviar mensajes al responsable.
- Recibir respuestas dentro de la aplicación.
- Consultar posteriormente sus conversaciones.
- Identificar a qué reporte pertenece cada conversación.

## Funcionalidad propuesta

Desde el detalle de un reporte activo perteneciente a otro usuario se mostrará la opción **Contactar**.

Al seleccionar esta opción:

1. La aplicación comprobará si ya existe una conversación entre el usuario interesado y el responsable para ese reporte.
2. Si no existe, se creará una nueva conversación.
3. Si ya existe, se reutilizará la conversación existente.
4. El usuario será dirigido al chat.
5. Ambos participantes podrán enviar y consultar mensajes.
6. La conversación permanecerá disponible desde la sección de mensajes.

Cada conversación estará asociada a un reporte específico.

## Reglas principales

- Un usuario no puede iniciar una conversación consigo mismo.
- Solo los participantes de una conversación pueden visualizar sus mensajes.
- Solo los participantes pueden enviar mensajes.
- No deben crearse conversaciones duplicadas entre el mismo usuario y el mismo reporte.
- La opción **Contactar** solo debe mostrarse cuando el reporte pertenece a otro usuario.
- No se pueden iniciar nuevas conversaciones desde reportes resueltos.
- Las conversaciones existentes pueden seguir siendo consultadas aunque el reporte haya sido resuelto.

## Beneficios

La mensajería permite:

- Centralizar la comunicación dentro de Pet Track.
- Relacionar cada conversación con una mascota específica.
- Facilitar el intercambio de información entre usuarios.
- Reducir pasos adicionales para contactar al responsable.
- Mejorar la colaboración entre personas que buscan, encuentran o ayudan a una mascota.

## Alcance de esta versión

Esta versión contempla:

- Inicio de conversaciones desde un reporte.
- Listado de conversaciones del usuario.
- Chat entre dos participantes.
- Envío de mensajes.
- Consulta del historial de mensajes.
- Asociación de la conversación con el reporte.
- Control de acceso a conversaciones y mensajes.

Por el momento no se contemplan funciones como llamadas, videollamadas, envío de archivos, mensajes de voz o conversaciones grupales.