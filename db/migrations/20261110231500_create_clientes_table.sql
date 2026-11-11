-- migrate:up
CREATE TYPE estado_cliente_enum AS ENUM ('ACTIVO', 'INACTIVO', 'MOROSO');

CREATE TABLE IF NOT EXISTS clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    razon_social VARCHAR(255) NOT NULL,
    rif_identificacion VARCHAR(50) NOT NULL UNIQUE,
    contacto_principal VARCHAR(150) NOT NULL,
    telefono_whatsapp VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    direccion_ciudad VARCHAR(255) NULL,
    ejecutivo_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    estado estado_cliente_enum NOT NULL DEFAULT 'ACTIVO',
    notas TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clientes_ejecutivo_id ON clientes(ejecutivo_id);
CREATE INDEX idx_clientes_estado ON clientes(estado);
CREATE INDEX idx_clientes_rif ON clientes(rif_identificacion);

CREATE TRIGGER update_clientes_updated_at
BEFORE UPDATE ON clientes
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- migrate:down
DROP TRIGGER IF EXISTS update_clientes_updated_at ON clientes;
DROP TABLE IF EXISTS clientes;
DROP TYPE IF EXISTS estado_cliente_enum;
