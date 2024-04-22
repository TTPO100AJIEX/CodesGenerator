CREATE TABLE voicetime_activityroles
(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_id DISCORD_ID NOT NULL REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    min INTERVAL NOT NULL CHECK (min > '0'),
    max INTERVAL NOT NULL CHECK (max > min)
);



CREATE VIEW voicetime_activityroles_view AS
	SELECT voicetime_activityroles.*, roles.guild_id
	FROM voicetime_activityroles
    INNER JOIN roles ON voicetime_activityroles.role_id = roles.id;



CALL create_json_casts('voicetime_activityroles_view', 'voicetime_activityroles');



CREATE FUNCTION voicetime_activityroles_view_insert() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	IF NEW.guild_id != (SELECT guild_id FROM roles WHERE id = NEW.role_id) THEN
		RAISE EXCEPTION SQLSTATE '23503' USING
			MESSAGE = 'guild_id Constraint violation on voicetime_activityroles',
			DETAIL = 'You cannot insert rules for roles that do not belong to your server',
			HINT = 'Please, fix your request';
	END IF;
	INSERT INTO voicetime_activityroles OVERRIDING USER VALUE VALUES ((NEW::voicetime_activityroles).*) RETURNING ((voicetime_activityroles::voicetime_activityroles_view).*) INTO NEW;
	RETURN NEW;
END $$;
CREATE TRIGGER voicetime_activityroles_view_insert_trigger INSTEAD OF INSERT ON voicetime_activityroles_view FOR EACH ROW EXECUTE FUNCTION voicetime_activityroles_view_insert();


-- UPDATE on voicetime_activityroles_view is not allowed



CREATE RULE voicetime_activityroles_view_delete_override AS ON DELETE TO voicetime_activityroles_view DO INSTEAD DELETE FROM voicetime_activityroles WHERE id = OLD.id;