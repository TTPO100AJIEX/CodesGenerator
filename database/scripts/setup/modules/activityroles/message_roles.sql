CREATE TABLE message_activityroles
(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_id DISCORD_ID NOT NULL REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    min POSITIVE_INT NOT NULL,
    max POSITIVE_INT NOT NULL CHECK (max > min)
);



CREATE VIEW message_activityroles_view AS
	SELECT message_activityroles.*, roles.guild_id
	FROM message_activityroles
    INNER JOIN roles ON message_activityroles.role_id = roles.id;



CALL create_json_casts('message_activityroles_view', 'message_activityroles');



CREATE FUNCTION message_activityroles_view_insert() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	IF NEW.guild_id != (SELECT guild_id FROM roles WHERE id = NEW.role_id) THEN
		RAISE EXCEPTION SQLSTATE '23503' USING
			MESSAGE = 'guild_id Constraint violation on message_activityroles',
			DETAIL = 'You cannot insert rules for roles that do not belong to your server',
			HINT = 'Please, fix your request';
	END IF;
	INSERT INTO message_activityroles OVERRIDING USER VALUE VALUES ((NEW::message_activityroles).*) RETURNING ((message_activityroles::message_activityroles_view).*) INTO NEW;
	RETURN NEW;
END $$;
CREATE TRIGGER message_activityroles_view_insert_trigger INSTEAD OF INSERT ON message_activityroles_view FOR EACH ROW EXECUTE FUNCTION message_activityroles_view_insert();


-- UPDATE on message_activityroles_view is not allowed



CREATE RULE message_activityroles_view_delete_override AS ON DELETE TO message_activityroles_view DO INSTEAD DELETE FROM message_activityroles WHERE id = OLD.id;