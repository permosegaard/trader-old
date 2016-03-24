CREATE SEQUENCE symbols_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE symbols_id_seq
  OWNER TO trader;

CREATE TABLE symbols
(
  id integer UNIQUE NOT NULL DEFAULT nextval('symbols_id_seq'::regclass),
  name text NOT NULL,
  CONSTRAINT symbols_pkey PRIMARY KEY (id),
  CONSTRAINT symbols_name_key UNIQUE (name)
);
ALTER TABLE symbols
  OWNER TO trader;


CREATE SEQUENCE symbol_snapshots_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE symbol_snapshots_id_seq
  OWNER TO trader;

CREATE TABLE symbol_snapshots
(
  id integer UNIQUE NOT NULL DEFAULT nextval('symbol_snapshots_id_seq'::regclass),
  symbol_id integer NOT NULL,
  "timestamp" timestamp without time zone,
  data jsonb,
  CONSTRAINT symbol_snapshots_pkey PRIMARY KEY (id),
  CONSTRAINT symbol_snapshots_symbol_id_fkey FOREIGN KEY (symbol_id)
      REFERENCES symbols (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE symbol_snapshots
  OWNER TO trader;


CREATE SEQUENCE symbol_ticks_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE symbol_ticks_id_seq
  OWNER TO trader;

CREATE TABLE symbol_ticks
(
  id integer UNIQUE NOT NULL DEFAULT nextval('symbol_ticks_id_seq'::regclass),
  symbol_id integer NOT NULL,
  "timestamp" timestamp without time zone NOT NULL,
  data jsonb,
  CONSTRAINT ticks_pkey PRIMARY KEY (id),
  CONSTRAINT ticks_symbol_id_fkey FOREIGN KEY (symbol_id)
      REFERENCES symbols (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE symbol_ticks
  OWNER TO trader;