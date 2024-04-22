ALTER TABLE embeds ADD CONSTRAINT embeds_guild_id_fkey_constraint
    FOREIGN KEY (guild_id) REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;
    
ALTER TABLE messages ADD CONSTRAINT messages_guild_id_fkey_constraint
    FOREIGN KEY (guild_id) REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;
    
ALTER TABLE roles ADD CONSTRAINT roles_guild_id_fkey_constraint
    FOREIGN KEY (guild_id) REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE textchannels ADD CONSTRAINT textchannels_guild_id_fkey_constraint
    FOREIGN KEY (guild_id) REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE voicechannels ADD CONSTRAINT voicechannels_guild_id_fkey_constraint
    FOREIGN KEY (guild_id) REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE categorychannels ADD CONSTRAINT categorychannels_guild_id_fkey_constraint
    FOREIGN KEY (guild_id) REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;