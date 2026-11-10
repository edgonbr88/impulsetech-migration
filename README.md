# ImpulseTech Migrations (`impulsetech-migration`)

Gestor de migraciones DDL para PostgreSQL 16 utilizando `dbmate`.

## Estructura
```
db/
└── migrations/
    └── YYYYMMDDHHMMSS_nombre_migracion.sql
```

## Regla de Oro
**PROHIBIDO ejecutar migraciones directamente en bases de datos productivas.** Todas las migraciones deben ejecutarse y validarse primero en el entorno local de Docker.

## Comandos Útiles
```bash
# Crear nueva migración
dbmate new nombre_de_la_migracion

# Aplicar migraciones pendientes
dbmate up

# Revertir última migración
dbmate rollback

# Ver estado de migraciones
dbmate status
```
