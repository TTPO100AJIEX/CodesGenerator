CREATE TABLE events
(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (guild_id, id),
    
    name VARCHAR(100) NOT NULL,
    max_balance POSITIVE_INT NOT NULL,
    periodicity INTERVAL NOT NULL CHECK (periodicity >= '0'),
    notification_id INT NOT NULL REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, notification_id) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    
    member_id DISCORD_ID,
    UNIQUE (guild_id, member_id),
    next_event TIMESTAMPTZ DEFAULT NOW(),
    balance UINT CHECK (balance <= max_balance),
    channel DISCORD_ID UNIQUE REFERENCES voicechannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, member_id) REFERENCES members(guild_id, id) MATCH SIMPLE ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, channel) REFERENCES voicechannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE INDEX events_next_event_index ON events(next_event);

CREATE TRIGGER events_members_insert_trigger BEFORE INSERT ON events FOR EACH ROW EXECUTE FUNCTION create_member();
CREATE TRIGGER events_members_update_trigger BEFORE UPDATE OF guild_id, member_id ON events FOR EACH ROW EXECUTE FUNCTION create_member();


CREATE VIEW events_view AS
    SELECT *, member_id AS organizer FROM events;


CALL create_json_casts('events_view', 'events');