CREATE VIEW messages_view AS
	SELECT
        messages.*,
		ARRAY(SELECT embeds_used.embed_id FROM embeds_used WHERE embeds_used.message_id = messages.id) AS embeds,
		char_length(COALESCE(content, '')) + ( SELECT COALESCE(SUM(length)::integer, 0) FROM embeds_view WHERE message_id = messages.id ) AS length
	FROM messages;



CALL create_json_casts('messages_view', 'messages');
CALL create_json_casts('messages_view', 'messages_data');



CREATE FUNCTION messages_view_insert() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE AS $$
DECLARE
	embeds_storage INT[];
BEGIN
	embeds_storage := NEW.embeds;
	INSERT INTO messages OVERRIDING USER VALUE VALUES ((NEW::messages).*) RETURNING ((messages::messages_view).*) INTO NEW;
	NEW.embeds := embeds_storage;
	INSERT INTO embeds_used (message_id, embed_id) (SELECT NEW.id, * FROM unnest(embeds_storage));
	RETURN NEW;
END $$;
CREATE TRIGGER messages_view_insert_trigger INSTEAD OF INSERT ON messages_view FOR EACH ROW EXECUTE FUNCTION messages_view_insert();



CREATE FUNCTION messages_view_update() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	IF (NEW.embeds != OLD.embeds) THEN
		DELETE FROM embeds_used WHERE message_id = NEW.id;
		INSERT INTO embeds_used (message_id, embed_id) (SELECT NEW.id, * FROM unnest(NEW.embeds));
	END IF;
	
	EXECUTE 'UPDATE messages
			SET (' || (SELECT string_agg(format('%I', attname), ',') FROM table_columns('messages_data')) || ') = ROW($1.*)
			WHERE id = $2' USING NEW::messages_data, NEW.id;
	RETURN NEW;
END $$;
CREATE TRIGGER messages_view_update_trigger INSTEAD OF UPDATE ON messages_view FOR EACH ROW EXECUTE FUNCTION messages_view_update();



-- DELETE on messages_view is defaulted