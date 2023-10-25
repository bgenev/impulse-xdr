--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2
-- Dumped by pg_dump version 13.2

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
-- Name: account_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_settings (
    id integer NOT NULL,
    color_scheme character varying(200)
);


ALTER TABLE public.account_settings OWNER TO postgres;

--
-- Name: account_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_settings_id_seq OWNER TO postgres;

--
-- Name: account_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_settings_id_seq OWNED BY public.account_settings.id;


--
-- Name: aggr_top_attackers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aggr_top_attackers (
    id integer NOT NULL,
    ip_addr character varying(200),
    count integer,
    country_short character varying(200),
    country_long character varying(200),
    region character varying(200),
    city character varying(200),
    latitude character varying(200),
    longitude character varying(200),
    isp character varying(200),
    pkts_sent integer,
    bytes_sent integer,
    flows_total integer,
    alerts_generated_no integer,
    signatures_no integer,
    blocked boolean
);


ALTER TABLE public.aggr_top_attackers OWNER TO postgres;

--
-- Name: aggr_top_attackers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aggr_top_attackers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggr_top_attackers_id_seq OWNER TO postgres;

--
-- Name: aggr_top_attackers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aggr_top_attackers_id_seq OWNED BY public.aggr_top_attackers.id;


--
-- Name: aggr_top_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aggr_top_categories (
    id integer NOT NULL,
    category text,
    count integer
);


ALTER TABLE public.aggr_top_categories OWNER TO postgres;

--
-- Name: aggr_top_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aggr_top_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggr_top_categories_id_seq OWNER TO postgres;

--
-- Name: aggr_top_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aggr_top_categories_id_seq OWNED BY public.aggr_top_categories.id;


--
-- Name: aggr_top_ports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aggr_top_ports (
    id integer NOT NULL,
    port integer,
    service character varying(200),
    count integer
);


ALTER TABLE public.aggr_top_ports OWNER TO postgres;

--
-- Name: aggr_top_ports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aggr_top_ports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggr_top_ports_id_seq OWNER TO postgres;

--
-- Name: aggr_top_ports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aggr_top_ports_id_seq OWNED BY public.aggr_top_ports.id;


--
-- Name: aggr_top_protocols; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aggr_top_protocols (
    id integer NOT NULL,
    proto_name character varying(200),
    count integer
);


ALTER TABLE public.aggr_top_protocols OWNER TO postgres;

--
-- Name: aggr_top_protocols_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aggr_top_protocols_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggr_top_protocols_id_seq OWNER TO postgres;

--
-- Name: aggr_top_protocols_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aggr_top_protocols_id_seq OWNED BY public.aggr_top_protocols.id;


--
-- Name: aggr_top_severity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aggr_top_severity (
    id integer NOT NULL,
    severity integer,
    count integer
);


ALTER TABLE public.aggr_top_severity OWNER TO postgres;

--
-- Name: aggr_top_severity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aggr_top_severity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggr_top_severity_id_seq OWNER TO postgres;

--
-- Name: aggr_top_severity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aggr_top_severity_id_seq OWNED BY public.aggr_top_severity.id;


--
-- Name: aggr_top_signatures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aggr_top_signatures (
    id integer NOT NULL,
    signature text,
    category text,
    count integer
);


ALTER TABLE public.aggr_top_signatures OWNER TO postgres;

--
-- Name: aggr_top_signatures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aggr_top_signatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggr_top_signatures_id_seq OWNER TO postgres;

--
-- Name: aggr_top_signatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aggr_top_signatures_id_seq OWNED BY public.aggr_top_signatures.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: detection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detection (
    id integer NOT NULL,
    score integer,
    signals integer,
    name_tags json,
    osquery_events_ids json,
    suricata_events_ids json,
    ossec_events_ids json,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.detection OWNER TO postgres;

--
-- Name: detection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.detection_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.detection_id_seq OWNER TO postgres;

--
-- Name: detection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.detection_id_seq OWNED BY public.detection.id;


--
-- Name: kernelk_meta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kernelk_meta (
    id integer NOT NULL,
    id_last_record_analysed_suricata integer,
    id_last_record_analysed_ossec integer,
    id_last_record_analysed_osquery integer
);


ALTER TABLE public.kernelk_meta OWNER TO postgres;

--
-- Name: kernelk_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kernelk_meta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kernelk_meta_id_seq OWNER TO postgres;

--
-- Name: kernelk_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kernelk_meta_id_seq OWNED BY public.kernelk_meta.id;


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


ALTER TABLE public.notification_id_seq OWNER TO postgres;

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


ALTER TABLE public.notifications_settings_id_seq OWNER TO postgres;

--
-- Name: notifications_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_settings_id_seq OWNED BY public.notifications_settings.id;


--
-- Name: osquery; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.osquery (
    id integer NOT NULL,
    message json,
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


ALTER TABLE public.osquery_id_seq OWNER TO postgres;

--
-- Name: osquery_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.osquery_id_seq OWNED BY public.osquery.id;


--
-- Name: ossec_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ossec_alerts (
    id integer NOT NULL,
    message json,
    created_on timestamp without time zone DEFAULT now(),
    agent_id character varying(50)
);


ALTER TABLE public.ossec_alerts OWNER TO postgres;

--
-- Name: ossec_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ossec_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ossec_alerts_id_seq OWNER TO postgres;

--
-- Name: ossec_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ossec_alerts_id_seq OWNED BY public.ossec_alerts.id;


--
-- Name: ossec_top_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ossec_top_comments (
    id integer NOT NULL,
    comment text,
    count integer
);


ALTER TABLE public.ossec_top_comments OWNER TO postgres;

--
-- Name: ossec_top_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ossec_top_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ossec_top_comments_id_seq OWNER TO postgres;

--
-- Name: ossec_top_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ossec_top_comments_id_seq OWNED BY public.ossec_top_comments.id;


--
-- Name: suricata_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_alerts (
    id integer NOT NULL,
    message json,
    created_on timestamp without time zone DEFAULT now(),
    agent_id character varying(50),
    saved boolean
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


ALTER TABLE public.suricata_alerts_id_seq OWNER TO postgres;

--
-- Name: suricata_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_alerts_id_seq OWNED BY public.suricata_alerts.id;


--
-- Name: suricata_dns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_dns (
    id integer NOT NULL,
    message json
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


ALTER TABLE public.suricata_dns_id_seq OWNER TO postgres;

--
-- Name: suricata_dns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_dns_id_seq OWNED BY public.suricata_dns.id;


--
-- Name: suricata_eve_flow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suricata_eve_flow (
    id integer NOT NULL,
    message json
);


ALTER TABLE public.suricata_eve_flow OWNER TO postgres;

--
-- Name: suricata_eve_flow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suricata_eve_flow_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.suricata_eve_flow_id_seq OWNER TO postgres;

--
-- Name: suricata_eve_flow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suricata_eve_flow_id_seq OWNED BY public.suricata_eve_flow.id;


--
-- Name: task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task (
    id integer NOT NULL,
    task_description character varying(5000),
    task_title character varying(200),
    created_by character varying(200),
    assigned_to character varying(200),
    action_taken character varying(200),
    completed boolean,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.task OWNER TO postgres;

--
-- Name: task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.task_id_seq OWNER TO postgres;

--
-- Name: task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_id_seq OWNED BY public.task.id;


--
-- Name: ticket; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ticket (
    id integer NOT NULL,
    ticket_description character varying(5000)
);


ALTER TABLE public.ticket OWNER TO postgres;

--
-- Name: ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ticket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ticket_id_seq OWNER TO postgres;

--
-- Name: ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ticket_id_seq OWNED BY public.ticket.id;


--
-- Name: tracked_ips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tracked_ips (
    id integer NOT NULL,
    ip character varying(50),
    domain_name character varying(100),
    pkts_count_in integer,
    bytes_count_in integer,
    pkts_count_out integer,
    bytes_count_out integer,
    connections_count integer,
    tracked boolean,
    tracking_start_time timestamp without time zone
);


ALTER TABLE public.tracked_ips OWNER TO postgres;

--
-- Name: tracked_ips_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tracked_ips_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tracked_ips_id_seq OWNER TO postgres;

--
-- Name: tracked_ips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tracked_ips_id_seq OWNED BY public.tracked_ips.id;


--
-- Name: vuls_analytics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vuls_analytics (
    id integer NOT NULL,
    severity_summary json,
    top_affected_packages json
);


ALTER TABLE public.vuls_analytics OWNER TO postgres;

--
-- Name: vuls_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vuls_analytics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vuls_analytics_id_seq OWNER TO postgres;

--
-- Name: vuls_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vuls_analytics_id_seq OWNED BY public.vuls_analytics.id;


--
-- Name: vuls_cves; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vuls_cves (
    id integer NOT NULL,
    cve_id character varying(20),
    "timestamp" timestamp without time zone
);


ALTER TABLE public.vuls_cves OWNER TO postgres;

--
-- Name: vuls_cves_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vuls_cves_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vuls_cves_id_seq OWNER TO postgres;

--
-- Name: vuls_cves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vuls_cves_id_seq OWNED BY public.vuls_cves.id;


--
-- Name: vuls_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vuls_results (
    id integer NOT NULL,
    message json,
    "timestamp" timestamp without time zone
);


ALTER TABLE public.vuls_results OWNER TO postgres;

--
-- Name: vuls_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vuls_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vuls_results_id_seq OWNER TO postgres;

--
-- Name: vuls_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vuls_results_id_seq OWNED BY public.vuls_results.id;


--
-- Name: account_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_settings ALTER COLUMN id SET DEFAULT nextval('public.account_settings_id_seq'::regclass);


--
-- Name: aggr_top_attackers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_attackers ALTER COLUMN id SET DEFAULT nextval('public.aggr_top_attackers_id_seq'::regclass);


--
-- Name: aggr_top_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_categories ALTER COLUMN id SET DEFAULT nextval('public.aggr_top_categories_id_seq'::regclass);


--
-- Name: aggr_top_ports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_ports ALTER COLUMN id SET DEFAULT nextval('public.aggr_top_ports_id_seq'::regclass);


--
-- Name: aggr_top_protocols id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_protocols ALTER COLUMN id SET DEFAULT nextval('public.aggr_top_protocols_id_seq'::regclass);


--
-- Name: aggr_top_severity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_severity ALTER COLUMN id SET DEFAULT nextval('public.aggr_top_severity_id_seq'::regclass);


--
-- Name: aggr_top_signatures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_signatures ALTER COLUMN id SET DEFAULT nextval('public.aggr_top_signatures_id_seq'::regclass);


--
-- Name: detection id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detection ALTER COLUMN id SET DEFAULT nextval('public.detection_id_seq'::regclass);


--
-- Name: kernelk_meta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kernelk_meta ALTER COLUMN id SET DEFAULT nextval('public.kernelk_meta_id_seq'::regclass);


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
-- Name: ossec_alerts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ossec_alerts ALTER COLUMN id SET DEFAULT nextval('public.ossec_alerts_id_seq'::regclass);


--
-- Name: ossec_top_comments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ossec_top_comments ALTER COLUMN id SET DEFAULT nextval('public.ossec_top_comments_id_seq'::regclass);


--
-- Name: suricata_alerts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_alerts ALTER COLUMN id SET DEFAULT nextval('public.suricata_alerts_id_seq'::regclass);


--
-- Name: suricata_dns id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_dns ALTER COLUMN id SET DEFAULT nextval('public.suricata_dns_id_seq'::regclass);


--
-- Name: suricata_eve_flow id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_eve_flow ALTER COLUMN id SET DEFAULT nextval('public.suricata_eve_flow_id_seq'::regclass);


--
-- Name: task id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task ALTER COLUMN id SET DEFAULT nextval('public.task_id_seq'::regclass);


--
-- Name: ticket id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket ALTER COLUMN id SET DEFAULT nextval('public.ticket_id_seq'::regclass);


--
-- Name: tracked_ips id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracked_ips ALTER COLUMN id SET DEFAULT nextval('public.tracked_ips_id_seq'::regclass);


--
-- Name: vuls_analytics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vuls_analytics ALTER COLUMN id SET DEFAULT nextval('public.vuls_analytics_id_seq'::regclass);


--
-- Name: vuls_cves id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vuls_cves ALTER COLUMN id SET DEFAULT nextval('public.vuls_cves_id_seq'::regclass);


--
-- Name: vuls_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vuls_results ALTER COLUMN id SET DEFAULT nextval('public.vuls_results_id_seq'::regclass);


--
-- Name: account_settings account_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_settings
    ADD CONSTRAINT account_settings_pkey PRIMARY KEY (id);


--
-- Name: aggr_top_attackers aggr_top_attackers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_attackers
    ADD CONSTRAINT aggr_top_attackers_pkey PRIMARY KEY (id);


--
-- Name: aggr_top_categories aggr_top_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_categories
    ADD CONSTRAINT aggr_top_categories_pkey PRIMARY KEY (id);


--
-- Name: aggr_top_ports aggr_top_ports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_ports
    ADD CONSTRAINT aggr_top_ports_pkey PRIMARY KEY (id);


--
-- Name: aggr_top_protocols aggr_top_protocols_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_protocols
    ADD CONSTRAINT aggr_top_protocols_pkey PRIMARY KEY (id);


--
-- Name: aggr_top_severity aggr_top_severity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_severity
    ADD CONSTRAINT aggr_top_severity_pkey PRIMARY KEY (id);


--
-- Name: aggr_top_signatures aggr_top_signatures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aggr_top_signatures
    ADD CONSTRAINT aggr_top_signatures_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: detection detection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detection
    ADD CONSTRAINT detection_pkey PRIMARY KEY (id);


--
-- Name: kernelk_meta kernelk_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kernelk_meta
    ADD CONSTRAINT kernelk_meta_pkey PRIMARY KEY (id);


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
-- Name: ossec_alerts ossec_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ossec_alerts
    ADD CONSTRAINT ossec_alerts_pkey PRIMARY KEY (id);


--
-- Name: ossec_top_comments ossec_top_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ossec_top_comments
    ADD CONSTRAINT ossec_top_comments_pkey PRIMARY KEY (id);


--
-- Name: suricata_alerts suricata_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_alerts
    ADD CONSTRAINT suricata_alerts_pkey PRIMARY KEY (id);


--
-- Name: suricata_dns suricata_dns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_dns
    ADD CONSTRAINT suricata_dns_pkey PRIMARY KEY (id);


--
-- Name: suricata_eve_flow suricata_eve_flow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suricata_eve_flow
    ADD CONSTRAINT suricata_eve_flow_pkey PRIMARY KEY (id);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- Name: ticket ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (id);


--
-- Name: tracked_ips tracked_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracked_ips
    ADD CONSTRAINT tracked_ips_pkey PRIMARY KEY (id);


--
-- Name: vuls_analytics vuls_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vuls_analytics
    ADD CONSTRAINT vuls_analytics_pkey PRIMARY KEY (id);


--
-- Name: vuls_cves vuls_cves_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vuls_cves
    ADD CONSTRAINT vuls_cves_pkey PRIMARY KEY (id);


--
-- Name: vuls_results vuls_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vuls_results
    ADD CONSTRAINT vuls_results_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

