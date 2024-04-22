CREATE FUNCTION members_insert_sync_economics() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE AS $$
BEGIN
	UPDATE members SET
		coins = coins + members.messages * guilds_view.economics_messagecoins,
		coins_voicetime_remainder = coins_voicetime_remainder + voicetime
	FROM guilds_view
	WHERE guilds_view.id = members.guild_id AND guilds_view.economics_active AND
		EXISTS(SELECT 1 FROM NEWTABLE WHERE members.id = NEWTABLE.id AND members.guild_id = NEWTABLE.guild_id);
	
	RETURN NEW;
END $$;
CREATE TRIGGER members_insert_sync_economics_trigger AFTER INSERT ON members
REFERENCING NEW TABLE AS NEWTABLE FOR EACH STATEMENT EXECUTE FUNCTION members_insert_sync_economics();


CREATE FUNCTION members_update_sync_economics() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
DECLARE
	voicecoins BIGINT;
	voiceinterval INTERVAL;

	messagecoins BIGINT;
    messageinterval INT;

	old_stats JSON;
	new_stats JSON;
	notification JSON;
BEGIN
	IF (OLD.coins > NEW.coins) AND (OLD.started_game IS NOT NULL) AND (NEW.started_game IS NOT NULL) AND (NOW() - OLD.started_game <= '1 minute') THEN
		RAISE EXCEPTION SQLSTATE 'P0004' USING
			MESSAGE = 'CoinsUpdateCheckGames Constraint violation',
			DETAIL = 'Removing coins on members that are currently playing games is not allowed!',
			HINT = 'Please, finish the game and try again';
	END IF;
	
	SELECT
        economics_voicecoins, EXTRACT(EPOCH FROM economics_voiceinterval),
        economics_messagecoins, economics_messageinterval
    FROM guilds_view WHERE id = NEW.guild_id AND economics_active
	INTO voicecoins, voiceinterval, messagecoins, messageinterval;
	
	voicecoins = COALESCE(voicecoins, 0);
	messagecoins = COALESCE(messagecoins, 0);
	messageinterval = COALESCE(messageinterval, 1);
	voiceinterval = COALESCE(voiceinterval, '5 seconds');

    NEW.coins_voicetime_remainder = NEW.coins_voicetime_remainder + NEW.voicetime - OLD.voicetime;
	voicecoins = voicecoins * (EXTRACT(EPOCH FROM NEW.coins_voicetime_remainder) / EXTRACT(EPOCH FROM voiceinterval));
	NEW.coins_voicetime_remainder = (EXTRACT(EPOCH FROM NEW.coins_voicetime_remainder) % EXTRACT(EPOCH FROM voiceinterval)) * '1s'::interval;

    NEW.coins_messages_remainder = NEW.coins_messages_remainder + NEW.messages - OLD.messages;
	messagecoins = messagecoins * (NEW.coins_messages_remainder / messageinterval);
    NEW.coins_messages_remainder = NEW.coins_messages_remainder % messageinterval;
	
	NEW.coins = CLAMP(0, NEW.coins + voicecoins + messagecoins, 2147483647);

	old_stats = json_build_object('coins', OLD.coins, 'voicetime', OLD.voicetime, 'messages', OLD.messages);
	new_stats = json_build_object('coins', NEW.coins, 'voicetime', NEW.voicetime, 'messages', NEW.messages);
	notification = json_build_object('guild_id', NEW.guild_id::text, 'id', NEW.id::text, 'old_stats', old_stats, 'new_stats', new_stats);
	PERFORM pg_notify('member_stats_change', notification::text);

	RETURN NEW;
END $$;
CREATE TRIGGER members_update_sync_economics_trigger BEFORE UPDATE OF coins, voicetime, messages ON members
FOR EACH ROW EXECUTE FUNCTION members_update_sync_economics();