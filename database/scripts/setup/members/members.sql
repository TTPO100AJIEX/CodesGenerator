CREATE TABLE members
(
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    id DISCORD_ID NOT NULL,


    coins INT NOT NULL DEFAULT 0,
    messages INT NOT NULL DEFAULT 0,
    voicetime INTERVAL NOT NULL DEFAULT '0',

    save_coins INT NOT NULL DEFAULT 0,
    save_messages INT NOT NULL DEFAULT 0,
    save_voicetime INTERVAL NOT NULL DEFAULT '0',

    coins_voicetime_remainder INTERVAL NOT NULL CHECK(coins_voicetime_remainder >= '0') DEFAULT '0',
    coins_messages_remainder USMALLINT NOT NULL DEFAULT 0,
    
    started_game TIMESTAMPTZ,


    autochannel DISCORD_ID UNIQUE REFERENCES voicechannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, autochannel) REFERENCES voicechannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,


    PRIMARY KEY (guild_id, id)
);
CREATE INDEX members_guild_id_coins_index ON members(guild_id ASC NULLS LAST, coins ASC NULLS LAST);
CREATE INDEX members_guild_id_messages_index ON members(guild_id ASC NULLS LAST, messages ASC NULLS LAST);
CREATE INDEX members_guild_id_voicetime_index ON members(guild_id ASC NULLS LAST, voicetime ASC NULLS LAST);


CREATE VIEW members_view AS
	SELECT members.*
	FROM members;