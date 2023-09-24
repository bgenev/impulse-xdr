--
-- PostgreSQL database dump
--

-- Dumped from database version 16.0
-- Dumped by pg_dump version 16.0

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: data_transfers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_transfers (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now(),
    agent_id character varying(50),
    saved boolean,
    assigned_to character varying(1000)
);


ALTER TABLE public.data_transfers OWNER TO postgres;

--
-- Name: data_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_transfers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_transfers_id_seq OWNER TO postgres;

--
-- Name: data_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_transfers_id_seq OWNED BY public.data_transfers.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
    id integer NOT NULL,
    notification_message character varying(200),
    task_id integer,
    "timestamp" timestamp without time zone
);


ALTER TABLE public.notification OWNER TO postgres;

--
-- Name: notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_id_seq OWNER TO postgres;

--
-- Name: notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_id_seq OWNED BY public.notification.id;


--
-- Name: notifications_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications_settings (
    id integer NOT NULL,
    notifications character varying(200)
);


ALTER TABLE public.notifications_settings OWNER TO postgres;

--
-- Name: notifications_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_settings_id_seq OWNER TO postgres;

--
-- Name: notifications_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_settings_id_seq OWNED BY public.notifications_settings.id;


--
-- Name: osquery; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.osquery (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.osquery OWNER TO postgres;

--
-- Name: osquery_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.osquery_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.osquery_id_seq OWNER TO postgres;

--
-- Name: osquery_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.osquery_id_seq OWNED BY public.osquery.id;


--
-- Name: processed_analytics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.processed_analytics (
    id integer NOT NULL,
    indicator_name character varying(10000),
    indicator_count integer,
    indicator_table character varying(100),
    category character varying(100),
    affected_asset character varying(100),
    batch_date date
);


ALTER TABLE public.processed_analytics OWNER TO postgres;

--
-- Name: processed_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.processed_analytics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.processed_analytics_id_seq OWNER TO postgres;

--
-- Name: processed_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.processed_analytics_id_seq OWNED BY public.processed_analytics.id;


--
-- Name: sca_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sca_alerts (
    id integer NOT NULL,
    agent_ip character varying(50),
    rule_id integer,
    test_state character varying(100),
    created_on timestamp without time zone
);


ALTER TABLE public.sca_alerts OWNER TO postgres;

--
-- Name: sca_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sca_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sca_alerts_id_seq OWNER TO postgres;

--
-- Name: sca_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sca_alerts_id_seq OWNED BY public.sca_alerts.id;


--
-- Name: scp_packs_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scp_packs_alerts (
    id integer NOT NULL,
    agent_ip character varying(50),
    pack_name character varying(1000),
    query_id integer,
    test_state character varying(100),
    resolved boolean,
    message jsonb,
    created_on timestamp without time zone
);


ALTER TABLE public.scp_packs_alerts OWNER TO postgres;

--
-- Name: scp_packs_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.scp_packs_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scp_packs_alerts_id_seq OWNER TO postgres;

--
-- Name: scp_packs_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.scp_packs_alerts_id_seq OWNED BY public.scp_packs_alerts.id;


--
-- Name: scp_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scp_results (
    id integer NOT NULL,
    agent_ip character varying(50),
    pack_name character varying(1000),
    query_id integer,
    test_state character varying(100),
    updated_on timestamp without time zone
);


ALTER TABLE public.scp_results OWNER TO postgres;

--
-- Name: scp_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.scp_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scp_results_id_seq OWNER TO postgres;

--
-- Name: scp_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.scp_results_id_seq OWNED BY public.scp_results.id;


--
-- Name: suricata_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_alerts (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now(),
    agent_id character varying(50),
    saved boolean,
    assigned_to character varying(1000)
);


ALTER TABLE public.suricata_alerts OWNER TO postgres;

--
-- Name: suricata_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_alerts_id_seq OWNER TO postgres;

--
-- Name: suricata_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_alerts_id_seq OWNED BY public.suricata_alerts.id;


--
-- Name: suricata_dhcp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_dhcp (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suricata_dhcp OWNER TO postgres;

--
-- Name: suricata_dhcp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_dhcp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_dhcp_id_seq OWNER TO postgres;

--
-- Name: suricata_dhcp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_dhcp_id_seq OWNED BY public.suricata_dhcp.id;


--
-- Name: suricata_dns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_dns (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suricata_dns OWNER TO postgres;

--
-- Name: suricata_dns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_dns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_dns_id_seq OWNER TO postgres;

--
-- Name: suricata_dns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_dns_id_seq OWNED BY public.suricata_dns.id;


--
-- Name: suricata_eve_flow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_eve_flow (
    id bigint NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suricata_eve_flow OWNER TO postgres;

--
-- Name: suricata_eve_flow_derived; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_eve_flow_derived (
    id bigint NOT NULL,
    ip_addr character varying(50),
    total_received double precision,
    total_sent double precision,
    total_inbound double precision,
    total_outbound double precision,
    batch_date timestamp without time zone
);


ALTER TABLE public.suricata_eve_flow_derived OWNER TO postgres;

--
-- Name: suricata_eve_flow_derived_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_eve_flow_derived_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_eve_flow_derived_id_seq OWNER TO postgres;

--
-- Name: suricata_eve_flow_derived_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_eve_flow_derived_id_seq OWNED BY public.suricata_eve_flow_derived.id;


--
-- Name: suricata_eve_flow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_eve_flow_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_eve_flow_id_seq OWNER TO postgres;

--
-- Name: suricata_eve_flow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_eve_flow_id_seq OWNED BY public.suricata_eve_flow.id;


--
-- Name: suricata_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_files (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suricata_files OWNER TO postgres;

--
-- Name: suricata_files_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_files_id_seq OWNER TO postgres;

--
-- Name: suricata_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_files_id_seq OWNED BY public.suricata_files.id;


--
-- Name: suricata_ftp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_ftp (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suricata_ftp OWNER TO postgres;

--
-- Name: suricata_ftp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_ftp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_ftp_id_seq OWNER TO postgres;

--
-- Name: suricata_ftp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_ftp_id_seq OWNED BY public.suricata_ftp.id;


--
-- Name: suricata_http; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_http (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suricata_http OWNER TO postgres;

--
-- Name: suricata_http_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_http_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_http_id_seq OWNER TO postgres;

--
-- Name: suricata_http_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_http_id_seq OWNED BY public.suricata_http.id;


--
-- Name: suricata_smb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_smb (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suricata_smb OWNER TO postgres;

--
-- Name: suricata_smb_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_smb_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_smb_id_seq OWNER TO postgres;

--
-- Name: suricata_smb_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_smb_id_seq OWNED BY public.suricata_smb.id;


--
-- Name: suricata_smtp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_smtp (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suricata_smtp OWNER TO postgres;

--
-- Name: suricata_smtp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_smtp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_smtp_id_seq OWNER TO postgres;

--
-- Name: suricata_smtp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_smtp_id_seq OWNED BY public.suricata_smtp.id;


--
-- Name: suricata_ssh; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_ssh (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suricata_ssh OWNER TO postgres;

--
-- Name: suricata_ssh_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_ssh_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_ssh_id_seq OWNER TO postgres;

--
-- Name: suricata_ssh_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_ssh_id_seq OWNED BY public.suricata_ssh.id;


--
-- Name: suricata_tls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_tls (
    id integer NOT NULL,
    message jsonb,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suricata_tls OWNER TO postgres;

--
-- Name: suricata_tls_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_tls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suricata_tls_id_seq OWNER TO postgres;

--
-- Name: suricata_tls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_tls_id_seq OWNED BY public.suricata_tls.id;


--
-- Name: system_profile_historical; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_profile_historical (
    id integer NOT NULL,
    indicator_name character varying(1000),
    indicator_count integer,
    batch_date timestamp without time zone
);


ALTER TABLE public.system_profile_historical OWNER TO postgres;

--
-- Name: system_profile_historical_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.system_profile_historical_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_profile_historical_id_seq OWNER TO postgres;

--
-- Name: system_profile_historical_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.system_profile_historical_id_seq OWNED BY public.system_profile_historical.id;


--
-- Name: uba_ssh; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.uba_ssh (
    id integer NOT NULL,
    host_ip_addr character varying(30)
);


ALTER TABLE public.uba_ssh OWNER TO postgres;

--
-- Name: uba_ssh_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.uba_ssh_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.uba_ssh_id_seq OWNER TO postgres;

--
-- Name: uba_ssh_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.uba_ssh_id_seq OWNED BY public.uba_ssh.id;


--
-- Name: data_transfers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_transfers ALTER COLUMN id SET DEFAULT nextval('public.data_transfers_id_seq'::regclass);


--
-- Name: notification id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification ALTER COLUMN id SET DEFAULT nextval('public.notification_id_seq'::regclass);


--
-- Name: notifications_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications_settings ALTER COLUMN id SET DEFAULT nextval('public.notifications_settings_id_seq'::regclass);


--
-- Name: osquery id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.osquery ALTER COLUMN id SET DEFAULT nextval('public.osquery_id_seq'::regclass);


--
-- Name: processed_analytics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.processed_analytics ALTER COLUMN id SET DEFAULT nextval('public.processed_analytics_id_seq'::regclass);


--
-- Name: sca_alerts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sca_alerts ALTER COLUMN id SET DEFAULT nextval('public.sca_alerts_id_seq'::regclass);


--
-- Name: scp_packs_alerts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scp_packs_alerts ALTER COLUMN id SET DEFAULT nextval('public.scp_packs_alerts_id_seq'::regclass);


--
-- Name: scp_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scp_results ALTER COLUMN id SET DEFAULT nextval('public.scp_results_id_seq'::regclass);


--
-- Name: suricata_alerts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_alerts ALTER COLUMN id SET DEFAULT nextval('public.suricata_alerts_id_seq'::regclass);


--
-- Name: suricata_dhcp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_dhcp ALTER COLUMN id SET DEFAULT nextval('public.suricata_dhcp_id_seq'::regclass);


--
-- Name: suricata_dns id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_dns ALTER COLUMN id SET DEFAULT nextval('public.suricata_dns_id_seq'::regclass);


--
-- Name: suricata_eve_flow id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_eve_flow ALTER COLUMN id SET DEFAULT nextval('public.suricata_eve_flow_id_seq'::regclass);


--
-- Name: suricata_eve_flow_derived id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_eve_flow_derived ALTER COLUMN id SET DEFAULT nextval('public.suricata_eve_flow_derived_id_seq'::regclass);


--
-- Name: suricata_files id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_files ALTER COLUMN id SET DEFAULT nextval('public.suricata_files_id_seq'::regclass);


--
-- Name: suricata_ftp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_ftp ALTER COLUMN id SET DEFAULT nextval('public.suricata_ftp_id_seq'::regclass);


--
-- Name: suricata_http id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_http ALTER COLUMN id SET DEFAULT nextval('public.suricata_http_id_seq'::regclass);


--
-- Name: suricata_smb id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_smb ALTER COLUMN id SET DEFAULT nextval('public.suricata_smb_id_seq'::regclass);


--
-- Name: suricata_smtp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_smtp ALTER COLUMN id SET DEFAULT nextval('public.suricata_smtp_id_seq'::regclass);


--
-- Name: suricata_ssh id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_ssh ALTER COLUMN id SET DEFAULT nextval('public.suricata_ssh_id_seq'::regclass);


--
-- Name: suricata_tls id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_tls ALTER COLUMN id SET DEFAULT nextval('public.suricata_tls_id_seq'::regclass);


--
-- Name: system_profile_historical id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_profile_historical ALTER COLUMN id SET DEFAULT nextval('public.system_profile_historical_id_seq'::regclass);


--
-- Name: uba_ssh id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uba_ssh ALTER COLUMN id SET DEFAULT nextval('public.uba_ssh_id_seq'::regclass);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: data_transfers data_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_transfers
    ADD CONSTRAINT data_transfers_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: notifications_settings notifications_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications_settings
    ADD CONSTRAINT notifications_settings_pkey PRIMARY KEY (id);


--
-- Name: osquery osquery_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.osquery
    ADD CONSTRAINT osquery_pkey PRIMARY KEY (id);


--
-- Name: processed_analytics processed_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.processed_analytics
    ADD CONSTRAINT processed_analytics_pkey PRIMARY KEY (id);


--
-- Name: sca_alerts sca_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sca_alerts
    ADD CONSTRAINT sca_alerts_pkey PRIMARY KEY (id);


--
-- Name: scp_packs_alerts scp_packs_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scp_packs_alerts
    ADD CONSTRAINT scp_packs_alerts_pkey PRIMARY KEY (id);


--
-- Name: scp_results scp_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scp_results
    ADD CONSTRAINT scp_results_pkey PRIMARY KEY (id);


--
-- Name: suricata_alerts suricata_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_alerts
    ADD CONSTRAINT suricata_alerts_pkey PRIMARY KEY (id);


--
-- Name: suricata_dhcp suricata_dhcp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_dhcp
    ADD CONSTRAINT suricata_dhcp_pkey PRIMARY KEY (id);


--
-- Name: suricata_dns suricata_dns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_dns
    ADD CONSTRAINT suricata_dns_pkey PRIMARY KEY (id);


--
-- Name: suricata_eve_flow_derived suricata_eve_flow_derived_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_eve_flow_derived
    ADD CONSTRAINT suricata_eve_flow_derived_pkey PRIMARY KEY (id);


--
-- Name: suricata_eve_flow suricata_eve_flow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_eve_flow
    ADD CONSTRAINT suricata_eve_flow_pkey PRIMARY KEY (id);


--
-- Name: suricata_files suricata_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_files
    ADD CONSTRAINT suricata_files_pkey PRIMARY KEY (id);


--
-- Name: suricata_ftp suricata_ftp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_ftp
    ADD CONSTRAINT suricata_ftp_pkey PRIMARY KEY (id);


--
-- Name: suricata_http suricata_http_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_http
    ADD CONSTRAINT suricata_http_pkey PRIMARY KEY (id);


--
-- Name: suricata_smb suricata_smb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_smb
    ADD CONSTRAINT suricata_smb_pkey PRIMARY KEY (id);


--
-- Name: suricata_smtp suricata_smtp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_smtp
    ADD CONSTRAINT suricata_smtp_pkey PRIMARY KEY (id);


--
-- Name: suricata_ssh suricata_ssh_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_ssh
    ADD CONSTRAINT suricata_ssh_pkey PRIMARY KEY (id);


--
-- Name: suricata_tls suricata_tls_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_tls
    ADD CONSTRAINT suricata_tls_pkey PRIMARY KEY (id);


--
-- Name: system_profile_historical system_profile_historical_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_profile_historical
    ADD CONSTRAINT system_profile_historical_pkey PRIMARY KEY (id);


--
-- Name: uba_ssh uba_ssh_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uba_ssh
    ADD CONSTRAINT uba_ssh_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

