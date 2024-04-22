CREATE TYPE embeds_data AS
(
    guild_id DISCORD_ID,
    name VARCHAR(100),
    title VARCHAR(256),
    description VARCHAR(4096),
    url URL,
    color COLOR,
    author_name VARCHAR(256),
    author_url URL,
    author_icon URL,
    thumbnail URL,
    image URL,
    footer_text VARCHAR(2048),
    footer_icon URL
);



CREATE TABLE embeds OF embeds_data
(
    guild_id WITH OPTIONS NOT NULL,
    name WITH OPTIONS NOT NULL
);
ALTER TABLE embeds NOT OF;
ALTER TABLE embeds ADD COLUMN id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY;
ALTER TABLE embeds ADD UNIQUE (guild_id, id);



CALL create_json_casts('embeds_data', 'embeds');