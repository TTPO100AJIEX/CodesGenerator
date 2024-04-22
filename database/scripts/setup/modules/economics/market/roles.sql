CREATE TABLE economics_market_roles
(
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    role_id DISCORD_ID NOT NULL PRIMARY KEY REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,

    UNIQUE (guild_id, role_id),
    FOREIGN KEY (guild_id, role_id) REFERENCES roles(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE VIEW economics_market_roles_view AS
	SELECT economics_market_roles.*
	FROM economics_market_roles;