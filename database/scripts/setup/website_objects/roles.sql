CREATE TABLE roles
(
    guild_id DISCORD_ID NOT NULL,
    id DISCORD_ID NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

    UNIQUE (guild_id, id)
);



CREATE VIEW roles_view AS
	SELECT roles.*
	FROM roles;