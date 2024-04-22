CREATE TABLE warns
(
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    member_id DISCORD_ID NOT NULL,
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reason TEXT NOT NULL,
    created TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE (guild_id, member_id, id),
    FOREIGN KEY (guild_id, member_id) REFERENCES members(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX warns_created_index ON warns (created DESC NULLS LAST);

CREATE TRIGGER warns_members_insert_trigger BEFORE INSERT ON warns FOR EACH ROW EXECUTE FUNCTION create_member();
CREATE TRIGGER warns_members_update_trigger BEFORE UPDATE OF guild_id, member_id ON warns FOR EACH ROW EXECUTE FUNCTION create_member();


CREATE VIEW warns_view AS
	SELECT warns.*
	FROM warns;