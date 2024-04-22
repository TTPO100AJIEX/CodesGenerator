CREATE TYPE messages_data AS
(
    guild_id DISCORD_ID,
    name VARCHAR(100),
    content VARCHAR(2000),
    suppressembeds BOOL
);



CREATE TABLE messages OF messages_data
(
    guild_id WITH OPTIONS NOT NULL,
    name WITH OPTIONS NOT NULL,
    suppressembeds WITH OPTIONS NOT NULL DEFAULT FALSE
);
ALTER TABLE messages NOT OF;
ALTER TABLE messages ADD COLUMN id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY;
ALTER TABLE messages ADD UNIQUE (guild_id, id);



CALL create_json_casts('messages_data', 'messages');



CREATE TABLE embeds_used
(
    message_id INT NOT NULL REFERENCES messages(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    embed_id INT NOT NULL REFERENCES embeds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,

    PRIMARY KEY (message_id, embed_id)
);
CREATE INDEX embeds_used_embed_id_index ON embeds_used(embed_id);
CREATE INDEX embeds_used_message_id_index ON embeds_used(message_id);