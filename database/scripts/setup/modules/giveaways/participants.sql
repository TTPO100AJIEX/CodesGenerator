CREATE TABLE giveaways_participants
(
    member_id DISCORD_ID NOT NULL,
    id DISCORD_ID GENERATED ALWAYS AS (member_id) STORED,
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    giveaway_id INT NOT NULL REFERENCES giveaways(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    
    UNIQUE (guild_id, giveaway_id, id),
    PRIMARY KEY (guild_id, giveaway_id, member_id),
    FOREIGN KEY (guild_id, member_id) REFERENCES members(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, giveaway_id) REFERENCES giveaways(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TRIGGER giveaways_participants_members_insert_trigger BEFORE INSERT ON giveaways_participants FOR EACH ROW EXECUTE FUNCTION create_member();
CREATE TRIGGER giveaways_participants_members_update_trigger BEFORE UPDATE OF guild_id, member_id ON giveaways_participants FOR EACH ROW EXECUTE FUNCTION create_member();


CREATE VIEW giveaways_participants_view AS
	SELECT giveaways_participants.*
	FROM giveaways_participants;