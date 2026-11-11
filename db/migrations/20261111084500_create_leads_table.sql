-- migrate:up
CREATE TYPE embudo_lead_enum AS ENUM ('LEGAL_SAREN', 'IA_AUTOMATIZACION', 'SOFTWARE_MEDIDA');
CREATE TYPE etapa_lead_enum AS ENUM ('NUEVO', 'DIAGNOSTICO', 'PROPUESTA', 'NEGOCIACION', 'GANADO', 'PERDIDO');

CREATE TABLE IF NOT EXISTS leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_contacto VARCHAR(150) NOT NULL,
    empresa_o_proyecto VARCHAR(200) NOT NULL,
    telefono_whatsapp VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    embudo embudo_lead_enum NOT NULL,
    etapa etapa_lead_enum NOT NULL DEFAULT 'NUEVO',
    motivo_perdida TEXT NULL,
    valor_estimado_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    ejecutivo_asignado_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    cliente_id UUID NULL REFERENCES clientes(id) ON DELETE SET NULL,
    notas TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_leads_embudo ON leads(embudo);
CREATE INDEX idx_leads_etapa ON leads(etapa);
CREATE INDEX idx_leads_ejecutivo_asignado_id ON leads(ejecutivo_asignado_id);
CREATE INDEX idx_leads_cliente_id ON leads(cliente_id);

CREATE TRIGGER update_leads_updated_at
BEFORE UPDATE ON leads
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- migrate:down
DROP TRIGGER IF EXISTS update_leads_updated_at ON leads;
DROP TABLE IF EXISTS leads;
DROP TYPE IF EXISTS etapa_lead_enum;
DROP TYPE IF EXISTS embudo_lead_enum;
