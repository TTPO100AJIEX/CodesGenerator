CREATE TABLE inventory_roles
(
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    role_id DISCORD_ID NOT NULL PRIMARY KEY REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,

    UNIQUE (guild_id, role_id),
    FOREIGN KEY (guild_id, role_id) REFERENCES roles(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE VIEW inventory_roles_view AS
	SELECT inventory_roles.*
	FROM inventory_roles;