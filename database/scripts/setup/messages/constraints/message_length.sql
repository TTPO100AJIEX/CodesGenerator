CREATE PROCEDURE check_message_length(messageId INT)
LANGUAGE plpgsql AS $$
DECLARE
	l_length SMALLINT;
BEGIN
	SELECT length FROM messages_view WHERE id = messageId INTO l_length;
	IF l_length = 0 THEN
		RAISE EXCEPTION SQLSTATE '21000' USING
			MESSAGE = 'MinMessageLength Constraint violation',
			DETAIL = 'The message may not be empty!',
			HINT = 'Please, add some content to the message';
	END IF;
	IF l_length > 6000 THEN
		RAISE EXCEPTION SQLSTATE '21000' USING
			MESSAGE = 'MaxMessageLength Constraint violation',
			DETAIL = 'The total length of the message cannot exceed 6000 characters',
			HINT = 'Please, remove any excessive content';
	END IF;
END $$;


CREATE FUNCTION messages_message_length_check() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	CALL check_message_length(NEW.id);
	RETURN NEW;
END $$;

CREATE CONSTRAINT TRIGGER messages_insert_message_length_check_trigger AFTER INSERT ON messages
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION messages_message_length_check();

CREATE CONSTRAINT TRIGGER messages_update_message_length_check_trigger AFTER UPDATE ON messages
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION messages_message_length_check();


CREATE FUNCTION embeds_used_message_length_check() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	CALL check_message_length(COALESCE(NEW.message_id, OLD.message_id));
	RETURN NEW;
END $$;

CREATE CONSTRAINT TRIGGER embeds_used_insert_message_length_check_trigger AFTER INSERT ON embeds_used
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION embeds_used_message_length_check();

CREATE CONSTRAINT TRIGGER embeds_used_update_message_length_check_trigger_1 AFTER UPDATE ON embeds_used
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION embeds_used_message_length_check();

CREATE CONSTRAINT TRIGGER embeds_used_delete_message_length_check_trigger AFTER DELETE ON embeds_used
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION embeds_used_message_length_check();


CREATE FUNCTION embeds_message_length_check() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE AS $$
DECLARE
	messageId INT;
BEGIN
	FOR messageId IN SELECT DISTINCT message_id FROM embeds_used WHERE embed_id = COALESCE(NEW.id, OLD.id)
	LOOP
		CALL check_message_length(messageId);
	END LOOP;
	RETURN NEW;
END $$;

CREATE CONSTRAINT TRIGGER embeds_insert_message_length_check_trigger AFTER INSERT ON embeds
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION embeds_message_length_check();

CREATE CONSTRAINT TRIGGER embeds_update_message_length_check_trigger AFTER UPDATE ON embeds
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION embeds_message_length_check();

CREATE CONSTRAINT TRIGGER embeds_delete_message_length_check_trigger AFTER DELETE ON embeds
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION embeds_message_length_check();