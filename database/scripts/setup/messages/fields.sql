CREATE TYPE fields_data AS
(
    embed_id INT,
    name VARCHAR(256),
    value VARCHAR(1024),
    inline BOOL
);



CREATE TABLE fields OF fields_data
(
    embed_id WITH OPTIONS NOT NULL REFERENCES embeds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    name WITH OPTIONS NOT NULL,
    value WITH OPTIONS NOT NULL,
    inline WITH OPTIONS NOT NULL DEFAULT FALSE,

    CHECK (CHAR_LENGTH(COALESCE(name, '')) + CHAR_LENGTH(COALESCE(value, '')) > 0)
);
ALTER TABLE fields NOT OF;
ALTER TABLE fields ADD COLUMN id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY;
ALTER TABLE fields ADD UNIQUE (embed_id, id);



CALL create_json_casts('fields_data', 'fields');