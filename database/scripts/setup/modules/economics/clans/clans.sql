CREATE TABLE clans
(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    member_id DISCORD_ID NOT NULL,
    UNIQUE (guild_id, member_id),
    FOREIGN KEY (guild_id, member_id) REFERENCES members(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    
    last_paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    level USMALLINT NOT NULL DEFAULT 0,
    prolong_notification_sent BOOL NOT NULL DEFAULT FALSE,

    role_id DISCORD_ID NOT NULL UNIQUE REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    voice_id DISCORD_ID UNIQUE REFERENCES voicechannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, role_id) REFERENCES roles(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, voice_id) REFERENCES voicechannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX clans_last_paid_at_index ON clans (last_paid_at ASC NULLS LAST);
CREATE INDEX clans_prolong_notification_sent_index ON clans (prolong_notification_sent ASC NULLS LAST);

CREATE TRIGGER clans_members_insert_trigger BEFORE INSERT ON clans FOR EACH ROW EXECUTE FUNCTION create_member();
CREATE TRIGGER clans_members_update_trigger BEFORE UPDATE OF guild_id, member_id ON clans FOR EACH ROW EXECUTE FUNCTION create_member();


CREATE TABLE clans_deputies
(
    clan_id INT NOT NULL REFERENCES clans(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    member_id DISCORD_ID NOT NULL,

    PRIMARY KEY (clan_id, member_id)
);


CREATE VIEW clans_view AS
    SELECT 	clans.id, clans.guild_id, clans.member_id AS owner_id,
            clans.level, levels.id AS actual_level, levels.is_last_level,
            clans.last_paid_at, clans.prolong_notification_sent, clans.role_id, clans.voice_id,
		    clans.last_paid_at + levels.duration AS deletion_date,
		    clans.last_paid_at + levels.duration - levels.prolongtime AS prolong_date,
			ARRAY(SELECT member_id FROM clans_deputies WHERE clans_deputies.clan_id = clans.id) AS deputies,
            
            levels.price, levels.members_limit, levels.role_position,
            levels.has_voice, levels.voice_position, levels.voice_category,
            levels.can_change_name, levels.can_change_color, levels.can_set_deputies,
            levels.duration, levels.prolongcost, levels.prolongmessage, levels.prolongtime
    FROM clans
    LEFT JOIN clans_levels_view AS levels
        ON  levels.guild_id = clans.guild_id AND
            (levels.id = clans.level OR (levels.is_last_level AND clans.level > levels.id));
