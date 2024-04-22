CREATE TABLE clans_levels
(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (guild_id, id),

    price UINT NOT NULL,
    members_limit POSITIVE_SMALLINT NOT NULL,
    role_position USMALLINT NOT NULL,

    has_voice BOOL NOT NULL,
    voice_category DISCORD_ID REFERENCES categorychannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    voice_position USMALLINT CHECK ((NOT has_voice) OR (has_voice AND voice_position IS NOT NULL)),
    FOREIGN KEY (guild_id, voice_category) REFERENCES categorychannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,

    can_change_name BOOL NOT NULL,
    can_change_color BOOL NOT NULL,
    can_set_deputies BOOL NOT NULL,

    duration INTERVAL CHECK (duration >= '1 day'),
    prolongcost UINT CHECK ((duration IS NULL) OR (prolongcost IS NOT NULL)),
    prolongmessage INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    prolongtime INTERVAL CHECK ((duration IS NULL) OR (prolongtime IS NOT NULL AND prolongtime >= '1 hour' AND prolongtime <= duration)),
    FOREIGN KEY (guild_id, prolongmessage) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT
);


CREATE VIEW clans_levels_view AS
    SELECT
        levels.guild_id, levels.id AS level_id,
        levels.price, levels.members_limit, levels.role_position,
        levels.has_voice, levels.voice_position, levels.voice_category,
        levels.can_change_name, levels.can_change_color, levels.can_set_deputies,
        levels.duration, levels.prolongcost, levels.prolongmessage, levels.prolongtime,
        (ROW_NUMBER() OVER (PARTITION BY guild_id ORDER BY id ASC))::SMALLINT AS id,
        (COUNT(*) OVER (PARTITION BY guild_id) = ROW_NUMBER() OVER (PARTITION BY guild_id ORDER BY id ASC)) AS is_last_level
    FROM clans_levels AS levels;



CALL create_json_casts('clans_levels_view', 'clans_levels');



CREATE FUNCTION clans_levels_view_insert() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	INSERT INTO clans_levels OVERRIDING USER VALUE VALUES ((NEW::clans_levels).*) RETURNING ((clans_levels::clans_levels_view).*) INTO NEW;
	RETURN NEW;
END $$;
CREATE TRIGGER clans_levels_view_insert_trigger INSTEAD OF INSERT ON clans_levels_view FOR EACH ROW EXECUTE FUNCTION clans_levels_view_insert();



-- UPDATE on clans_levels_view is not allowed



CREATE RULE clans_levels_view_delete_override AS ON DELETE TO clans_levels_view DO INSTEAD DELETE FROM clans_levels WHERE id = OLD.level_id;
