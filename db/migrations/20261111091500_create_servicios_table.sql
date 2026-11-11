-- migrate:up
CREATE TYPE tipo_servicio_enum AS ENUM ('LEGAL_SAREN', 'IA_AUTOMATIZACION', 'SOFTWARE_MEDIDA', 'RETAINER_MENSUAL');
CREATE TYPE modalidad_servicio_enum AS ENUM ('PROYECTO_UNICO', 'RECURRENTE_MENSUAL');
CREATE TYPE estado_operativo_servicio_enum AS ENUM ('EN_ESPERA', 'EN_DESARROLLO', 'EN_REVISION', 'ACTIVO_PRODUCCION', 'FINALIZADO', 'PAUSADO');

CREATE TABLE IF NOT EXISTS servicios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    tipo tipo_servicio_enum NOT NULL,
    nombre_servicio VARCHAR(200) NOT NULL,
    modalidad modalidad_servicio_enum NOT NULL DEFAULT 'PROYECTO_UNICO',
    estado_operativo estado_operativo_servicio_enum NOT NULL DEFAULT 'EN_ESPERA',
    especialista_responsable VARCHAR(150) NOT NULL,
    monto_pactado_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    fecha_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_entrega_estimada DATE NULL,
    dia_corte_mensual SMALLINT NULL CHECK (dia_corte_mensual BETWEEN 1 AND 31),
    notas TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_servicios_cliente_id ON servicios(cliente_id);
CREATE INDEX idx_servicios_tipo ON servicios(tipo);
CREATE INDEX idx_servicios_modalidad ON servicios(modalidad);
CREATE INDEX idx_servicios_estado_operativo ON servicios(estado_operativo);

CREATE TRIGGER update_servicios_updated_at
BEFORE UPDATE ON servicios
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- migrate:down
DROP TRIGGER IF EXISTS update_servicios_updated_at ON servicios;
DROP TABLE IF EXISTS servicios;
DROP TYPE IF EXISTS estado_operativo_servicio_enum;
DROP TYPE IF EXISTS modalidad_servicio_enum;
DROP TYPE IF EXISTS tipo_servicio_enum;
