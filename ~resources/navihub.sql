CREATE TABLE "accesslog" (
"id" int4 NOT NULL,
"ajax" int2 NOT NULL DEFAULT 0,
"ip2long" int4 NOT NULL,
"ip" varchar(15) DEFAULT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id", "ip2long", "_created") 
);

CREATE TABLE "blacklist" (
"ip2long" int4 NOT NULL,
"ip" varchar(15) DEFAULT NULL,
"reason" varchar(500) DEFAULT NULL,
"valid_from" timestamp DEFAULT NULL,
"valid_to" timestamp DEFAULT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("ip2long") 
);

CREATE UNIQUE INDEX "unique_ip2long" ON "blacklist" ("ip2long");

CREATE TABLE "cookies" (
"id" int4 NOT NULL,
"cookie" varchar(128) NOT NULL,
"id_users" int4 DEFAULT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id", "cookie") 
);

CREATE UNIQUE INDEX "cookie" ON "cookies" ("cookie");
CREATE INDEX "id" ON "cookies" ("id");
CREATE INDEX "c_u" ON "cookies" ("id_users");

CREATE TABLE "emails" (
"id" int4 NOT NULL,
"recipient" varchar(255) NOT NULL,
"sender" varchar(255) NOT NULL,
"subject" text DEFAULT NULL,
"content" text NOT NULL,
"type" varchar(20) NOT NULL DEFAULT 'other',
"tries" int2 NOT NULL DEFAULT 0,
"sent" timestamp DEFAULT '0000-00-00 00:00:00',
"hash" varchar(100) NOT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id") 
);

CREATE TABLE "email_verifications" (
"id" int4 NOT NULL,
"id_users" int4 NOT NULL,
"email" varchar(255) NOT NULL,
"verified" int2 NOT NULL DEFAULT 0,
"hash" varchar(255) NOT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id", "hash") 
);

CREATE UNIQUE INDEX "ev_hash" ON "email_verifications" ("hash");
CREATE INDEX "ev_u" ON "email_verifications" ("id_users");

CREATE TABLE "forms" (
"id" int4 NOT NULL,
"id_cookies" int4 DEFAULT NULL,
"crc32" varchar(50) DEFAULT NULL,
"ip" int8 DEFAULT NULL,
"server_ser" text DEFAULT NULL,
"data" varchar(255) DEFAULT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id") 
);

CREATE INDEX "f_c" ON "forms" ("id_cookies");

CREATE TABLE "lst_timezones" (
"id" int4 NOT NULL,
"utc" float4 NOT NULL,
"name" varchar(500) NOT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id") 
);

CREATE TABLE "notes" (
"id" int4 NOT NULL,
"id_tasks" int4 NOT NULL,
"note" text NOT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id") 
);

CREATE INDEX "notes_tasks" ON "notes" ("id_tasks");

CREATE TABLE "options" (
"id" int4 NOT NULL,
"id_users" int4 NOT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id") 
);

CREATE INDEX "options_users" ON "options" ("id_users");

CREATE TABLE "tasks" (
"id" int4 NOT NULL,
"id_users" int4 NOT NULL,
"name" varchar(500) DEFAULT NULL,
"start" timestamp NOT NULL,
"end" timestamp DEFAULT NULL,
"end_type" varchar(255) DEFAULT NULL,
"end_note" varchar(500) DEFAULT NULL,
"interruption_note" varchar(250) DEFAULT NULL,
"worktime" int2 NOT NULL,
"pausetime" int2 NOT NULL,
"breaktime" int2 NOT NULL,
"iterations" int2 NOT NULL,
"timezone" varchar(20) NOT NULL,
"microtime" numeric(15,4) NOT NULL,
"utc" numeric(4,2) NOT NULL,
"dst" int2 NOT NULL DEFAULT 0,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id", "id_users") 
);

CREATE INDEX "tasks_users" ON "tasks" ("id_users");

CREATE TABLE "users" (
"id" int4 NOT NULL,
"id_fb" varchar(50) DEFAULT NULL,
"id_tw" varchar(50) DEFAULT NULL,
"id_gp" varchar(50) DEFAULT NULL,
"name" varchar(255) DEFAULT NULL,
"imgurl" varchar(1000) DEFAULT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id") 
);

CREATE UNIQUE INDEX "id_fb" ON "users" ("id_fb");
CREATE UNIQUE INDEX "id_tw" ON "users" ("id_tw");
CREATE UNIQUE INDEX "id_gp" ON "users" ("id_gp");

CREATE TABLE "users_credentials" (
"id" int4 NOT NULL,
"id_users" int4 NOT NULL,
"username" varchar(50) NOT NULL,
"email" varchar(50) DEFAULT '',
"password" varchar(128) NOT NULL,
"salt" varchar(128) NOT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id", "username") 
);

CREATE INDEX "username" ON "users_credentials" ("username");
CREATE INDEX "email" ON "users_credentials" ("email");
CREATE INDEX "uc_u" ON "users_credentials" ("id_users");

CREATE TABLE "users_passwords_reset" (
"id" int4 NOT NULL,
"id_users" int4 NOT NULL,
"hash" varchar(255) NOT NULL,
"used" timestamp DEFAULT NULL,
"_created" timestamp DEFAULT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id", "id_users", "hash") 
);

CREATE UNIQUE INDEX "upr_hash" ON "users_passwords_reset" ("hash");

CREATE TABLE "users_sessions" (
"id" int4 NOT NULL,
"id_users" int4 NOT NULL,
"id_cookies" int4 DEFAULT 0,
"phpsess" varchar(50) NOT NULL,
"valid" timestamp DEFAULT NULL,
"remember" int2 NOT NULL DEFAULT 0,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id", "id_users", "phpsess") 
);

CREATE INDEX "id_users" ON "users_sessions" ("id_users");
CREATE INDEX "us_c" ON "users_sessions" ("id_cookies");

CREATE TABLE "users_sessions_fb" (
"id" int4 NOT NULL,
"id_users" int4 NOT NULL,
"valid" timestamp NOT NULL,
"expires" timestamp DEFAULT NULL,
"issued" timestamp DEFAULT NULL,
"session_ser" text NOT NULL,
"info_ser" text NOT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id", "id_users", "valid") 
);

CREATE INDEX "usfb_u" ON "users_sessions_fb" ("id_users");
COMMENT ON COLUMN "users_sessions_fb"."valid" IS 'This field is calculated based on the application settings. It has no connection with the FB session itself.';
COMMENT ON COLUMN "users_sessions_fb"."expires" IS 'This is the time when the acquired session expires.';

CREATE TABLE "users_sessions_gp" (
"id" int4 NOT NULL,
"id_users" int4 NOT NULL,
"valid" timestamp NOT NULL,
"expires" timestamp NOT NULL,
"issued" timestamp NOT NULL,
"token_json" text NOT NULL,
"info_ser" text NOT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id", "id_users", "valid") 
);

CREATE INDEX "usgp_u" ON "users_sessions_gp" ("id_users");
COMMENT ON COLUMN "users_sessions_gp"."valid" IS 'This field is calculated based on the application settings. It has no connection with the Google session itself.';
COMMENT ON COLUMN "users_sessions_gp"."expires" IS 'This is the time when the acquired token expires.';

CREATE TABLE "users_sessions_tw" (
"id" int4 NOT NULL,
"id_users" int4 NOT NULL,
"token" varchar(500) NOT NULL,
"token_secret" varchar(500) NOT NULL,
"valid" timestamp NOT NULL,
"conn_ser" text NOT NULL,
"credentials_ser" text NOT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("id", "id_users", "valid") 
);

CREATE INDEX "ustw_u" ON "users_sessions_tw" ("id_users");
COMMENT ON COLUMN "users_sessions_tw"."valid" IS 'This field is calculated based on the application settings. It has no connection with the TW session itself.';

CREATE TABLE "whitelist" (
"ip2long" int4 NOT NULL,
"ip" varchar(15) DEFAULT NULL,
"reason" varchar(500) DEFAULT NULL,
"valid_from" timestamp DEFAULT NULL,
"valid_to" timestamp DEFAULT NULL,
"_created" timestamp NOT NULL,
"_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
"_deleted" int2 NOT NULL DEFAULT 0,
PRIMARY KEY ("ip2long") 
);

CREATE UNIQUE INDEX "unique_ip2long" ON "whitelist" ("ip2long");


ALTER TABLE "cookies" ADD CONSTRAINT "c_u" FOREIGN KEY ("id_users") REFERENCES "users" ("id");
ALTER TABLE "email_verifications" ADD CONSTRAINT "ev_u" FOREIGN KEY ("id_users") REFERENCES "users" ("id");
ALTER TABLE "forms" ADD CONSTRAINT "f_c" FOREIGN KEY ("id_cookies") REFERENCES "cookies" ("id");
ALTER TABLE "notes" ADD CONSTRAINT "notes_tasks" FOREIGN KEY ("id_tasks") REFERENCES "tasks" ("id");
ALTER TABLE "options" ADD CONSTRAINT "o_u" FOREIGN KEY ("id_users") REFERENCES "users" ("id");
ALTER TABLE "tasks" ADD CONSTRAINT "t_u" FOREIGN KEY ("id_users") REFERENCES "users" ("id");
ALTER TABLE "users_credentials" ADD CONSTRAINT "uc_u" FOREIGN KEY ("id_users") REFERENCES "users" ("id");
ALTER TABLE "users_sessions" ADD CONSTRAINT "us_c" FOREIGN KEY ("id_cookies") REFERENCES "cookies" ("id");
ALTER TABLE "users_sessions" ADD CONSTRAINT "us_u" FOREIGN KEY ("id_users") REFERENCES "users" ("id");
ALTER TABLE "users_sessions_fb" ADD CONSTRAINT "usfb_u" FOREIGN KEY ("id_users") REFERENCES "users" ("id");
ALTER TABLE "users_sessions_gp" ADD CONSTRAINT "usgp_u" FOREIGN KEY ("id_users") REFERENCES "users" ("id");
ALTER TABLE "users_sessions_tw" ADD CONSTRAINT "ustw_u" FOREIGN KEY ("id_users") REFERENCES "users" ("id");

