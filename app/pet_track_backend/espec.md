## 📖 CONTEXTO Y REFERENCIA

Sigue la arquitectura para este proyecto de django de:
**"Clean Architecture in Django: A Practical, Real-World Project Structure"**

La filosofía central es: **"El backend define la lógica de negocio. 
El frontend solo la representa."**

---

## 🎯 INSTRUCCIONES INICIALES

1. **LEE COMPLETAMENTE LA ESPECIFICACIÓN DE LA APLICACIÓN** que se encuentra en 
   la carpeta `@docs` de este proyecto. Analiza en profundidad los requisitos 
   funcionales, no funcionales, los modelos de datos propuestos, los flujos 
   de negocio y las integraciones externas mencionadas.

2. **BASÁNDOTE EN ESA ESPECIFICACIÓN**, diseña un sistema backend completo usando 
   Django REST Framework que implemente **ESTRICTAMENTE** la siguiente arquitectura:

### 🏛️ CLEAN ARCHITECTURE (ARQUITECTURA LIMPIA) con enfoque DDD táctico

Basada en el principio de **independencia del framework**: la lógica de negocio 
NO debe depender de Django, el ORM, ni de detalles de infraestructura.

---

## 📂 ESTRUCTURA DE CARPETAS (Basada en el Blog)

```
project/
├── config/                     # Configuración Django (settings, urls, wsgi/asgi)
│   ├── settings/
│   │   ├── base.py
│   │   ├── local.py
│   │   └── production.py
│   ├── urls.py
│   └── wsgi.py
│
├── domain/                     # 🧠 CAPA DE DOMINIO (Reglas de negocio puras)
│   └── orders/
│       ├── entities.py         # Entidades como clases Python puras
│       ├── exceptions.py       # Excepciones de negocio
│       └── value_objects.py    # Value Objects
│
├── application/                # ⚙️ CAPA DE APLICACIÓN (Casos de Uso)
│   └── orders/
│       ├── services.py         # Servicios de aplicación (Use Cases)
│       ├── interfaces.py       # Puertos (ABC: Repositories, Gateways)
│       ├── dtos.py             # Data Transfer Objects
│       └── exceptions.py       # Excepciones de aplicación
│
├── infrastructure/             # 🔌 CAPA DE INFRAESTRUCTURA (Adaptadores)
│   ├── db/
│   │   ├── models.py           # Modelos Django ORM (SOLO mapeo)
│   │   └── order_repository.py # Implementación concreta de repositorio
│   ├── external/
│   │   ├── payment_gateway.py  # Adaptador para Stripe/PayPal
│   │   └── email_sender.py     # Adaptador para SendGrid/Mailgun
│   └── migrations/             # Migraciones de Django
│
├── interface/                  # 📡 CAPA DE PRESENTACIÓN (DRF)
│   └── api/
│       └── orders/
│           ├── serializers.py  # Serializadores de DRF (Input/Output)
│           ├── views.py        # ViewSets/APIViews (DELGADOS)
│           ├── urls.py         # URLs
│           └── schemas.py      # OpenAPI schemas
│
├── tests/                      # Pruebas
│   ├── unit/                   # Pruebas de dominio y aplicación (sin Django)
│   │   ├── domain/
│   │   └── application/
│   ├── integration/            # Pruebas con DB y APIs reales
│   └── e2e/                    # Pruebas end-to-end
│
└── manage.py
```

---

## 🧩 CAPAS Y RESPONSABILIDADES (Basado en el Blog)

### 1. CAPA DE DOMINIO (`domain/`)
- **Propósito**: Reglas de negocio puras, independientes de Django
- **Características**:
  - Código Python puro (sin imports de Django)
  - Entidades con lógica de negocio
  - Value Objects
  - Excepciones de negocio
- **Ejemplo**:
  ```python
  # domain/orders/entities.py
  class Order:
      def __init__(self, items):
          self.items = items
      
      def total(self):
          return sum(item.price for item in self.items)
  ```

### 2. CAPA DE APLICACIÓN (`application/`)
- **Propósito**: Orquestar casos de uso, coordinar flujos de trabajo
- **Características**:
  - Servicios que ejecutan casos de uso
  - Interfaces (puertos) para repositorios y gateways
  - DTOs para entrada/salida
  - Depende SOLO de la capa de Dominio
- **Ejemplo**:
  ```python
  # application/orders/services.py
  class CreateOrderService:
      def __init__(self, order_repo, payment_gateway):
          self.order_repo = order_repo
          self.payment_gateway = payment_gateway
      
      def execute(self, order_dto):
          order = Order(order_dto.items)
          payment_status = self.payment_gateway.charge(order.total())
          self.order_repo.save(order, payment_status)
          return payment_status
  ```

### 3. CAPA DE INFRAESTRUCTURA (`infrastructure/`)
- **Propósito**: Implementar adaptadores concretos para puertos
- **Características**:
  - Modelos Django ORM (SOLO mapeo, SIN lógica)
  - Repositorios concretos (ej: `DjangoOrderRepository`)
  - Adaptadores para servicios externos
  - Depende de Aplicación y Dominio
- **Ejemplo**:
  ```python
  # infrastructure/db/order_repository.py
  class DjangoOrderRepository(OrderRepository):
      def save(self, order, payment_status):
          OrderModel.objects.create(
              total=order.total(), 
              status=payment_status
          )
  ```

### 4. CAPA DE INTERFAZ / PRESENTACIÓN (`interface/`)
- **Propósito**: Adaptadores DRF, manejo de HTTP
- **Características**:
  - Views delgadas (sin lógica de negocio)
  - Serializadores Input/Output
  - Orquestan servicios de aplicación
- **Ejemplo**:
  ```python
  # interface/api/orders/views.py
  class OrderView(APIView):
      def post(self, request):
          serializer = OrderInputSerializer(data=request.data)
          serializer.is_valid(raise_exception=True)
          
          service = CreateOrderService(
              order_repo=DjangoOrderRepository(),
              payment_gateway=StripeGateway()
          )
          result = service.execute(serializer.validated_data)
          return Response({"payment_status": result})
  ```

---

## ⚠️ REGLA DE ORO: DIRECCIÓN DE DEPENDENCIAS

Las dependencias SIEMPRE deben apuntar hacia adentro:

```
Frontend (React/Vue/Angular)
           ↓
Interface Layer (DRF Views)
           ↓
Application Layer (Use Cases)
           ↓
Domain Layer (Entities & Rules)
           ↓
Infrastructure Layer (DB, APIs externas)
```

**NUNCA** la capa de dominio debe importar desde infraestructura o presentación.

---

## 💻 EJEMPLO DE CÓDIGO OBLIGATORIO (incluir en el documento)

a) Entidad de dominio (clase Python pura)
b) Servicio de aplicación con inyección de dependencias
c) Implementación de repositorio con Django ORM
d) ViewSet de DRF delgado
e) Prueba unitaria del caso de uso

---

## 🚨 RESTRICCIONES Y ADVERTENCIAS

⚠️ Los modelos Django **NO DEBEN** contener lógica de negocio
⚠️ Las vistas **NO DEBEN** tener lógica de negocio (máximo 3-5 líneas)
⚠️ Ninguna capa interna debe importar desde infraestructura o presentación
⚠️ Todas las dependencias deben apuntar hacia el centro (Dominio)
⚠️ Los casos de uso deben ser probables sin base de datos
⚠️ Las entidades de dominio NO deben heredar de `models.Model`
⚠️ La capa de dominio NO debe importar nada de Django

---

## 🔑 PRINCIPIOS CLAVE DEL BLOG A APLICAR

1. **Business Logic First**: La lógica de negocio se define primero, independiente del framework
2. **Framework as Detail**: Django es un detalle de implementación, no el corazón del sistema
3. **API Contract First**: Backend define contratos OpenAPI, frontend consume
4. **Backend-Driven Design**: El backend define flujos de trabajo, no el frontend
5. **Testability**: Pruebas de casos de uso sin HTTP ni base de datos
6. **Reusability**: La misma lógica de negocio sirve para REST, gRPC, WebSockets, CLI
---
