CREATE TABLE categorychannels
(
    guild_id DISCORD_ID NOT NULL,
    id DISCORD_ID NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

    UNIQUE (guild_id, id)
);



CREATE VIEW categorychannels_view AS
	SELECT categorychannels.*
	FROM categorychannels;