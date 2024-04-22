CREATE OR REPLACE PROCEDURE check_messages_embeds_limit(messageIds INT[])
LANGUAGE plpgsql
AS $$
BEGIN
	IF EXISTS( SELECT 1 FROM messages_view WHERE id = ANY(messageIds) AND COALESCE(ARRAY_LENGTH(embeds, 1), 0) > 10 ) THEN
		RAISE EXCEPTION SQLSTATE '21000' USING
			MESSAGE = 'MaxChildren Constraint violation',
			DETAIL = 'You cannot have more than 10 embeds for one message',
			HINT = 'Please, remove any excessive embeds';
	END IF;
END $$;

CREATE FUNCTION check_message_embeds_integrity() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE AS $$
DECLARE
	messageIds INT[];
BEGIN
	IF EXISTS(
		SELECT 1 FROM NEWTABLE INNER JOIN messages ON messages.id = NEWTABLE.message_id INNER JOIN embeds ON embeds.id = NEWTABLE.embed_id
		WHERE messages.guild_id != embeds.guild_id
	) THEN
		RAISE EXCEPTION SQLSTATE '23000' USING
			MESSAGE = 'Embed and message belong to different guilds',
			DETAIL = 'You are not allowed to use this embed template as it is from an another server',
			HINT = 'Please, limit to the embeds of your server';
	END IF;

	SELECT ARRAY_AGG(DISTINCT message_id) FROM NEWTABLE INTO messageIds;
	CALL check_messages_embeds_limit(messageIds);
	RETURN NEW;
END $$;

CREATE TRIGGER embeds_used_insert_integrity_check_trigger AFTER INSERT ON embeds_used
REFERENCING NEW TABLE AS NEWTABLE FOR EACH STATEMENT EXECUTE FUNCTION check_message_embeds_integrity();

CREATE TRIGGER embeds_used_update_integrity_check_trigger AFTER UPDATE ON embeds_used
REFERENCING NEW TABLE AS NEWTABLE FOR EACH STATEMENT EXECUTE FUNCTION check_message_embeds_integrity();