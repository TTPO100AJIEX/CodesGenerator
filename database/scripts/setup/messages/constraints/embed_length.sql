CREATE PROCEDURE check_embed_length(embedId INT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF ( SELECT length FROM embeds_view WHERE id = embedId LIMIT 1 ) = 0 THEN
		RAISE EXCEPTION SQLSTATE '21000' USING
			MESSAGE = 'MinEmbedLength Constraint violation',
			DETAIL = 'The embed may not be empty!',
			HINT = 'Please, add some content to the embed';
	END IF;
END $$;


CREATE FUNCTION embeds_embed_length_check() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	CALL check_embed_length(NEW.id);
	RETURN NEW;
END $$;

CREATE CONSTRAINT TRIGGER embeds_insert_embed_length_check_trigger AFTER INSERT ON embeds
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION embeds_embed_length_check();

CREATE CONSTRAINT TRIGGER embeds_update_embed_length_check_trigger AFTER UPDATE ON embeds
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION embeds_embed_length_check();


CREATE FUNCTION fields_embed_length_check() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	CALL check_embed_length(OLD.embed_id);
	RETURN NEW;
END $$;

CREATE CONSTRAINT TRIGGER fields_delete_embed_length_check_trigger AFTER DELETE ON fields
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION fields_embed_length_check();

CREATE CONSTRAINT TRIGGER fields_update_embed_length_check_trigger AFTER UPDATE ON fields
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION fields_embed_length_check();