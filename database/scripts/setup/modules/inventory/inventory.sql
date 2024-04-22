CREATE TABLE inventory
(
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    member_id DISCORD_ID NOT NULL,
    role_id DISCORD_ID NOT NULL REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    amount POSITIVE_SMALLINT NOT NULL DEFAULT 1,

    PRIMARY KEY (member_id, role_id),
    UNIQUE (guild_id, member_id, role_id),
    FOREIGN KEY (guild_id, role_id) REFERENCES roles(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, member_id) REFERENCES members(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX inventory_amount_index ON inventory (amount ASC NULLS LAST);

CREATE TRIGGER inventory_members_insert_trigger BEFORE INSERT ON inventory FOR EACH ROW EXECUTE FUNCTION create_member();
CREATE TRIGGER inventory_members_update_trigger BEFORE UPDATE OF guild_id, member_id ON inventory FOR EACH ROW EXECUTE FUNCTION create_member();


CREATE VIEW inventory_view AS
	SELECT inventory.*, roles.name AS role_name
	FROM inventory INNER JOIN roles ON inventory.role_id = roles.id;
