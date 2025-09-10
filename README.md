# CRM App - SwiftUI

Una aplicación de gestión de relaciones con clientes (CRM) desarrollada en SwiftUI para iOS.

## Características

### 📊 Dashboard
- Métricas en tiempo real (total clientes, nuevos leads, tareas pendientes, deals cerrados)
- Resumen de ingresos
- Actividades recientes
- Tareas pendientes

### 👥 Gestión de Clientes
- Lista de clientes con búsqueda y filtros
- Estados de cliente (Prospecto, Lead, Calificado, Propuesta, Negociación, Cerrado)
- Información detallada de cada cliente
- Notas y etiquetas personalizables
- Historial de actividades por cliente

### ✅ Gestión de Tareas
- Crear y asignar tareas
- Prioridades (Baja, Media, Alta, Urgente)
- Estados (Pendiente, En Progreso, Completada, Cancelada)
- Asociación con clientes
- Fechas límite

### 📅 Actividades
- Registro de diferentes tipos de actividades (Llamada, Email, Reunión, Nota, Seguimiento)
- Duración de actividades
- Asociación con clientes
- Historial cronológico

## Estructura del Proyecto

```
CRMApp/
├── CRMApp.swift              # Punto de entrada de la aplicación
├── ContentView.swift         # Vista principal con navegación por tabs
├── Models.swift              # Modelos de datos (Client, Task, Activity, etc.)
├── DataManager.swift         # Gestión de datos y persistencia
├── DashboardView.swift       # Vista del dashboard con métricas
├── ClientsView.swift         # Lista y gestión de clientes
├── ClientDetailView.swift    # Vista detallada de cliente
├── AddClientView.swift       # Formularios para agregar/editar clientes
├── TasksView.swift           # Lista y gestión de tareas
├── AddTaskView.swift         # Formularios para agregar/editar tareas
├── ActivitiesView.swift      # Lista y gestión de actividades
└── AddActivityView.swift     # Formularios para agregar/editar actividades
```

## Modelos de Datos

### Client
- Información personal (nombre, email, teléfono)
- Información empresarial (empresa, estado)
- Notas y etiquetas
- Fecha de último contacto

### Task
- Título y descripción
- Fecha límite y prioridad
- Estado y asignación
- Asociación opcional con cliente

### Activity
- Tipo de actividad
- Título y descripción
- Fecha y duración
- Asociación opcional con cliente

## Estados de Cliente

1. **Prospecto** - Cliente potencial inicial
2. **Lead** - Cliente interesado
3. **Calificado** - Cliente validado
4. **Propuesta** - Propuesta enviada
5. **Negociación** - En proceso de negociación
6. **Cerrado - Ganado** - Deal cerrado exitosamente
7. **Cerrado - Perdido** - Deal perdido

## Prioridades de Tarea

1. **Baja** - Verde
2. **Media** - Azul
3. **Alta** - Naranja
4. **Urgente** - Rojo

## Requisitos

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Instalación

1. Clona el repositorio
2. Abre `CRMApp.xcodeproj` en Xcode
3. Compila y ejecuta en el simulador o dispositivo

## Funcionalidades Futuras

- [ ] Persistencia de datos con Core Data
- [ ] Sincronización en la nube
- [ ] Notificaciones push
- [ ] Exportación de datos
- [ ] Gráficos y reportes avanzados
- [ ] Integración con calendario
- [ ] Modo oscuro
- [ ] Búsqueda avanzada
- [ ] Plantillas de actividades
- [ ] Recordatorios automáticos

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.
