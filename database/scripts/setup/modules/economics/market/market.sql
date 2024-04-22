CREATE TABLE economics_market
(
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    member_id DISCORD_ID NOT NULL,
    role_id DISCORD_ID NOT NULL REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    price UINT NOT NULL,
    created TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (member_id, role_id),
    UNIQUE (guild_id, member_id, role_id),
    FOREIGN KEY (guild_id, role_id) REFERENCES roles(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, member_id) REFERENCES members(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX economics_market_created_index ON economics_market (created ASC NULLS LAST);

CREATE TRIGGER economics_market_members_insert_trigger BEFORE INSERT ON economics_market FOR EACH ROW EXECUTE FUNCTION create_member();
CREATE TRIGGER economics_market_members_update_trigger BEFORE UPDATE OF guild_id, member_id ON economics_market FOR EACH ROW EXECUTE FUNCTION create_member();


CREATE VIEW economics_market_view AS
	SELECT economics_market.*, roles.name AS role_name
	FROM economics_market INNER JOIN roles ON economics_market.role_id = roles.id;
