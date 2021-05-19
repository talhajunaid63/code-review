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
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: diagnoses_full_text_function(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diagnoses_full_text_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      begin
        new.tsv_body :=
           to_tsvector('pg_catalog.simple', coalesce(new.diag_description, ''));
        return new;
      end
      $$;


--
-- Name: users_full_text_function(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.users_full_text_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      begin
        new.tsv_body :=
           to_tsvector('pg_catalog.simple', coalesce(new.first_name,'')) ||
           to_tsvector('pg_catalog.simple', coalesce(new.last_name,'')) ||
           to_tsvector('pg_catalog.simple', coalesce(new.email,'')) ||
           to_tsvector('pg_catalog.simple', coalesce(new.phone,'')) ||
           to_tsvector('pg_catalog.simple', coalesce(new.date_of_birth,'')) ||
           to_tsvector('pg_catalog.simple', coalesce(new.zip,''));
        return new;
      end
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actions (
    id integer NOT NULL,
    event character varying,
    user_id integer,
    actionable_type character varying,
    actionable_id integer,
    metadata character varying,
    os_name character varying,
    os_version character varying,
    browser_name character varying,
    browser_version character varying,
    ip_address character varying,
    referrer character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.actions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.actions_id_seq OWNED BY public.actions.id;


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcements (
    id integer NOT NULL,
    content text,
    active boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.announcements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: authentications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authentications (
    id integer NOT NULL,
    token character varying,
    token_expired_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    login_handler character varying
);


--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authentications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authentications_id_seq OWNED BY public.authentications.id;


--
-- Name: available_times; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.available_times (
    id integer NOT NULL,
    weekly_schedule_rules text,
    user_id integer,
    time_block integer,
    day integer
);


--
-- Name: available_times_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.available_times_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: available_times_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.available_times_id_seq OWNED BY public.available_times.id;


--
-- Name: basic_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.basic_details (
    id integer NOT NULL,
    gender integer,
    patient_id integer,
    dependent_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    address character varying,
    city character varying,
    state character varying,
    conditions text,
    client_unique_id character varying,
    imported boolean DEFAULT false,
    employer_email character varying,
    pre_test_id integer
);


--
-- Name: basic_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.basic_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basic_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.basic_details_id_seq OWNED BY public.basic_details.id;


--
-- Name: conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conditions (
    id integer NOT NULL,
    name character varying,
    patient_id integer,
    dependent_id integer,
    notes text,
    is_current boolean,
    visit_id integer
);


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conditions_id_seq OWNED BY public.conditions.id;


--
-- Name: coordinator_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coordinator_details (
    id integer NOT NULL,
    role character varying,
    zip integer,
    coordinator_id integer,
    specialties character varying,
    imported boolean DEFAULT false,
    acts_as_org_admin boolean DEFAULT false
);


--
-- Name: coordinator_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.coordinator_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coordinator_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.coordinator_details_id_seq OWNED BY public.coordinator_details.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    name character varying,
    code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: cpts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cpts (
    id integer NOT NULL,
    cpt_record_id character varying,
    cpt_code character varying,
    lookup_field character varying,
    cpt_description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cpts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cpts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cpts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cpts_id_seq OWNED BY public.cpts.id;


--
-- Name: demo_visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demo_visits (
    id integer NOT NULL,
    tok_session_id character varying,
    tok_token character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: demo_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.demo_visits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demo_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.demo_visits_id_seq OWNED BY public.demo_visits.id;


--
-- Name: dependents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dependents (
    id integer NOT NULL,
    patient_id integer
);


--
-- Name: dependents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dependents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dependents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dependents_id_seq OWNED BY public.dependents.id;


--
-- Name: diagnoses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diagnoses (
    id integer NOT NULL,
    hcc_diag_record_id bigint,
    diagnosis_code character varying,
    diag_description character varying,
    lookup_field character varying,
    esrd_v21 character varying,
    cms_hcc_v22 character varying,
    cms_hcc_v24 character varying,
    rxhcc_v05 character varying,
    esrd_py2020 character varying,
    cms_hcc_v22_py2020 character varying,
    cms_hcc_v24_py2020 character varying,
    rxhcc_py2020 character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tsv_body tsvector
);


--
-- Name: diagnoses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.diagnoses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diagnoses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.diagnoses_id_seq OWNED BY public.diagnoses.id;


--
-- Name: identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identities (
    id integer NOT NULL,
    user_id integer,
    organization_id bigint,
    provider character varying,
    uid character varying,
    email character varying,
    name character varying,
    token character varying,
    refresh_token character varying,
    expires_at integer,
    expires boolean,
    profile_url character varying,
    image_url character varying,
    secret character varying,
    created_at timestamp without time zone
);


--
-- Name: identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.identities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.identities_id_seq OWNED BY public.identities.id;


--
-- Name: incident_informations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incident_informations (
    id integer NOT NULL,
    visit_id integer,
    patient_id integer,
    incident_description character varying,
    activity_performed character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nova_incident_info character varying,
    date_y character varying,
    date_m character varying,
    date_d character varying
);


--
-- Name: incident_informations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incident_informations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incident_informations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incident_informations_id_seq OWNED BY public.incident_informations.id;


--
-- Name: insurance_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.insurance_details (
    id integer NOT NULL,
    provider character varying,
    member_id character varying,
    group_id character varying,
    user_id integer,
    no_insurance boolean
);


--
-- Name: insurance_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.insurance_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: insurance_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.insurance_details_id_seq OWNED BY public.insurance_details.id;


--
-- Name: medications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medications (
    id integer NOT NULL,
    name character varying,
    how_long character varying,
    patient_id integer,
    dependent_id integer,
    visit_id integer
);


--
-- Name: medications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.medications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: medications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.medications_id_seq OWNED BY public.medications.id;


--
-- Name: metadata_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metadata_settings (
    id integer NOT NULL,
    organization_id integer,
    address boolean DEFAULT true,
    medications boolean DEFAULT true,
    conditions boolean DEFAULT true,
    visit_notes boolean DEFAULT true,
    dob boolean DEFAULT true,
    gender boolean DEFAULT true,
    reference_number boolean DEFAULT true NOT NULL,
    incident_information boolean DEFAULT false
);


--
-- Name: metadata_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.metadata_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metadata_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.metadata_settings_id_seq OWNED BY public.metadata_settings.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    visit_id integer,
    user_id integer,
    status character varying DEFAULT 'pending'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: online_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.online_users (
    id integer NOT NULL,
    user_id integer,
    online boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: online_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.online_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: online_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.online_users_id_seq OWNED BY public.online_users.id;


--
-- Name: org_admin_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.org_admin_details (
    id integer NOT NULL,
    org_admin_id integer,
    name character varying
);


--
-- Name: org_admin_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.org_admin_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_admin_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.org_admin_details_id_seq OWNED BY public.org_admin_details.id;


--
-- Name: org_setups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.org_setups (
    id integer NOT NULL,
    step integer DEFAULT 1,
    org_admin_id integer,
    organization_id integer,
    plan_id integer
);


--
-- Name: org_setups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.org_setups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_setups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.org_setups_id_seq OWNED BY public.org_setups.id;


--
-- Name: organization_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_features (
    id integer NOT NULL,
    name character varying NOT NULL,
    key character varying NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organization_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_features_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_features_id_seq OWNED BY public.organization_features.id;


--
-- Name: organization_included_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_included_features (
    id integer NOT NULL,
    organization_plan_id integer,
    organization_feature_id integer
);


--
-- Name: organization_included_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_included_features_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_included_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_included_features_id_seq OWNED BY public.organization_included_features.id;


--
-- Name: organization_payouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_payouts (
    id integer NOT NULL,
    organization_id integer,
    status integer DEFAULT 0 NOT NULL,
    amount numeric(8,2),
    visit_ids text[] DEFAULT '{}'::text[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    stripe_account_id character varying,
    stripe_account_email character varying
);


--
-- Name: organization_payouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_payouts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_payouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_payouts_id_seq OWNED BY public.organization_payouts.id;


--
-- Name: organization_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_plans (
    id integer NOT NULL,
    name character varying NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    display_order integer,
    "interval" integer,
    price numeric,
    stripe_id character varying,
    by_quote boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    featured boolean DEFAULT false NOT NULL,
    special boolean DEFAULT false
);


--
-- Name: organization_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_plans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_plans_id_seq OWNED BY public.organization_plans.id;


--
-- Name: organization_reminder_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_reminder_settings (
    id integer NOT NULL,
    organization_id integer,
    patient_send_at character varying,
    patient_subject character varying,
    patient_content character varying,
    provider_send_at character varying,
    provider_subject character varying,
    provider_content character varying,
    send_via integer NOT NULL,
    created_at timestamp without time zone,
    udpated_at timestamp without time zone
);


--
-- Name: organization_reminder_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_reminder_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_reminder_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_reminder_settings_id_seq OWNED BY public.organization_reminder_settings.id;


--
-- Name: organization_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_states (
    id integer NOT NULL,
    organization_id integer,
    state_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_primary boolean DEFAULT false
);


--
-- Name: organization_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_states_id_seq OWNED BY public.organization_states.id;


--
-- Name: organization_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_stats (
    id integer NOT NULL,
    paid_users_count integer,
    visits_count integer,
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organization_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_stats_id_seq OWNED BY public.organization_stats.id;


--
-- Name: organization_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_subscriptions (
    id integer NOT NULL,
    organization_plan_id integer,
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    stripe_id character varying,
    current_period_end timestamp without time zone,
    stripe_subscription_item_id character varying,
    stripe_recording_subscription_item_id character varying
);


--
-- Name: organization_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_subscriptions_id_seq OWNED BY public.organization_subscriptions.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name character varying,
    description text,
    landing_page text,
    slug character varying,
    zip character varying,
    address character varying,
    phone character varying,
    hero_file_name character varying,
    hero_content_type character varying,
    hero_file_size integer,
    hero_updated_at timestamp without time zone,
    logo_file_name character varying,
    logo_content_type character varying,
    logo_file_size integer,
    logo_updated_at timestamp without time zone,
    brand_color character varying,
    enable_recording boolean DEFAULT false,
    stripe_id character varying,
    payout_stripe_id character varying,
    api_token character varying,
    enable_patient_screen_sharing boolean DEFAULT true,
    enable_chat boolean DEFAULT false,
    tier character varying,
    left_footer_title character varying,
    right_footer_title character varying,
    left_footer_description text,
    right_footer_description text,
    left_footer_image_file_name character varying,
    left_footer_image_content_type character varying,
    left_footer_image_file_size integer,
    left_footer_image_updated_at timestamp without time zone,
    right_footer_image_file_name character varying,
    right_footer_image_content_type character varying,
    right_footer_image_file_size integer,
    right_footer_image_updated_at timestamp without time zone,
    intercom_id character varying,
    creator_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    bucket_name character varying
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_methods (
    id integer NOT NULL,
    stripe_card_id character varying,
    last_4 integer,
    brand text,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    exp_m integer,
    exp_y integer
);


--
-- Name: payment_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_methods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_methods_id_seq OWNED BY public.payment_methods.id;


--
-- Name: pre_test_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pre_test_details (
    id bigint NOT NULL,
    user_id bigint,
    attempted_at timestamp without time zone,
    content jsonb,
    visit_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    codecs character varying[] DEFAULT '{}'::character varying[],
    user_agent character varying DEFAULT ''::character varying
);


--
-- Name: pre_test_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pre_test_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pre_test_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pre_test_details_id_seq OWNED BY public.pre_test_details.id;


--
-- Name: provider_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_details (
    id integer NOT NULL,
    about text,
    qualifications text,
    specialties text,
    city character varying,
    state character varying,
    provider_id integer,
    zip integer,
    role character varying,
    acts_as_org_admin boolean DEFAULT false,
    imported boolean DEFAULT false
);


--
-- Name: provider_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.provider_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: provider_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.provider_details_id_seq OWNED BY public.provider_details.id;


--
-- Name: provider_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_states (
    id integer NOT NULL,
    provider_id integer,
    state_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_primary boolean DEFAULT false
);


--
-- Name: provider_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.provider_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: provider_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.provider_states_id_seq OWNED BY public.provider_states.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.states (
    id integer NOT NULL,
    name character varying,
    code character varying,
    country_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.states_id_seq OWNED BY public.states.id;


--
-- Name: updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.updates (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone NOT NULL,
    udpated_at timestamp without time zone,
    invoice character varying,
    content text,
    summary character varying,
    updated_at timestamp without time zone NOT NULL,
    invoice_number integer
);


--
-- Name: updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.updates_id_seq OWNED BY public.updates.id;


--
-- Name: user_import_failures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_import_failures (
    id integer NOT NULL,
    reason character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    csv_row json DEFAULT '{}'::json,
    user_import_id integer
);


--
-- Name: user_import_failures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_import_failures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_import_failures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_import_failures_id_seq OWNED BY public.user_import_failures.id;


--
-- Name: user_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_imports (
    id integer NOT NULL,
    file_name character varying,
    file_size integer,
    updated integer DEFAULT 0,
    created integer DEFAULT 0,
    failed integer DEFAULT 0,
    job_id character varying,
    import_type character varying,
    user_id integer,
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    total integer DEFAULT 0,
    processed integer DEFAULT 0,
    status character varying DEFAULT 'pending'::character varying,
    headers character varying[] DEFAULT '{}'::character varying[],
    error character varying
);


--
-- Name: user_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_imports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_imports_id_seq OWNED BY public.user_imports.id;


--
-- Name: user_visit_consents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_visit_consents (
    id integer NOT NULL,
    user_id integer,
    visit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_visit_consents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_visit_consents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_visit_consents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_visit_consents_id_seq OWNED BY public.user_visit_consents.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    type character varying,
    source character varying,
    terms boolean,
    zip character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    avatar_file_name character varying,
    avatar_content_type character varying,
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    stripe_id character varying,
    last_seen timestamp without time zone,
    authentication_token character varying(30),
    status integer,
    organization_id integer,
    reference_number character varying,
    coordinator_id integer,
    archived_at timestamp without time zone,
    time_zone character varying,
    imported boolean DEFAULT false,
    notifications_count integer DEFAULT 0,
    first_name character varying,
    last_name character varying,
    visit_sms_sent_at timestamp without time zone,
    tsv_body tsvector,
    email character varying,
    phone character varying,
    date_of_birth character varying,
    last_activity_at timestamp without time zone,
    intercom_id character varying,
    notifications_enabled boolean DEFAULT true,
    category character varying DEFAULT 'regular'::character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
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
-- Name: users_visit_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_visit_types (
    visit_type_id integer,
    user_id integer
);


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id bigint NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone,
    object_changes text
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: video_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.video_logs (
    id integer NOT NULL,
    visit_id integer,
    user_id integer,
    content jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: video_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.video_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: video_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.video_logs_id_seq OWNED BY public.video_logs.id;


--
-- Name: visit_attendances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visit_attendances (
    id integer NOT NULL,
    visit_id integer,
    user_id integer,
    attending boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    codecs character varying[] DEFAULT '{}'::character varying[]
);


--
-- Name: visit_attendances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visit_attendances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visit_attendances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visit_attendances_id_seq OWNED BY public.visit_attendances.id;


--
-- Name: visit_coordinators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visit_coordinators (
    id integer NOT NULL,
    coordinator_id integer,
    visit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: visit_coordinators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visit_coordinators_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visit_coordinators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visit_coordinators_id_seq OWNED BY public.visit_coordinators.id;


--
-- Name: visit_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visit_details (
    id integer NOT NULL,
    visit_id integer,
    provider_id integer,
    diagnosis_id integer,
    cpt_id integer,
    assessment character varying,
    status character varying,
    plan character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    patient_id integer,
    patient_history text
);


--
-- Name: visit_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visit_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visit_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visit_details_id_seq OWNED BY public.visit_details.id;


--
-- Name: visit_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visit_providers (
    id integer NOT NULL,
    provider_id integer,
    visit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: visit_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visit_providers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visit_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visit_providers_id_seq OWNED BY public.visit_providers.id;


--
-- Name: visit_recordings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visit_recordings (
    id integer NOT NULL,
    organization_id integer,
    visit_id integer,
    recorded_at timestamp without time zone,
    duration bigint,
    tok_id character varying,
    tok_session_id character varying,
    size bigint,
    url character varying,
    created_at timestamp without time zone,
    expired_at timestamp without time zone,
    downloaded_at timestamp without time zone
);


--
-- Name: visit_recordings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visit_recordings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visit_recordings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visit_recordings_id_seq OWNED BY public.visit_recordings.id;


--
-- Name: visit_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visit_settings (
    id integer NOT NULL,
    organization_id integer,
    visit_rate integer DEFAULT 35,
    visit_length integer DEFAULT 10,
    visit_buffer integer DEFAULT 5,
    require_payment boolean DEFAULT false,
    schedule_preference integer DEFAULT 1 NOT NULL,
    self_service_enabled boolean DEFAULT false,
    auth_number_required boolean DEFAULT false NOT NULL,
    mandatory_diagnoses boolean DEFAULT false,
    mandatory_patient_history boolean DEFAULT false,
    mandatory_patient_status boolean DEFAULT false,
    mandatory_plan boolean DEFAULT false,
    waiting_image_file_name character varying,
    waiting_image_content_type character varying,
    waiting_image_file_size integer,
    waiting_image_updated_at timestamp without time zone,
    waiting_video_file_name character varying,
    waiting_video_content_type character varying,
    waiting_video_file_size integer,
    waiting_video_updated_at timestamp without time zone
);


--
-- Name: visit_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visit_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visit_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visit_settings_id_seq OWNED BY public.visit_settings.id;


--
-- Name: visit_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visit_types (
    id integer NOT NULL,
    name character varying,
    "desc" text,
    html text,
    default_length integer,
    rate_per_session integer
);


--
-- Name: visit_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visit_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visit_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visit_types_id_seq OWNED BY public.visit_types.id;


--
-- Name: visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visits (
    id integer NOT NULL,
    patient_id integer,
    dependent_id integer,
    provider_ids integer[] DEFAULT '{}'::integer[],
    schedule timestamp without time zone,
    status integer,
    patient_notes text,
    provider_notes text,
    start_date_time timestamp without time zone,
    end_date_time timestamp without time zone,
    step integer,
    stripe_invoice character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    internal_notes text,
    organization_id integer,
    online_users text,
    auth_number character varying,
    tok_session_id character varying,
    patient_email_reminder_queued_at timestamp without time zone,
    provider_email_reminder_queued_at timestamp without time zone,
    patient_sms_reminder_queued_at timestamp without time zone,
    provider_sms_reminder_queued_at timestamp without time zone,
    coordinator_ids integer[] DEFAULT '{}'::integer[],
    client_unique_id character varying,
    phone_confirmed boolean DEFAULT false,
    patient_sms_sent_at timestamp without time zone,
    patient_on_boarding_at timestamp without time zone,
    codec character varying DEFAULT 'no_codec'::character varying,
    notifications_scheduled boolean DEFAULT false,
    schedule_end timestamp without time zone,
    patient_available_at timestamp without time zone,
    state character varying(32) DEFAULT 'active'::character varying NOT NULL,
    type character varying(32),
    category character varying DEFAULT 'regular'::character varying,
    category_status character varying DEFAULT 'pending'::character varying
);


--
-- Name: visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visits_id_seq OWNED BY public.visits.id;


--
-- Name: web_rtc_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_rtc_details (
    id integer NOT NULL,
    ice_servers text,
    config text,
    status integer,
    visit_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: web_rtc_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.web_rtc_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_rtc_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.web_rtc_details_id_seq OWNED BY public.web_rtc_details.id;


--
-- Name: zip_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zip_codes (
    id bigint NOT NULL,
    code character varying DEFAULT ''::character varying NOT NULL,
    state_name character varying,
    state_code character varying DEFAULT ''::character varying NOT NULL,
    city character varying,
    time_zone character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: zip_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.zip_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zip_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.zip_codes_id_seq OWNED BY public.zip_codes.id;


--
-- Name: actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions ALTER COLUMN id SET DEFAULT nextval('public.actions_id_seq'::regclass);


--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: authentications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentications ALTER COLUMN id SET DEFAULT nextval('public.authentications_id_seq'::regclass);


--
-- Name: available_times id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.available_times ALTER COLUMN id SET DEFAULT nextval('public.available_times_id_seq'::regclass);


--
-- Name: basic_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.basic_details ALTER COLUMN id SET DEFAULT nextval('public.basic_details_id_seq'::regclass);


--
-- Name: conditions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions ALTER COLUMN id SET DEFAULT nextval('public.conditions_id_seq'::regclass);


--
-- Name: coordinator_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coordinator_details ALTER COLUMN id SET DEFAULT nextval('public.coordinator_details_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: cpts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cpts ALTER COLUMN id SET DEFAULT nextval('public.cpts_id_seq'::regclass);


--
-- Name: demo_visits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demo_visits ALTER COLUMN id SET DEFAULT nextval('public.demo_visits_id_seq'::regclass);


--
-- Name: dependents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependents ALTER COLUMN id SET DEFAULT nextval('public.dependents_id_seq'::regclass);


--
-- Name: diagnoses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnoses ALTER COLUMN id SET DEFAULT nextval('public.diagnoses_id_seq'::regclass);


--
-- Name: identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities ALTER COLUMN id SET DEFAULT nextval('public.identities_id_seq'::regclass);


--
-- Name: incident_informations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incident_informations ALTER COLUMN id SET DEFAULT nextval('public.incident_informations_id_seq'::regclass);


--
-- Name: insurance_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insurance_details ALTER COLUMN id SET DEFAULT nextval('public.insurance_details_id_seq'::regclass);


--
-- Name: medications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medications ALTER COLUMN id SET DEFAULT nextval('public.medications_id_seq'::regclass);


--
-- Name: metadata_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metadata_settings ALTER COLUMN id SET DEFAULT nextval('public.metadata_settings_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: online_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_users ALTER COLUMN id SET DEFAULT nextval('public.online_users_id_seq'::regclass);


--
-- Name: org_admin_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_admin_details ALTER COLUMN id SET DEFAULT nextval('public.org_admin_details_id_seq'::regclass);


--
-- Name: org_setups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_setups ALTER COLUMN id SET DEFAULT nextval('public.org_setups_id_seq'::regclass);


--
-- Name: organization_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_features ALTER COLUMN id SET DEFAULT nextval('public.organization_features_id_seq'::regclass);


--
-- Name: organization_included_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_included_features ALTER COLUMN id SET DEFAULT nextval('public.organization_included_features_id_seq'::regclass);


--
-- Name: organization_payouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_payouts ALTER COLUMN id SET DEFAULT nextval('public.organization_payouts_id_seq'::regclass);


--
-- Name: organization_plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_plans ALTER COLUMN id SET DEFAULT nextval('public.organization_plans_id_seq'::regclass);


--
-- Name: organization_reminder_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_reminder_settings ALTER COLUMN id SET DEFAULT nextval('public.organization_reminder_settings_id_seq'::regclass);


--
-- Name: organization_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_states ALTER COLUMN id SET DEFAULT nextval('public.organization_states_id_seq'::regclass);


--
-- Name: organization_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_stats ALTER COLUMN id SET DEFAULT nextval('public.organization_stats_id_seq'::regclass);


--
-- Name: organization_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.organization_subscriptions_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: payment_methods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods ALTER COLUMN id SET DEFAULT nextval('public.payment_methods_id_seq'::regclass);


--
-- Name: pre_test_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_test_details ALTER COLUMN id SET DEFAULT nextval('public.pre_test_details_id_seq'::regclass);


--
-- Name: provider_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_details ALTER COLUMN id SET DEFAULT nextval('public.provider_details_id_seq'::regclass);


--
-- Name: provider_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_states ALTER COLUMN id SET DEFAULT nextval('public.provider_states_id_seq'::regclass);


--
-- Name: states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states ALTER COLUMN id SET DEFAULT nextval('public.states_id_seq'::regclass);


--
-- Name: updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.updates ALTER COLUMN id SET DEFAULT nextval('public.updates_id_seq'::regclass);


--
-- Name: user_import_failures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_import_failures ALTER COLUMN id SET DEFAULT nextval('public.user_import_failures_id_seq'::regclass);


--
-- Name: user_imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_imports ALTER COLUMN id SET DEFAULT nextval('public.user_imports_id_seq'::regclass);


--
-- Name: user_visit_consents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_visit_consents ALTER COLUMN id SET DEFAULT nextval('public.user_visit_consents_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: video_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video_logs ALTER COLUMN id SET DEFAULT nextval('public.video_logs_id_seq'::regclass);


--
-- Name: visit_attendances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_attendances ALTER COLUMN id SET DEFAULT nextval('public.visit_attendances_id_seq'::regclass);


--
-- Name: visit_coordinators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_coordinators ALTER COLUMN id SET DEFAULT nextval('public.visit_coordinators_id_seq'::regclass);


--
-- Name: visit_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_details ALTER COLUMN id SET DEFAULT nextval('public.visit_details_id_seq'::regclass);


--
-- Name: visit_providers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_providers ALTER COLUMN id SET DEFAULT nextval('public.visit_providers_id_seq'::regclass);


--
-- Name: visit_recordings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_recordings ALTER COLUMN id SET DEFAULT nextval('public.visit_recordings_id_seq'::regclass);


--
-- Name: visit_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_settings ALTER COLUMN id SET DEFAULT nextval('public.visit_settings_id_seq'::regclass);


--
-- Name: visit_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_types ALTER COLUMN id SET DEFAULT nextval('public.visit_types_id_seq'::regclass);


--
-- Name: visits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visits ALTER COLUMN id SET DEFAULT nextval('public.visits_id_seq'::regclass);


--
-- Name: web_rtc_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_rtc_details ALTER COLUMN id SET DEFAULT nextval('public.web_rtc_details_id_seq'::regclass);


--
-- Name: zip_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zip_codes ALTER COLUMN id SET DEFAULT nextval('public.zip_codes_id_seq'::regclass);


--
-- Name: actions actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: authentications authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: available_times available_times_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.available_times
    ADD CONSTRAINT available_times_pkey PRIMARY KEY (id);


--
-- Name: basic_details basic_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.basic_details
    ADD CONSTRAINT basic_details_pkey PRIMARY KEY (id);


--
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: coordinator_details coordinator_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coordinator_details
    ADD CONSTRAINT coordinator_details_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: cpts cpts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cpts
    ADD CONSTRAINT cpts_pkey PRIMARY KEY (id);


--
-- Name: demo_visits demo_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demo_visits
    ADD CONSTRAINT demo_visits_pkey PRIMARY KEY (id);


--
-- Name: dependents dependents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependents
    ADD CONSTRAINT dependents_pkey PRIMARY KEY (id);


--
-- Name: diagnoses diagnoses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnoses
    ADD CONSTRAINT diagnoses_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: incident_informations incident_informations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incident_informations
    ADD CONSTRAINT incident_informations_pkey PRIMARY KEY (id);


--
-- Name: insurance_details insurance_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insurance_details
    ADD CONSTRAINT insurance_details_pkey PRIMARY KEY (id);


--
-- Name: medications medications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medications
    ADD CONSTRAINT medications_pkey PRIMARY KEY (id);


--
-- Name: metadata_settings metadata_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metadata_settings
    ADD CONSTRAINT metadata_settings_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: online_users online_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_users
    ADD CONSTRAINT online_users_pkey PRIMARY KEY (id);


--
-- Name: org_admin_details org_admin_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_admin_details
    ADD CONSTRAINT org_admin_details_pkey PRIMARY KEY (id);


--
-- Name: org_setups org_setups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_setups
    ADD CONSTRAINT org_setups_pkey PRIMARY KEY (id);


--
-- Name: organization_features organization_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_features
    ADD CONSTRAINT organization_features_pkey PRIMARY KEY (id);


--
-- Name: organization_included_features organization_included_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_included_features
    ADD CONSTRAINT organization_included_features_pkey PRIMARY KEY (id);


--
-- Name: organization_payouts organization_payouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_payouts
    ADD CONSTRAINT organization_payouts_pkey PRIMARY KEY (id);


--
-- Name: organization_plans organization_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_plans
    ADD CONSTRAINT organization_plans_pkey PRIMARY KEY (id);


--
-- Name: organization_reminder_settings organization_reminder_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_reminder_settings
    ADD CONSTRAINT organization_reminder_settings_pkey PRIMARY KEY (id);


--
-- Name: organization_states organization_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_states
    ADD CONSTRAINT organization_states_pkey PRIMARY KEY (id);


--
-- Name: organization_stats organization_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_stats
    ADD CONSTRAINT organization_stats_pkey PRIMARY KEY (id);


--
-- Name: organization_subscriptions organization_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_subscriptions
    ADD CONSTRAINT organization_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);


--
-- Name: pre_test_details pre_test_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_test_details
    ADD CONSTRAINT pre_test_details_pkey PRIMARY KEY (id);


--
-- Name: provider_details provider_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_details
    ADD CONSTRAINT provider_details_pkey PRIMARY KEY (id);


--
-- Name: provider_states provider_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_states
    ADD CONSTRAINT provider_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: updates updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.updates
    ADD CONSTRAINT updates_pkey PRIMARY KEY (id);


--
-- Name: user_import_failures user_import_failures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_import_failures
    ADD CONSTRAINT user_import_failures_pkey PRIMARY KEY (id);


--
-- Name: user_imports user_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_imports
    ADD CONSTRAINT user_imports_pkey PRIMARY KEY (id);


--
-- Name: user_visit_consents user_visit_consents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_visit_consents
    ADD CONSTRAINT user_visit_consents_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: video_logs video_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video_logs
    ADD CONSTRAINT video_logs_pkey PRIMARY KEY (id);


--
-- Name: visit_attendances visit_attendances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_attendances
    ADD CONSTRAINT visit_attendances_pkey PRIMARY KEY (id);


--
-- Name: visit_coordinators visit_coordinators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_coordinators
    ADD CONSTRAINT visit_coordinators_pkey PRIMARY KEY (id);


--
-- Name: visit_details visit_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_details
    ADD CONSTRAINT visit_details_pkey PRIMARY KEY (id);


--
-- Name: visit_providers visit_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_providers
    ADD CONSTRAINT visit_providers_pkey PRIMARY KEY (id);


--
-- Name: visit_recordings visit_recordings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_recordings
    ADD CONSTRAINT visit_recordings_pkey PRIMARY KEY (id);


--
-- Name: visit_settings visit_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_settings
    ADD CONSTRAINT visit_settings_pkey PRIMARY KEY (id);


--
-- Name: visit_types visit_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_types
    ADD CONSTRAINT visit_types_pkey PRIMARY KEY (id);


--
-- Name: visits visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (id);


--
-- Name: web_rtc_details web_rtc_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_rtc_details
    ADD CONSTRAINT web_rtc_details_pkey PRIMARY KEY (id);


--
-- Name: zip_codes zip_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zip_codes
    ADD CONSTRAINT zip_codes_pkey PRIMARY KEY (id);


--
-- Name: index_actions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_actions_on_user_id ON public.actions USING btree (user_id);


--
-- Name: index_authentications_on_login_handler; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_authentications_on_login_handler ON public.authentications USING btree (login_handler);


--
-- Name: index_available_times_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_available_times_on_user_id ON public.available_times USING btree (user_id);


--
-- Name: index_basic_details_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_basic_details_on_patient_id ON public.basic_details USING btree (patient_id);


--
-- Name: index_conditions_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conditions_on_patient_id ON public.conditions USING btree (patient_id);


--
-- Name: index_conditions_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conditions_on_visit_id ON public.conditions USING btree (visit_id);


--
-- Name: index_coordinator_details_on_coordinator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_coordinator_details_on_coordinator_id ON public.coordinator_details USING btree (coordinator_id);


--
-- Name: index_diagnoses_on_tsv_body; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_diagnoses_on_tsv_body ON public.diagnoses USING gin (tsv_body);


--
-- Name: index_identities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identities_on_user_id ON public.identities USING btree (user_id);


--
-- Name: index_incident_informations_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incident_informations_on_patient_id ON public.incident_informations USING btree (patient_id);


--
-- Name: index_incident_informations_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incident_informations_on_visit_id ON public.incident_informations USING btree (visit_id);


--
-- Name: index_insurance_details_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_insurance_details_on_user_id ON public.insurance_details USING btree (user_id);


--
-- Name: index_medications_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_medications_on_patient_id ON public.medications USING btree (patient_id);


--
-- Name: index_medications_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_medications_on_visit_id ON public.medications USING btree (visit_id);


--
-- Name: index_metadata_settings_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_metadata_settings_on_organization_id ON public.metadata_settings USING btree (organization_id);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_user_id ON public.notifications USING btree (user_id);


--
-- Name: index_notifications_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_visit_id ON public.notifications USING btree (visit_id);


--
-- Name: index_online_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_users_on_user_id ON public.online_users USING btree (user_id);


--
-- Name: index_org_admin_details_on_org_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_org_admin_details_on_org_admin_id ON public.org_admin_details USING btree (org_admin_id);


--
-- Name: index_org_setups_on_org_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_org_setups_on_org_admin_id ON public.org_setups USING btree (org_admin_id);


--
-- Name: index_org_setups_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_org_setups_on_organization_id ON public.org_setups USING btree (organization_id);


--
-- Name: index_organization_included_features_on_organization_feature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_included_features_on_organization_feature_id ON public.organization_included_features USING btree (organization_feature_id);


--
-- Name: index_organization_included_features_on_organization_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_included_features_on_organization_plan_id ON public.organization_included_features USING btree (organization_plan_id);


--
-- Name: index_organization_payouts_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_payouts_on_organization_id ON public.organization_payouts USING btree (organization_id);


--
-- Name: index_organization_reminder_settings_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_reminder_settings_on_organization_id ON public.organization_reminder_settings USING btree (organization_id);


--
-- Name: index_organization_states_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_states_on_organization_id ON public.organization_states USING btree (organization_id);


--
-- Name: index_organization_states_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_states_on_state_id ON public.organization_states USING btree (state_id);


--
-- Name: index_organization_stats_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_stats_on_organization_id ON public.organization_stats USING btree (organization_id);


--
-- Name: index_organization_subscriptions_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_subscriptions_on_organization_id ON public.organization_subscriptions USING btree (organization_id);


--
-- Name: index_organization_subscriptions_on_organization_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_subscriptions_on_organization_plan_id ON public.organization_subscriptions USING btree (organization_plan_id);


--
-- Name: index_organizations_on_api_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_api_token ON public.organizations USING btree (api_token);


--
-- Name: index_organizations_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_creator_id ON public.organizations USING btree (creator_id);


--
-- Name: index_payment_methods_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_methods_on_user_id ON public.payment_methods USING btree (user_id);


--
-- Name: index_pre_test_details_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pre_test_details_on_user_id ON public.pre_test_details USING btree (user_id);


--
-- Name: index_pre_test_details_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pre_test_details_on_visit_id ON public.pre_test_details USING btree (visit_id);


--
-- Name: index_provider_details_on_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_provider_details_on_provider_id ON public.provider_details USING btree (provider_id);


--
-- Name: index_provider_states_on_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_provider_states_on_provider_id ON public.provider_states USING btree (provider_id);


--
-- Name: index_provider_states_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_provider_states_on_state_id ON public.provider_states USING btree (state_id);


--
-- Name: index_states_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_states_on_country_id ON public.states USING btree (country_id);


--
-- Name: index_user_import_failures_on_user_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_import_failures_on_user_import_id ON public.user_import_failures USING btree (user_import_id);


--
-- Name: index_user_imports_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_imports_on_organization_id ON public.user_imports USING btree (organization_id);


--
-- Name: index_user_imports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_imports_on_user_id ON public.user_imports USING btree (user_id);


--
-- Name: index_user_visit_consents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_visit_consents_on_user_id ON public.user_visit_consents USING btree (user_id);


--
-- Name: index_user_visit_consents_on_user_id_and_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_visit_consents_on_user_id_and_visit_id ON public.user_visit_consents USING btree (user_id, visit_id);


--
-- Name: index_user_visit_consents_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_visit_consents_on_visit_id ON public.user_visit_consents USING btree (visit_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON public.users USING btree (authentication_token);


--
-- Name: index_users_on_coordinator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_coordinator_id ON public.users USING btree (coordinator_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_organization_id ON public.users USING btree (organization_id);


--
-- Name: index_users_on_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_phone ON public.users USING btree (phone);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_tsv_body; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_tsv_body ON public.users USING gin (tsv_body);


--
-- Name: index_users_visit_types_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_visit_types_on_user_id ON public.users_visit_types USING btree (user_id);


--
-- Name: index_users_visit_types_on_visit_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_visit_types_on_visit_type_id ON public.users_visit_types USING btree (visit_type_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: index_video_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_video_logs_on_user_id ON public.video_logs USING btree (user_id);


--
-- Name: index_video_logs_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_video_logs_on_visit_id ON public.video_logs USING btree (visit_id);


--
-- Name: index_visit_attendances_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_attendances_on_user_id ON public.visit_attendances USING btree (user_id);


--
-- Name: index_visit_attendances_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_attendances_on_visit_id ON public.visit_attendances USING btree (visit_id);


--
-- Name: index_visit_attendances_on_visit_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_visit_attendances_on_visit_id_and_user_id ON public.visit_attendances USING btree (visit_id, user_id);


--
-- Name: index_visit_coordinators_on_coordinator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_coordinators_on_coordinator_id ON public.visit_coordinators USING btree (coordinator_id);


--
-- Name: index_visit_coordinators_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_coordinators_on_visit_id ON public.visit_coordinators USING btree (visit_id);


--
-- Name: index_visit_details_on_cpt_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_details_on_cpt_id ON public.visit_details USING btree (cpt_id);


--
-- Name: index_visit_details_on_diagnosis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_details_on_diagnosis_id ON public.visit_details USING btree (diagnosis_id);


--
-- Name: index_visit_details_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_details_on_patient_id ON public.visit_details USING btree (patient_id);


--
-- Name: index_visit_details_on_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_details_on_provider_id ON public.visit_details USING btree (provider_id);


--
-- Name: index_visit_details_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_details_on_visit_id ON public.visit_details USING btree (visit_id);


--
-- Name: index_visit_providers_on_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_providers_on_provider_id ON public.visit_providers USING btree (provider_id);


--
-- Name: index_visit_providers_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_providers_on_visit_id ON public.visit_providers USING btree (visit_id);


--
-- Name: index_visit_recordings_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_recordings_on_organization_id ON public.visit_recordings USING btree (organization_id);


--
-- Name: index_visit_recordings_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_recordings_on_visit_id ON public.visit_recordings USING btree (visit_id);


--
-- Name: index_visit_settings_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_settings_on_organization_id ON public.visit_settings USING btree (organization_id);


--
-- Name: index_visits_on_organization_id_and_schedule; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visits_on_organization_id_and_schedule ON public.visits USING btree (organization_id, schedule);


--
-- Name: index_visits_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visits_on_patient_id ON public.visits USING btree (patient_id);


--
-- Name: index_zip_codes_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_zip_codes_on_code ON public.zip_codes USING btree (code);


--
-- Name: diagnoses diagnoses_full_text_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER diagnoses_full_text_trigger BEFORE INSERT OR UPDATE ON public.diagnoses FOR EACH ROW EXECUTE FUNCTION public.diagnoses_full_text_function();


--
-- Name: users users_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER users_tsvectorupdate BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.users_full_text_function();


--
-- Name: visit_details fk_rails_1304df93cb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_details
    ADD CONSTRAINT fk_rails_1304df93cb FOREIGN KEY (provider_id) REFERENCES public.users(id);


--
-- Name: organization_subscriptions fk_rails_237f4a17bb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_subscriptions
    ADD CONSTRAINT fk_rails_237f4a17bb FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: organization_reminder_settings fk_rails_32d76dc984; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_reminder_settings
    ADD CONSTRAINT fk_rails_32d76dc984 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: user_imports fk_rails_3bcfa7e0e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_imports
    ADD CONSTRAINT fk_rails_3bcfa7e0e1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: states fk_rails_40bd891262; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT fk_rails_40bd891262 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: visit_details fk_rails_4969371314; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_details
    ADD CONSTRAINT fk_rails_4969371314 FOREIGN KEY (cpt_id) REFERENCES public.cpts(id);


--
-- Name: identities fk_rails_5373344100; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT fk_rails_5373344100 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: organization_states fk_rails_61c6aec5d3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_states
    ADD CONSTRAINT fk_rails_61c6aec5d3 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: visit_details fk_rails_7571fea025; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_details
    ADD CONSTRAINT fk_rails_7571fea025 FOREIGN KEY (visit_id) REFERENCES public.visits(id);


--
-- Name: incident_informations fk_rails_765c943268; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incident_informations
    ADD CONSTRAINT fk_rails_765c943268 FOREIGN KEY (visit_id) REFERENCES public.visits(id);


--
-- Name: incident_informations fk_rails_8152e8a8a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incident_informations
    ADD CONSTRAINT fk_rails_8152e8a8a8 FOREIGN KEY (patient_id) REFERENCES public.users(id);


--
-- Name: organization_subscriptions fk_rails_83911ffcb8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_subscriptions
    ADD CONSTRAINT fk_rails_83911ffcb8 FOREIGN KEY (organization_plan_id) REFERENCES public.organization_plans(id);


--
-- Name: provider_states fk_rails_874fe2695b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_states
    ADD CONSTRAINT fk_rails_874fe2695b FOREIGN KEY (provider_id) REFERENCES public.users(id);


--
-- Name: actions fk_rails_8c6b5c12eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT fk_rails_8c6b5c12eb FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: medications fk_rails_bd2c97edb7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medications
    ADD CONSTRAINT fk_rails_bd2c97edb7 FOREIGN KEY (visit_id) REFERENCES public.visits(id);


--
-- Name: provider_states fk_rails_bfd96242d3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_states
    ADD CONSTRAINT fk_rails_bfd96242d3 FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- Name: visit_details fk_rails_d2768dcd20; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_details
    ADD CONSTRAINT fk_rails_d2768dcd20 FOREIGN KEY (patient_id) REFERENCES public.users(id);


--
-- Name: visit_details fk_rails_da373772fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_details
    ADD CONSTRAINT fk_rails_da373772fd FOREIGN KEY (diagnosis_id) REFERENCES public.diagnoses(id);


--
-- Name: conditions fk_rails_e265dff5ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT fk_rails_e265dff5ce FOREIGN KEY (visit_id) REFERENCES public.visits(id);


--
-- Name: organization_states fk_rails_e5a2ffdeda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_states
    ADD CONSTRAINT fk_rails_e5a2ffdeda FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- Name: organization_included_features fk_rails_ea955a1f41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_included_features
    ADD CONSTRAINT fk_rails_ea955a1f41 FOREIGN KEY (organization_plan_id) REFERENCES public.organization_plans(id);


--
-- Name: user_imports fk_rails_fcded192d5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_imports
    ADD CONSTRAINT fk_rails_fcded192d5 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: organization_included_features fk_rails_fe60a8f476; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_included_features
    ADD CONSTRAINT fk_rails_fe60a8f476 FOREIGN KEY (organization_feature_id) REFERENCES public.organization_features(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20160925182238'),
('20161007195029'),
('20161007195031'),
('20161007195512'),
('20161009175012'),
('20161018233843'),
('20161023171504'),
('20161023181146'),
('20161023203726'),
('20161025204520'),
('20161029200401'),
('20161108173152'),
('20161117204753'),
('20161117205100'),
('20161124041724'),
('20161127010230'),
('20161128000511'),
('20161128001607'),
('20161201003116'),
('20161210074048'),
('20161211200852'),
('20161213192918'),
('20170115201559'),
('20170118142249'),
('20170525171844'),
('20170526003312'),
('20170529190145'),
('20170608213841'),
('20170609001737'),
('20170609152158'),
('20170612191150'),
('20170612192730'),
('20170614204825'),
('20170623183130'),
('20170711212745'),
('20170811203426'),
('20170811203628'),
('20170824224308'),
('20170906162117'),
('20170906195530'),
('20170916202248'),
('20180807215426'),
('20180808030841'),
('20180808205912'),
('20180808212641'),
('20180808233543'),
('20180815210732'),
('20180906204633'),
('20180919160919'),
('20181026233409'),
('20181026233955'),
('20181027104239'),
('20181105234209'),
('20181118005025'),
('20181121205810'),
('20181206004940'),
('20181206185135'),
('20181207021213'),
('20181208211053'),
('20181221233954'),
('20181223194029'),
('20190201024305'),
('20190222140829'),
('20190328180851'),
('20190405185645'),
('20190420110236'),
('20190604153747'),
('20190604154618'),
('20190604164245'),
('20190604164812'),
('20190610060444'),
('20190610061506'),
('20190610175610'),
('20190615112944'),
('20190618111017'),
('20190621144305'),
('20190621145303'),
('20190621173214'),
('20190626161123'),
('20190712172732'),
('20190721070014'),
('20190726094106'),
('20190727105137'),
('20190727105658'),
('20190727141431'),
('20190727144849'),
('20190806164152'),
('20190820164802'),
('20191210102951'),
('20191210103033'),
('20191210105303'),
('20191211065549'),
('20191212092638'),
('20191217072112'),
('20191217072215'),
('20191218114354'),
('20191220125422'),
('20191223135213'),
('20191224051730'),
('20191231085732'),
('20200116125600'),
('20200204122418'),
('20200206074708'),
('20200210104133'),
('20200213045814'),
('20200228090747'),
('20200228091842'),
('20200320103442'),
('20200324105537'),
('20200325073254'),
('20200325115819'),
('20200325144515'),
('20200326072742'),
('20200326135701'),
('20200327063912'),
('20200331105549'),
('20200401055358'),
('20200401055527'),
('20200401115231'),
('20200403065658'),
('20200403073429'),
('20200405201837'),
('20200405225242'),
('20200407104115'),
('20200408054808'),
('20200408113942'),
('20200408120737'),
('20200408130418'),
('20200409062631'),
('20200409063050'),
('20200409081421'),
('20200409082152'),
('20200409112352'),
('20200409114520'),
('20200409120318'),
('20200410062647'),
('20200410062844'),
('20200410100745'),
('20200410101114'),
('20200410101831'),
('20200410103459'),
('20200410103803'),
('20200410114112'),
('20200410115816'),
('20200410142347'),
('20200410190213'),
('20200411082330'),
('20200412111820'),
('20200412112303'),
('20200412120718'),
('20200413042528'),
('20200414111413'),
('20200415121908'),
('20200415131630'),
('20200415162945'),
('20200416113008'),
('20200416124050'),
('20200417075324'),
('20200417075531'),
('20200417105734'),
('20200420073629'),
('20200420114406'),
('20200420124449'),
('20200421062223'),
('20200421081910'),
('20200421083644'),
('20200421112403'),
('20200422070329'),
('20200423045109'),
('20200423075009'),
('20200424072348'),
('20200424114130'),
('20200427063643'),
('20200427080129'),
('20200427111627'),
('20200428092215'),
('20200429080721'),
('20200429125026'),
('20200430090406'),
('20200430115455'),
('20200430133820'),
('20200430163930'),
('20200501075301'),
('20200504073544'),
('20200505100004'),
('20200506082014'),
('20200506120046'),
('20200507112800'),
('20200508070859'),
('20200508134005'),
('20200508134301'),
('20200511101011'),
('20200512061303'),
('20200512061500'),
('20200513112712'),
('20200513112808'),
('20200515083349'),
('20200515095813'),
('20200518082256'),
('20200520080335'),
('20200520090344'),
('20200522220452'),
('20200527092051'),
('20200527112331'),
('20200528103936'),
('20200528104942'),
('20200601105856'),
('20200605075211'),
('20200617074128'),
('20200710072827'),
('20200710092916'),
('20200710093422'),
('20200710095303'),
('20200714122207'),
('20200720101859'),
('20200721121055'),
('20200727080749'),
('20200727085344'),
('20200807072417'),
('20200811085915'),
('20200812131133'),
('20200813105704'),
('20200907080530');


