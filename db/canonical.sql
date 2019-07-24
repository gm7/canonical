--
-- PostgreSQL database dump
--

-- Dumped from database version 10.9 (Debian 10.9-1.pgdg90+1)
-- Dumped by pg_dump version 10.9 (Ubuntu 10.9-0ubuntu0.18.04.1)

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
-- Name: _documents; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA _documents;


ALTER SCHEMA _documents OWNER TO postgres;

--
-- Name: _reports; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA _reports;


ALTER SCHEMA _reports OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: report_status; Type: TYPE; Schema: _reports; Owner: postgres
--

CREATE TYPE _reports.report_status AS ENUM (
    'PENDING',
    'STARTED',
    'FAILED',
    'FINISHED'
);


ALTER TYPE _reports.report_status OWNER TO postgres;

--
-- Name: TYPE report_status; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON TYPE _reports.report_status IS 'Status of the request to generated a report
PENDING: requested accepted 
STARTED: processing of the request has started 
FAILED: processing for generating the report failed
FINISHED: processing for generating the report of streamed destination complete
FINISHED_REMOTE: processing for generating the report to any destination other than streaming is complete';


--
-- Name: ui-notification_status; Type: TYPE; Schema: _reports; Owner: postgres
--

CREATE TYPE _reports."ui-notification_status" AS ENUM (
    'unread',
    'read',
    'closed'
);


ALTER TYPE _reports."ui-notification_status" OWNER TO postgres;

--
-- Name: TYPE "ui-notification_status"; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON TYPE _reports."ui-notification_status" IS 'this provides an enumerated type for ui-notifications';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attribute_label; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.attribute_label (
    id smallint NOT NULL,
    name text NOT NULL,
    attribute_validaton text,
    __updated_on timestamp without time zone NOT NULL,
    __updated_by uuid NOT NULL
);


ALTER TABLE _documents.attribute_label OWNER TO postgres;

--
-- Name: TABLE attribute_label; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON TABLE _documents.attribute_label IS 'eg. Contract Renewal Date, and the validation regex will be dd-mm-yyyy would be:
^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$.';


--
-- Name: COLUMN attribute_label.name; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.attribute_label.name IS 'human readable label';


--
-- Name: COLUMN attribute_label.attribute_validaton; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.attribute_label.attribute_validaton IS 'regular expression to validate the attribute';


--
-- Name: attribute_label_id_seq; Type: SEQUENCE; Schema: _documents; Owner: postgres
--

ALTER TABLE _documents.attribute_label ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME _documents.attribute_label_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: document; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.document (
    id uuid NOT NULL,
    name text NOT NULL,
    description text,
    content_type text,
    __updated_on timestamp without time zone NOT NULL,
    __updated_by uuid NOT NULL
);


ALTER TABLE _documents.document OWNER TO postgres;

--
-- Name: TABLE document; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON TABLE _documents.document IS 'All documents';


--
-- Name: COLUMN document.name; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document.name IS 'Document name';


--
-- Name: COLUMN document.description; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document.description IS 'Optional description for the document';


--
-- Name: COLUMN document.content_type; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document.content_type IS 'mime/type ppt, pdf, csv, docx, odf etc';


--
-- Name: document_acl; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.document_acl (
    id bigint NOT NULL,
    document_id uuid NOT NULL,
    user_uuid uuid NOT NULL,
    permission text DEFAULT 'read'::text NOT NULL,
    may_assign boolean DEFAULT false NOT NULL,
    _granted_by uuid NOT NULL,
    _granted_on timestamp without time zone NOT NULL
);


ALTER TABLE _documents.document_acl OWNER TO postgres;

--
-- Name: COLUMN document_acl.user_uuid; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_acl.user_uuid IS 'the user_uuid as stored in Keycloak (or other identity storage) or
the group_uuid as stored in the _documents schema';


--
-- Name: COLUMN document_acl.permission; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_acl.permission IS 'READ < WRITE (and modify meta-data), < ROLLBACK < UN/ARCHIVE';


--
-- Name: COLUMN document_acl.may_assign; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_acl.may_assign IS 'able to assign document rights to others';


--
-- Name: COLUMN document_acl._granted_by; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_acl._granted_by IS 'uuid of the user who granted these acl rights';


--
-- Name: document_acl_id_seq; Type: SEQUENCE; Schema: _documents; Owner: postgres
--

ALTER TABLE _documents.document_acl ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME _documents.document_acl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: document_attribute; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.document_attribute (
    document_id uuid NOT NULL,
    attribute_value text,
    attribute_label smallint NOT NULL,
    __updated_on timestamp without time zone NOT NULL,
    __updated_by uuid NOT NULL
);


ALTER TABLE _documents.document_attribute OWNER TO postgres;

--
-- Name: TABLE document_attribute; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON TABLE _documents.document_attribute IS 'for custom attributes added at run time by users';


--
-- Name: COLUMN document_attribute.attribute_value; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_attribute.attribute_value IS 'eg. contract expiry date : 21/09/2023';


--
-- Name: document_document_group; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.document_document_group (
    document_id uuid NOT NULL,
    document_group_id uuid NOT NULL
);


ALTER TABLE _documents.document_document_group OWNER TO postgres;

--
-- Name: document_group; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.document_group (
    id uuid NOT NULL,
    name text NOT NULL,
    __updated_on timestamp without time zone NOT NULL,
    __updated_by uuid NOT NULL
);


ALTER TABLE _documents.document_group OWNER TO postgres;

--
-- Name: TABLE document_group; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON TABLE _documents.document_group IS 'group of users to which acl rights may be asigned';


--
-- Name: document_group_user; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.document_group_user (
    id bigint NOT NULL,
    group_uuid uuid NOT NULL,
    user_uuid uuid,
    __updated_by uuid NOT NULL,
    __updated_on timestamp without time zone NOT NULL
);


ALTER TABLE _documents.document_group_user OWNER TO postgres;

--
-- Name: COLUMN document_group_user.user_uuid; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_group_user.user_uuid IS 'the user uuid as stored in Keycloak (or other identity storage)';


--
-- Name: COLUMN document_group_user.__updated_by; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_group_user.__updated_by IS 'uuid of the user who granted these acl rights';


--
-- Name: document_group_user_id_seq; Type: SEQUENCE; Schema: _documents; Owner: postgres
--

ALTER TABLE _documents.document_group_user ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME _documents.document_group_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: document_status; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.document_status (
    id bigint NOT NULL,
    document_id uuid,
    updated_on date NOT NULL,
    status text NOT NULL
);


ALTER TABLE _documents.document_status OWNER TO postgres;

--
-- Name: COLUMN document_status.status; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_status.status IS 'CREATED, UPDATED, EDITED, DELETED, DESTROYED, ROLLBACK
Suggest using a databasetype for this';


--
-- Name: document_status_id_seq; Type: SEQUENCE; Schema: _documents; Owner: postgres
--

ALTER TABLE _documents.document_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME _documents.document_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: document_tag; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.document_tag (
    document_id uuid,
    tag text
);


ALTER TABLE _documents.document_tag OWNER TO postgres;

--
-- Name: TABLE document_tag; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON TABLE _documents.document_tag IS 'DENORMALISED for performance';


--
-- Name: document_version; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.document_version (
    id uuid NOT NULL,
    document_id uuid,
    checksum text NOT NULL,
    __uploaded_on timestamp without time zone NOT NULL,
    __uploaded_by uuid NOT NULL
);


ALTER TABLE _documents.document_version OWNER TO postgres;

--
-- Name: TABLE document_version; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON TABLE _documents.document_version IS 'this table holds the various instance meta-data of a particular document';


--
-- Name: COLUMN document_version.checksum; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_version.checksum IS 'an MD5 digest to ensure file integrity';


--
-- Name: document_version_parts; Type: TABLE; Schema: _documents; Owner: postgres
--

CREATE TABLE _documents.document_version_parts (
    document_version_id uuid NOT NULL,
    sequence smallint NOT NULL,
    part_uuid uuid NOT NULL,
    checksum text NOT NULL
);


ALTER TABLE _documents.document_version_parts OWNER TO postgres;

--
-- Name: COLUMN document_version_parts.sequence; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_version_parts.sequence IS 'sequence number of the document blob';


--
-- Name: COLUMN document_version_parts.checksum; Type: COMMENT; Schema: _documents; Owner: postgres
--

COMMENT ON COLUMN _documents.document_version_parts.checksum IS 'an MD5 digest to ensure part integrity';


--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: _documents; Owner: postgres
--

CREATE SEQUENCE _documents.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE _documents.hibernate_sequence OWNER TO postgres;

--
-- Name: datasource; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.datasource (
    datasource_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type text NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    is_active boolean DEFAULT false
);


ALTER TABLE _reports.datasource OWNER TO postgres;

--
-- Name: destination; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.destination (
    destination_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type text NOT NULL,
    name text NOT NULL,
    description text,
    security_protocol text NOT NULL,
    timeout bigint DEFAULT 5000,
    is_active boolean DEFAULT false,
    downloadable boolean NOT NULL,
    __updated_on timestamp with time zone NOT NULL,
    __updated_by uuid NOT NULL
);


ALTER TABLE _reports.destination OWNER TO postgres;

--
-- Name: COLUMN destination.__updated_on; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.destination.__updated_on IS 'timestamptz when destination was last updated (changed) ';


--
-- Name: COLUMN destination.__updated_by; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.destination.__updated_by IS 'UUID of the user that last updated this destination at the __updated_on time. ';


--
-- Name: destination_parameter; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.destination_parameter (
    id bigint NOT NULL,
    destination_id uuid NOT NULL,
    name text NOT NULL,
    data_type text NOT NULL,
    description text,
    required boolean DEFAULT true NOT NULL,
    validation text
);


ALTER TABLE _reports.destination_parameter OWNER TO postgres;

--
-- Name: TABLE destination_parameter; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON TABLE _reports.destination_parameter IS 'Holds the possible variable parameters for a destination. For example SFTP can have a path (which could be different for any report request), SMTP has to,cc,bcc,subject,body parameters. ';


--
-- Name: COLUMN destination_parameter.validation; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.destination_parameter.validation IS 'RegEx used to validate a selected_destination_paramter. As selected_destination_parameter.value is just TEXT. (eg. for an email the ##.validation field might be something like: ^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,}$';


--
-- Name: destination_parameter_id_seq; Type: SEQUENCE; Schema: _reports; Owner: postgres
--

ALTER TABLE _reports.destination_parameter ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME _reports.destination_parameter_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1
);


--
-- Name: export_format; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.export_format (
    id smallint NOT NULL,
    name text,
    media_type text,
    is_active boolean
);


ALTER TABLE _reports.export_format OWNER TO postgres;

--
-- Name: TABLE export_format; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON TABLE _reports.export_format IS 'enum ? PDF, CSV, TXT, ';


--
-- Name: export_format_id_seq; Type: SEQUENCE; Schema: _reports; Owner: postgres
--

ALTER TABLE _reports.export_format ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME _reports.export_format_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1
);


--
-- Name: flat_file; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.flat_file (
    datasource_id uuid NOT NULL,
    file_uri text NOT NULL,
    char_set text NOT NULL,
    flat_file_style text NOT NULL,
    first_line_header boolean DEFAULT true,
    second_line_data_type_indicator boolean DEFAULT false
);


ALTER TABLE _reports.flat_file OWNER TO postgres;

--
-- Name: generated_report; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.generated_report (
    correlation_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    requested_by uuid NOT NULL,
    requested_at timestamp with time zone NOT NULL,
    generated_at timestamp with time zone NOT NULL,
    destination_id uuid NOT NULL,
    template_id uuid NOT NULL,
    export_format_id smallint NOT NULL,
    request_body text NOT NULL,
    report_status _reports.report_status,
    retry_count smallint DEFAULT 0,
    processed_by text
);


ALTER TABLE _reports.generated_report OWNER TO postgres;

--
-- Name: COLUMN generated_report.requested_by; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.generated_report.requested_by IS 'The uuid of the users (in KeyCloak) logged in and requesting the report';


--
-- Name: COLUMN generated_report.request_body; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.generated_report.request_body IS 'JSON of the request body to be used for generating this report';


--
-- Name: COLUMN generated_report.retry_count; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.generated_report.retry_count IS 'Number of times left to rety upon failure ';


--
-- Name: COLUMN generated_report.processed_by; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.generated_report.processed_by IS 'The name of instance/thread that last processed, this generated_report request. ';


--
-- Name: jdbc; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.jdbc (
    datasource_id uuid NOT NULL,
    driver_class text NOT NULL,
    db_url text NOT NULL,
    username text NOT NULL,
    password bytea NOT NULL,
    password_hash text NOT NULL
);


ALTER TABLE _reports.jdbc OWNER TO postgres;

--
-- Name: COLUMN jdbc.password_hash; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.jdbc.password_hash IS 'This column will be used to validate that the decryption of the encrypted password was successful.';


--
-- Name: s3; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.s3 (
    destination_id uuid NOT NULL,
    access_key text NOT NULL,
    secret_key text NOT NULL
);


ALTER TABLE _reports.s3 OWNER TO postgres;

--
-- Name: selected_destination_parameter; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.selected_destination_parameter (
    id bigint NOT NULL,
    correlation_id uuid NOT NULL,
    destination_parameter_id bigint,
    value text
);


ALTER TABLE _reports.selected_destination_parameter OWNER TO postgres;

--
-- Name: TABLE selected_destination_parameter; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON TABLE _reports.selected_destination_parameter IS 'destination parameter value for the specific report. For example if destination type is SMTP. destination_parameter entries would include: 
to: melissap@grindrodbank.co.za
subject: report to be sent';


--
-- Name: selected_destination_parameter_id_seq; Type: SEQUENCE; Schema: _reports; Owner: postgres
--

ALTER TABLE _reports.selected_destination_parameter ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME _reports.selected_destination_parameter_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sftp; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.sftp (
    destination_id uuid NOT NULL,
    host text NOT NULL,
    port smallint NOT NULL,
    username text NOT NULL,
    password bytea NOT NULL,
    password_hash text NOT NULL,
    working_directory text NOT NULL
);


ALTER TABLE _reports.sftp OWNER TO postgres;

--
-- Name: COLUMN sftp.password_hash; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.sftp.password_hash IS 'This column will be used to validate that the decryption of the encrypted password was successful.';


--
-- Name: smtp; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.smtp (
    destination_id uuid NOT NULL,
    host text NOT NULL,
    port smallint NOT NULL,
    username text NOT NULL,
    password bytea NOT NULL,
    password_hash text NOT NULL,
    from_address text NOT NULL
);


ALTER TABLE _reports.smtp OWNER TO postgres;

--
-- Name: COLUMN smtp.password_hash; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.smtp.password_hash IS 'This column will be used to validate that the decryption of the encrypted password was successful.';


--
-- Name: stream; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.stream (
    destination_id uuid NOT NULL
);


ALTER TABLE _reports.stream OWNER TO postgres;

--
-- Name: template; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.template (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    original_filename text NOT NULL
);


ALTER TABLE _reports.template OWNER TO postgres;

--
-- Name: COLUMN template.original_filename; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.template.original_filename IS 'the birt report design file location ';


--
-- Name: template_datasource; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.template_datasource (
    template_id uuid NOT NULL,
    datasource_id uuid NOT NULL
);


ALTER TABLE _reports.template_datasource OWNER TO postgres;

--
-- Name: template_tag; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.template_tag (
    template_id uuid,
    tag text NOT NULL
);


ALTER TABLE _reports.template_tag OWNER TO postgres;

--
-- Name: TABLE template_tag; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON TABLE _reports.template_tag IS 'Purposely Denormalised';


--
-- Name: ui-notification; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports."ui-notification" (
    id bigint NOT NULL,
    title text NOT NULL,
    message text,
    notification_status _reports."ui-notification_status",
    user_id uuid
);


ALTER TABLE _reports."ui-notification" OWNER TO postgres;

--
-- Name: TABLE "ui-notification"; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON TABLE _reports."ui-notification" IS 'to be replaced later with a more robust topic-subscribe notfication capability';


--
-- Name: web_endpoint; Type: TABLE; Schema: _reports; Owner: postgres
--

CREATE TABLE _reports.web_endpoint (
    destination_id uuid NOT NULL,
    url text NOT NULL,
    verb text NOT NULL
);


ALTER TABLE _reports.web_endpoint OWNER TO postgres;

--
-- Name: COLUMN web_endpoint.verb; Type: COMMENT; Schema: _reports; Owner: postgres
--

COMMENT ON COLUMN _reports.web_endpoint.verb IS 'POST,PUT';


--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO postgres;

--
-- Name: document_group_user document_group_user_pk; Type: CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_group_user
    ADD CONSTRAINT document_group_user_pk PRIMARY KEY (id);


--
-- Name: document_acl document_share_acl_pk; Type: CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_acl
    ADD CONSTRAINT document_share_acl_pk PRIMARY KEY (id);


--
-- Name: document_group document_usergroup_pk; Type: CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_group
    ADD CONSTRAINT document_usergroup_pk PRIMARY KEY (id);


--
-- Name: document pk_document; Type: CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document
    ADD CONSTRAINT pk_document PRIMARY KEY (id);


--
-- Name: document_attribute pk_document_attribute; Type: CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_attribute
    ADD CONSTRAINT pk_document_attribute PRIMARY KEY (document_id, attribute_label);


--
-- Name: attribute_label pk_document_attribute_label; Type: CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.attribute_label
    ADD CONSTRAINT pk_document_attribute_label PRIMARY KEY (id);


--
-- Name: document_status pk_document_status; Type: CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_status
    ADD CONSTRAINT pk_document_status PRIMARY KEY (id);


--
-- Name: document_version pk_document_version; Type: CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_version
    ADD CONSTRAINT pk_document_version PRIMARY KEY (id);


--
-- Name: document_version_parts uq_document_version_id; Type: CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_version_parts
    ADD CONSTRAINT uq_document_version_id UNIQUE (document_version_id);


--
-- Name: datasource pk_datasource; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.datasource
    ADD CONSTRAINT pk_datasource PRIMARY KEY (datasource_id);


--
-- Name: destination pk_destination; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.destination
    ADD CONSTRAINT pk_destination PRIMARY KEY (destination_id);


--
-- Name: destination_parameter pk_destination_parameter; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.destination_parameter
    ADD CONSTRAINT pk_destination_parameter PRIMARY KEY (id);


--
-- Name: export_format pk_export_format; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.export_format
    ADD CONSTRAINT pk_export_format PRIMARY KEY (id);


--
-- Name: flat_file pk_flat_file; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.flat_file
    ADD CONSTRAINT pk_flat_file PRIMARY KEY (datasource_id);


--
-- Name: generated_report pk_generated_report; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.generated_report
    ADD CONSTRAINT pk_generated_report PRIMARY KEY (correlation_id);


--
-- Name: jdbc pk_jdbc; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.jdbc
    ADD CONSTRAINT pk_jdbc PRIMARY KEY (datasource_id);


--
-- Name: ui-notification pk_notification; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports."ui-notification"
    ADD CONSTRAINT pk_notification PRIMARY KEY (id);


--
-- Name: s3 pk_s3; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.s3
    ADD CONSTRAINT pk_s3 PRIMARY KEY (destination_id);


--
-- Name: selected_destination_parameter pk_selected_destination_parameter; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.selected_destination_parameter
    ADD CONSTRAINT pk_selected_destination_parameter PRIMARY KEY (id);


--
-- Name: sftp pk_sftp; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.sftp
    ADD CONSTRAINT pk_sftp PRIMARY KEY (destination_id);


--
-- Name: smtp pk_smtp; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.smtp
    ADD CONSTRAINT pk_smtp PRIMARY KEY (destination_id);


--
-- Name: stream pk_stream; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.stream
    ADD CONSTRAINT pk_stream PRIMARY KEY (destination_id);


--
-- Name: template pk_template; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.template
    ADD CONSTRAINT pk_template PRIMARY KEY (id);


--
-- Name: template_datasource pk_template_datasource; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.template_datasource
    ADD CONSTRAINT pk_template_datasource PRIMARY KEY (template_id, datasource_id);


--
-- Name: web_endpoint pk_web_endpoint; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.web_endpoint
    ADD CONSTRAINT pk_web_endpoint PRIMARY KEY (destination_id);


--
-- Name: destination un_destination_name; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.destination
    ADD CONSTRAINT un_destination_name UNIQUE (name);


--
-- Name: destination_parameter un_destination_parameter_name; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.destination_parameter
    ADD CONSTRAINT un_destination_parameter_name UNIQUE (destination_id, name);


--
-- Name: datasource un_name; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.datasource
    ADD CONSTRAINT un_name UNIQUE (name);


--
-- Name: template un_template_name; Type: CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.template
    ADD CONSTRAINT un_template_name UNIQUE (name);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: idx_tag; Type: INDEX; Schema: _documents; Owner: postgres
--

CREATE INDEX idx_tag ON _documents.document_tag USING gin (to_tsvector('english'::regconfig, tag));


--
-- Name: idx_tag; Type: INDEX; Schema: _reports; Owner: postgres
--

CREATE INDEX idx_tag ON _reports.template_tag USING gin (to_tsvector('english'::regconfig, tag));


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: document_attribute fk_attribute.id; Type: FK CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_attribute
    ADD CONSTRAINT "fk_attribute.id" FOREIGN KEY (attribute_label) REFERENCES _documents.attribute_label(id) MATCH FULL;


--
-- Name: document_attribute fk_document.id; Type: FK CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_attribute
    ADD CONSTRAINT "fk_document.id" FOREIGN KEY (document_id) REFERENCES _documents.document(id) MATCH FULL;


--
-- Name: document_tag fk_document.id; Type: FK CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_tag
    ADD CONSTRAINT "fk_document.id" FOREIGN KEY (document_id) REFERENCES _documents.document(id) MATCH FULL;


--
-- Name: document_status fk_document.id; Type: FK CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_status
    ADD CONSTRAINT "fk_document.id" FOREIGN KEY (document_id) REFERENCES _documents.document(id) MATCH FULL;


--
-- Name: document_version fk_document.id; Type: FK CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_version
    ADD CONSTRAINT "fk_document.id" FOREIGN KEY (document_id) REFERENCES _documents.document(id) MATCH FULL;


--
-- Name: document_acl fk_document.id; Type: FK CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_acl
    ADD CONSTRAINT "fk_document.id" FOREIGN KEY (document_id) REFERENCES _documents.document(id) MATCH FULL;


--
-- Name: document_version_parts fk_document_version_version.id; Type: FK CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_version_parts
    ADD CONSTRAINT "fk_document_version_version.id" FOREIGN KEY (document_version_id) REFERENCES _documents.document_version(id) MATCH FULL;


--
-- Name: document_group_user fk_usergroup.id; Type: FK CONSTRAINT; Schema: _documents; Owner: postgres
--

ALTER TABLE ONLY _documents.document_group_user
    ADD CONSTRAINT "fk_usergroup.id" FOREIGN KEY (group_uuid) REFERENCES _documents.document_group(id) MATCH FULL;


--
-- Name: jdbc fk_datasource.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.jdbc
    ADD CONSTRAINT "fk_datasource.id" FOREIGN KEY (datasource_id) REFERENCES _reports.datasource(datasource_id) MATCH FULL;


--
-- Name: flat_file fk_datasource.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.flat_file
    ADD CONSTRAINT "fk_datasource.id" FOREIGN KEY (datasource_id) REFERENCES _reports.datasource(datasource_id) MATCH FULL;


--
-- Name: template_datasource fk_datasource.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.template_datasource
    ADD CONSTRAINT "fk_datasource.id" FOREIGN KEY (datasource_id) REFERENCES _reports.datasource(datasource_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: destination_parameter fk_destination; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.destination_parameter
    ADD CONSTRAINT fk_destination FOREIGN KEY (destination_id) REFERENCES _reports.destination(destination_id) MATCH FULL;


--
-- Name: smtp fk_destination.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.smtp
    ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id) REFERENCES _reports.destination(destination_id) MATCH FULL;


--
-- Name: sftp fk_destination.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.sftp
    ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id) REFERENCES _reports.destination(destination_id) MATCH FULL;


--
-- Name: web_endpoint fk_destination.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.web_endpoint
    ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id) REFERENCES _reports.destination(destination_id) MATCH FULL;


--
-- Name: stream fk_destination.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.stream
    ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id) REFERENCES _reports.destination(destination_id) MATCH FULL;


--
-- Name: s3 fk_destination.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.s3
    ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id) REFERENCES _reports.destination(destination_id) MATCH FULL;


--
-- Name: generated_report fk_destination.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.generated_report
    ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id) REFERENCES _reports.destination(destination_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: selected_destination_parameter fk_destination_parameter.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.selected_destination_parameter
    ADD CONSTRAINT "fk_destination_parameter.id" FOREIGN KEY (destination_parameter_id) REFERENCES _reports.destination_parameter(id) MATCH FULL;


--
-- Name: generated_report fk_export_format.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.generated_report
    ADD CONSTRAINT "fk_export_format.id" FOREIGN KEY (export_format_id) REFERENCES _reports.export_format(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: selected_destination_parameter fk_generated_report.correlation_id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.selected_destination_parameter
    ADD CONSTRAINT "fk_generated_report.correlation_id" FOREIGN KEY (correlation_id) REFERENCES _reports.generated_report(correlation_id) MATCH FULL;


--
-- Name: template_tag fk_template.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.template_tag
    ADD CONSTRAINT "fk_template.id" FOREIGN KEY (template_id) REFERENCES _reports.template(id) MATCH FULL;


--
-- Name: template_datasource fk_template.id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.template_datasource
    ADD CONSTRAINT "fk_template.id" FOREIGN KEY (template_id) REFERENCES _reports.template(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: generated_report fk_template_id; Type: FK CONSTRAINT; Schema: _reports; Owner: postgres
--

ALTER TABLE ONLY _reports.generated_report
    ADD CONSTRAINT fk_template_id FOREIGN KEY (template_id) REFERENCES _reports.template(id) MATCH FULL;


--
-- PostgreSQL database dump complete
--

