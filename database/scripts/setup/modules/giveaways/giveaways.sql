CREATE TABLE giveaways
(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    channel_id DISCORD_ID NOT NULL REFERENCES textchannels(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    message_id DISCORD_ID NOT NULL UNIQUE,
    duration INTERVAL NOT NULL CHECK (duration >= '5 minute'),
    winners POSITIVE_SMALLINT NOT NULL CHECK (winners <= 50),
    participation_cost UINT NOT NULL DEFAULT 0,
    min_messages UINT NOT NULL DEFAULT 0,
    max_messages UINT CHECK (max_messages IS NULL OR max_messages > min_messages),
    min_voicetime INTERVAL NOT NULL CHECK (min_voicetime >= '0') DEFAULT '0',
    max_voicetime INTERVAL CHECK (max_voicetime IS NULL OR max_voicetime > min_voicetime),
    start TIMESTAMP NOT NULL DEFAULT NOW(),
    finish TIMESTAMP GENERATED ALWAYS AS (start + duration) STORED,
    
    UNIQUE (guild_id, id),
    FOREIGN KEY (guild_id, channel_id) REFERENCES textchannels(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX giveaways_finish_index ON giveaways (finish ASC NULLS LAST);


CREATE VIEW giveaways_view AS
	SELECT giveaways.*
	FROM giveaways;