CREATE TABLE timedroles
(
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    member_id DISCORD_ID NOT NULL,
    role_id DISCORD_ID NOT NULL REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    action DISCORD_ROLE_ACTION NOT NULL CHECK (action = 'ADD' OR action = 'REMOVE'),
    timestamp TIMESTAMPTZ NOT NULL,

    PRIMARY KEY (guild_id, member_id, role_id),
    FOREIGN KEY (guild_id, role_id) REFERENCES roles(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, member_id) REFERENCES members(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX timedroles_timestamp_index ON timedroles (timestamp ASC NULLS LAST);

CREATE TRIGGER timedroles_members_insert_trigger BEFORE INSERT ON timedroles FOR EACH ROW EXECUTE FUNCTION create_member();
CREATE TRIGGER timedroles_members_update_trigger BEFORE UPDATE OF guild_id, member_id ON timedroles FOR EACH ROW EXECUTE FUNCTION create_member();


CREATE VIEW timedroles_view AS
	SELECT timedroles.*
	FROM timedroles;