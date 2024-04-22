CREATE TABLE textchannels
(
    guild_id DISCORD_ID NOT NULL,
    id DISCORD_ID NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

    UNIQUE (guild_id, id)
);



CREATE VIEW textchannels_view AS
	SELECT textchannels.*
	FROM textchannels;