SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: embudo_lead_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.embudo_lead_enum AS ENUM (
    'LEGAL_SAREN',
    'IA_AUTOMATIZACION',
    'SOFTWARE_MEDIDA'
);


--
-- Name: estado_cliente_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_cliente_enum AS ENUM (
    'ACTIVO',
    'INACTIVO',
    'MOROSO'
);


--
-- Name: etapa_lead_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.etapa_lead_enum AS ENUM (
    'NUEVO',
    'DIAGNOSTICO',
    'PROPUESTA',
    'NEGOCIACION',
    'GANADO',
    'PERDIDO'
);


--
-- Name: rol_usuario_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.rol_usuario_enum AS ENUM (
    'ADMIN',
    'EJECUTIVO'
);


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: clientes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clientes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    razon_social character varying(255) NOT NULL,
    rif_identificacion character varying(50) NOT NULL,
    contacto_principal character varying(150) NOT NULL,
    telefono_whatsapp character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    direccion_ciudad character varying(255),
    ejecutivo_id uuid NOT NULL,
    estado public.estado_cliente_enum DEFAULT 'ACTIVO'::public.estado_cliente_enum NOT NULL,
    notas text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: leads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre_contacto character varying(150) NOT NULL,
    empresa_o_proyecto character varying(200) NOT NULL,
    telefono_whatsapp character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    embudo public.embudo_lead_enum NOT NULL,
    etapa public.etapa_lead_enum DEFAULT 'NUEVO'::public.etapa_lead_enum NOT NULL,
    motivo_perdida text,
    valor_estimado_usd numeric(12,2) DEFAULT 0.00 NOT NULL,
    ejecutivo_asignado_id uuid NOT NULL,
    cliente_id uuid,
    notas text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(128) NOT NULL
);


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuarios (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre character varying(120) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    rol public.rol_usuario_enum DEFAULT 'EJECUTIVO'::public.rol_usuario_enum NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- Name: clientes clientes_rif_identificacion_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_rif_identificacion_key UNIQUE (rif_identificacion);


--
-- Name: leads leads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: usuarios uq_usuarios_email; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT uq_usuarios_email UNIQUE (email);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: idx_clientes_ejecutivo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_ejecutivo_id ON public.clientes USING btree (ejecutivo_id);


--
-- Name: idx_clientes_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_estado ON public.clientes USING btree (estado);


--
-- Name: idx_clientes_rif; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_rif ON public.clientes USING btree (rif_identificacion);


--
-- Name: idx_leads_cliente_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_cliente_id ON public.leads USING btree (cliente_id);


--
-- Name: idx_leads_ejecutivo_asignado_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_ejecutivo_asignado_id ON public.leads USING btree (ejecutivo_asignado_id);


--
-- Name: idx_leads_embudo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_embudo ON public.leads USING btree (embudo);


--
-- Name: idx_leads_etapa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_etapa ON public.leads USING btree (etapa);


--
-- Name: idx_usuarios_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_activo ON public.usuarios USING btree (activo);


--
-- Name: idx_usuarios_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_email ON public.usuarios USING btree (email);


--
-- Name: idx_usuarios_rol; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_rol ON public.usuarios USING btree (rol);


--
-- Name: usuarios trg_usuarios_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_usuarios_updated_at BEFORE UPDATE ON public.usuarios FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: clientes update_clientes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_clientes_updated_at BEFORE UPDATE ON public.clientes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: leads update_leads_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON public.leads FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: clientes clientes_ejecutivo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_ejecutivo_id_fkey FOREIGN KEY (ejecutivo_id) REFERENCES public.usuarios(id) ON DELETE RESTRICT;


--
-- Name: leads leads_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE SET NULL;


--
-- Name: leads leads_ejecutivo_asignado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_ejecutivo_asignado_id_fkey FOREIGN KEY (ejecutivo_asignado_id) REFERENCES public.usuarios(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20261110195500'),
    ('20261110231500'),
    ('20261111084500');
