\restrict 4xxpUULad3Q2YPp0uKKK9HNbgwmrMUiIqCwJGOkyCBF4KmbAo8zqtYqEDtbC3qo

-- Dumped from database version 17.6 (Debian 17.6-1.pgdg13+1)
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

ALTER TABLE ONLY public.tenants FORCE ROW LEVEL SECURITY;


--
-- Name: user_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_invitations (
    id bigint NOT NULL,
    tenant_id uuid NOT NULL,
    email character varying(510) NOT NULL,
    role integer DEFAULT 0 NOT NULL,
    token character varying NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

ALTER TABLE ONLY public.user_invitations FORCE ROW LEVEL SECURITY;


--
-- Name: user_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_invitations_id_seq OWNED BY public.user_invitations.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    tenant_id uuid NOT NULL,
    email character varying(510) NOT NULL,
    password_digest character varying NOT NULL,
    role integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

ALTER TABLE ONLY public.users FORCE ROW LEVEL SECURITY;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: user_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_invitations ALTER COLUMN id SET DEFAULT nextval('public.user_invitations_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: user_invitations user_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_invitations
    ADD CONSTRAINT user_invitations_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_tenants_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tenants_on_name ON public.tenants USING btree (name);


--
-- Name: index_user_invitations_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_invitations_on_tenant_id ON public.user_invitations USING btree (tenant_id);


--
-- Name: index_user_invitations_on_tenant_id_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_invitations_on_tenant_id_and_email ON public.user_invitations USING btree (tenant_id, email);


--
-- Name: index_user_invitations_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_invitations_on_token ON public.user_invitations USING btree (token);


--
-- Name: index_users_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_tenant_id ON public.users USING btree (tenant_id);


--
-- Name: index_users_on_tenant_id_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_tenant_id_and_email ON public.users USING btree (tenant_id, email);


--
-- Name: users fk_rails_135c8f54b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_135c8f54b2 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_invitations fk_rails_a8ecf9e4db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_invitations
    ADD CONSTRAINT fk_rails_a8ecf9e4db FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenants; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;

--
-- Name: tenants tenants_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenants_insert ON public.tenants FOR INSERT WITH CHECK ((current_setting('app.signup_phase'::text, true) = '1'::text));


--
-- Name: tenants tenants_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenants_select ON public.tenants FOR SELECT USING (((current_setting('app.signup_phase'::text, true) = '1'::text) OR (id = (NULLIF(current_setting('app.current_tenant'::text, true), ''::text))::uuid)));


--
-- Name: tenants tenants_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenants_update ON public.tenants FOR UPDATE USING ((id = (NULLIF(current_setting('app.current_tenant'::text, true), ''::text))::uuid)) WITH CHECK ((id = (NULLIF(current_setting('app.current_tenant'::text, true), ''::text))::uuid));


--
-- Name: user_invitations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_invitations ENABLE ROW LEVEL SECURITY;

--
-- Name: user_invitations user_invitations_tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_invitations_tenant_isolation ON public.user_invitations USING ((tenant_id = (NULLIF(current_setting('app.current_tenant'::text, true), ''::text))::uuid)) WITH CHECK ((tenant_id = (NULLIF(current_setting('app.current_tenant'::text, true), ''::text))::uuid));


--
-- Name: user_invitations user_invitations_token_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_invitations_token_access ON public.user_invitations FOR SELECT USING (((token)::text = current_setting('app.invitation_token'::text, true)));


--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- Name: users users_login_by_email; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_login_by_email ON public.users FOR SELECT USING (((email)::text = current_setting('app.login_email'::text, true)));


--
-- Name: users users_tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_tenant_isolation ON public.users USING ((tenant_id = (NULLIF(current_setting('app.current_tenant'::text, true), ''::text))::uuid)) WITH CHECK ((tenant_id = (NULLIF(current_setting('app.current_tenant'::text, true), ''::text))::uuid));


--
-- PostgreSQL database dump complete
--

\unrestrict 4xxpUULad3Q2YPp0uKKK9HNbgwmrMUiIqCwJGOkyCBF4KmbAo8zqtYqEDtbC3qo

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250819050733'),
('20250819050500'),
('20250815002000'),
('20250815001914'),
('20250814045435'),
('20250814045246');

