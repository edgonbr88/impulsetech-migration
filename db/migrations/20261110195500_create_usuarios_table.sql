-- migrate:up
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Tipo ENUM de roles de usuario
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'rol_usuario_enum') THEN
        CREATE TYPE rol_usuario_enum AS ENUM ('ADMIN', 'EJECUTIVO');
    END IF;
END$$;

-- 2. Función genérica para actualización de updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Tabla de Usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(120) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rol rol_usuario_enum NOT NULL DEFAULT 'EJECUTIVO',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_usuarios_email UNIQUE (email)
);

-- 4. Índices para rendimiento en búsquedas y filtros
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios (email);
CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON usuarios (rol);
CREATE INDEX IF NOT EXISTS idx_usuarios_activo ON usuarios (activo);

-- 5. Trigger para actualizar automáticamente updated_at
DROP TRIGGER IF EXISTS trg_usuarios_updated_at ON usuarios;
CREATE TRIGGER trg_usuarios_updated_at
BEFORE UPDATE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- 6. Seed del usuario Administrador inicial (Password: Admin2026*!)
INSERT INTO usuarios (nombre, email, password_hash, rol, activo)
VALUES (
    'Administrador ImpulseTech',
    'admin@impulsetech.com',
    '$2b$12$jRsFZJVJfajSmyz5apQCr.3BqA5WstoPeEN/LHDe79li6bpfv2aBu',
    'ADMIN',
    TRUE
)
ON CONFLICT (email) DO NOTHING;

-- migrate:down
DROP TRIGGER IF EXISTS trg_usuarios_updated_at ON usuarios;
DROP TABLE IF EXISTS usuarios;
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP TYPE IF EXISTS rol_usuario_enum;
