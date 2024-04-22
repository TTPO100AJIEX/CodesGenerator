CREATE VIEW fields_view AS
	SELECT
		fields.*,
		embeds.guild_id,
		embeds_used.message_id,
		char_length(COALESCE(fields.name, '')) + char_length(COALESCE(fields.value, '')) AS length
	FROM fields
	LEFT OUTER JOIN embeds ON embeds.id = fields.embed_id
	LEFT OUTER JOIN embeds_used ON embeds_used.embed_id = embeds.id;



CALL create_json_casts('fields_view', 'fields');
CALL create_json_casts('fields_view', 'fields_data');



CREATE FUNCTION fields_view_insert() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	IF NEW.guild_id != (SELECT guild_id FROM embeds WHERE id = NEW.embed_id) THEN
		RAISE EXCEPTION SQLSTATE '23503' USING
			MESSAGE = 'guild_id Constraint violation on fields',
			DETAIL = 'You cannot insert fields for the embed that does not belong to your server',
			HINT = 'Please, fix your request';
	END IF;
	INSERT INTO fields OVERRIDING USER VALUE VALUES ((NEW::fields).*) RETURNING ((fields::fields_view).*) INTO NEW;
	RETURN NEW;
END $$;
CREATE TRIGGER fields_view_insert_trigger INSTEAD OF INSERT ON fields_view FOR EACH ROW EXECUTE FUNCTION fields_view_insert();



-- UPDATE on fields_view is not allowed



CREATE RULE fields_view_delete_override AS ON DELETE TO fields_view DO INSTEAD DELETE FROM fields WHERE id = OLD.id;