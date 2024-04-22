CREATE TABLE donationroles
(
    role_id DISCORD_ID NOT NULL PRIMARY KEY REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    add_price UINT,
    add_duration INTERVAL CHECK (add_duration >= '1 hour'),
    remove_price UINT,
    remove_duration INTERVAL CHECK (remove_duration >= '1 hour'),
	CHECK ((add_price IS NOT NULL) OR (remove_price IS NOT NULL))
);



CREATE VIEW donationroles_view AS
	SELECT donationroles.*, roles.guild_id, roles.name AS role_name
	FROM donationroles INNER JOIN roles ON donationroles.role_id = roles.id;



CALL create_json_casts('donationroles_view', 'donationroles');



CREATE FUNCTION donationroles_view_insert() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	IF NEW.guild_id != (SELECT guild_id FROM roles WHERE id = NEW.role_id) THEN
		RAISE EXCEPTION SQLSTATE '23503' USING
			MESSAGE = 'guild_id Constraint violation on donationroles',
			DETAIL = 'You cannot insert rules for roles that do not belong to your server',
			HINT = 'Please, fix your request';
	END IF;
	INSERT INTO donationroles OVERRIDING USER VALUE VALUES ((NEW::donationroles).*) RETURNING ((donationroles::donationroles_view).*) INTO NEW;
	RETURN NEW;
END $$;
CREATE TRIGGER donationroles_view_insert_trigger INSTEAD OF INSERT ON donationroles_view FOR EACH ROW EXECUTE FUNCTION donationroles_view_insert();


-- UPDATE on donationroles_view is not allowed



CREATE RULE donationroles_view_delete_override AS ON DELETE TO donationroles_view DO INSTEAD DELETE FROM donationroles WHERE role_id = OLD.role_id;