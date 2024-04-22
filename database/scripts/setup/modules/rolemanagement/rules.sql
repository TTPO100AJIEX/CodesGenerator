CREATE TYPE ROLEMANAGEMENT_RULE_TYPE AS ENUM ('ADD', 'REMOVE', 'FULL');

CREATE TABLE rolemanagement_rules
(
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    role_id DISCORD_ID NOT NULL REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    manager_role_id DISCORD_ID NOT NULL REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    permission ROLEMANAGEMENT_RULE_TYPE NOT NULL,

    CHECK (role_id != manager_role_id),
	PRIMARY KEY (role_id, manager_role_id),
	UNIQUE (guild_id, role_id, manager_role_id),
    FOREIGN KEY (guild_id, role_id) REFERENCES roles(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, manager_role_id) REFERENCES roles(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE
);



CREATE VIEW rolemanagement_rules_view AS
	SELECT rolemanagement_rules.*
	FROM rolemanagement_rules;