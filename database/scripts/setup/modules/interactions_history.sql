CREATE TYPE DISCORD_INTERACTION_TYPE AS ENUM ('PING', 'APPLICATION_COMMAND', 'MESSAGE_COMPONENT', 'APPLICATION_COMMAND_AUTOCOMPLETE', 'MODAL_SUBMIT', 'UNKNOWN');
CREATE TYPE DISCORD_INTERACTION_COMPONENT_TYPE AS ENUM ('ACTION_ROW', 'BUTTON', 'STRING_SELECT', 'TEXT_INPUT', 'USER_SELECT', 'ROLE_SELECT', 'MENTIONABLE_SELECT', 'CHANNEL_SELECT', 'UNKNOWN');

CREATE TABLE interactions_history
(
    id DISCORD_ID PRIMARY KEY,
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    member_id DISCORD_ID NOT NULL,
    FOREIGN KEY (guild_id, member_id) REFERENCES members(guild_id, id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,

    channel_id DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (guild_id, channel_id) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,

    name TEXT,
    guild_locale TEXT,
    locale LOCALE NOT NULL,
    user_locale TEXT NOT NULL,
    version POSITIVE_INT NOT NULL,
    interaction_type DISCORD_INTERACTION_TYPE NOT NULL,
    component_type DISCORD_INTERACTION_COMPONENT_TYPE NOT NULL,
    custom_id TEXT,
    command_name TEXT,
    subcommand TEXT,
    subcommand_group TEXT
);
CREATE INDEX interactions_history_guild_member_index ON interactions_history(guild_id, member_id);

CREATE TRIGGER interactions_history_members_insert_trigger BEFORE INSERT ON interactions_history FOR EACH ROW EXECUTE FUNCTION create_member();
CREATE TRIGGER interactions_history_members_update_trigger BEFORE UPDATE OF guild_id, member_id ON interactions_history FOR EACH ROW EXECUTE FUNCTION create_member();


CREATE VIEW interactions_history_view AS
	SELECT interactions_history.*
	FROM interactions_history;