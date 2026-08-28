# Registro de Prueba - Clase 5 IHC
**Flujo:** Registrar una mascota perdida (App: Pet Track)

## 1. Qué había antes
El diseño inicial (Wireframe v0.1) consistía en un esqueleto básico sin jerarquía clara ni espaciado definido. Faltaban los campos de "Fecha de pérdida" e "Información de contacto" estipulados en el flujo de la tarea. Además, presentaba errores ortográficos ("FFOTO", "ABISTAMIENTO") y todos los inputs eran bloques grises sólidos, lo que dificultaba distinguir entre etiquetas y áreas de escritura.

## 2. Qué cambiamos (HTML/CSS)
Aplicamos los principios de la clase 5 directamente en el código:
* **Jerarquía:** Se reemplazó "AGREGAR MASCOTA" por el título exacto de la tarea "Reportar mascota perdida" para orientar al usuario. El botón de acción pasó a ser el elemento con mayor contraste visual.
* **Layout (Agrupación):** Se dividió el formulario en 3 secciones lógicas para evitar saturación visual: *1. Identidad de la mascota, 2. Cuándo y Dónde, 3. Datos de contacto*.
* **Espaciado (Variables 8px):** Se aplicó la escala en el CSS (`--space-1: 8px` para separar la etiqueta del campo, `--space-2: 16px` entre campos distintos y `--space-4: 32px` para separar las secciones lógicas).
* Se añadieron los campos faltantes (`<input type="date">` y `<input type="tel">`).

## 3. Qué pasó en la prueba
*Nota: Prueba realizada con un usuario simulando reportar a su perro.*
* **Orientación:** El usuario comprendió inmediatamente que estaba en la pantalla correcta gracias al título de la cabecera.
* **Layout:** Al ver la información agrupada numéricamente (1, 2, 3), el usuario escaneó el formulario con facilidad y no se sintió abrumado.
* **Interacción:** El uso del componente nativo de fecha (`input type="date"`) facilitó enormemente la selección sin necesidad de explicar el formato (DD/MM/AAAA). El placeholder del teléfono ("Ej. 70000000") ayudó a entender el formato local esperado.

## 4. Qué mejoraríamos después
* Añadir un paso de "Revisión" en un modal justo al presionar "Revisar y Publicar" para que el usuario confirme los datos antes de que se envíen a la base de datos, tal como lo requiere el paso 6 del flujo principal.
* Implementar validación en tiempo real (por ejemplo, evitar que se puedan seleccionar fechas futuras en el calendario).
