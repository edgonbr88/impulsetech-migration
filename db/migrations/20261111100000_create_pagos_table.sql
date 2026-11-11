-- migrate:up
CREATE TYPE moneda_pago_enum AS ENUM (
    'USD',
    'VES',
    'USDT'
);

CREATE TYPE medio_pago_enum AS ENUM (
    'ZELLE',
    'PAGO_MOVIL',
    'USDT_BINANCE',
    'EFECTIVO_USD',
    'TRANSFERENCIA_VES'
);

CREATE TYPE concepto_pago_enum AS ENUM (
    'ANTICIPO_50',
    'FINIQUITO',
    'CUOTA_RETAINER',
    'OTRO'
);

CREATE TYPE estado_pago_enum AS ENUM (
    'PENDIENTE',
    'VERIFICADO',
    'RECHAZADO'
);

CREATE TABLE pagos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    servicio_id UUID REFERENCES servicios(id) ON DELETE SET NULL,
    monto NUMERIC(12, 2) NOT NULL,
    moneda moneda_pago_enum NOT NULL,
    tasa_cambio_bcv NUMERIC(12, 4),
    medio_pago medio_pago_enum NOT NULL,
    referencia_bancaria VARCHAR(100),
    concepto concepto_pago_enum NOT NULL DEFAULT 'ANTICIPO_50',
    estado_pago estado_pago_enum NOT NULL DEFAULT 'PENDIENTE',
    fecha_pago DATE NOT NULL DEFAULT CURRENT_DATE,
    comprobante_url VARCHAR(500),
    notas TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pagos_cliente_id ON pagos(cliente_id);
CREATE INDEX idx_pagos_servicio_id ON pagos(servicio_id);
CREATE INDEX idx_pagos_moneda ON pagos(moneda);
CREATE INDEX idx_pagos_estado_pago ON pagos(estado_pago);
CREATE INDEX idx_pagos_fecha_pago ON pagos(fecha_pago);

-- migrate:down
DROP TABLE IF EXISTS pagos;
DROP TYPE IF EXISTS estado_pago_enum;
DROP TYPE IF EXISTS concepto_pago_enum;
DROP TYPE IF EXISTS medio_pago_enum;
DROP TYPE IF EXISTS moneda_pago_enum;
