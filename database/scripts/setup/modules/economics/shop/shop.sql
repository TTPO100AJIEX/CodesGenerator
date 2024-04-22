CREATE TABLE shop
(
    role_id DISCORD_ID NOT NULL PRIMARY KEY REFERENCES roles(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE,
    add_price INT,
    add_duration INTERVAL CHECK (add_duration >= '1 hour'),
    remove_price INT,
    remove_duration INTERVAL CHECK (remove_duration >= '1 hour'),
	CHECK ((add_price IS NOT NULL) OR (remove_price IS NOT NULL))
);



CREATE VIEW shop_view AS
	SELECT shop.*, roles.guild_id, roles.name AS role_name
	FROM shop INNER JOIN roles ON shop.role_id = roles.id;



CALL create_json_casts('shop_view', 'shop');



CREATE FUNCTION shop_view_insert() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	IF NEW.guild_id != (SELECT guild_id FROM roles WHERE id = NEW.role_id) THEN
		RAISE EXCEPTION SQLSTATE '23503' USING
			MESSAGE = 'guild_id Constraint violation on shop',
			DETAIL = 'You cannot insert rules for roles that do not belong to your server',
			HINT = 'Please, fix your request';
	END IF;
	INSERT INTO shop OVERRIDING USER VALUE VALUES ((NEW::shop).*) RETURNING ((shop::shop_view).*) INTO NEW;
	RETURN NEW;
END $$;
CREATE TRIGGER shop_view_insert_trigger INSTEAD OF INSERT ON shop_view FOR EACH ROW EXECUTE FUNCTION shop_view_insert();


-- UPDATE on shop_view is not allowed



CREATE RULE shop_view_delete_override AS ON DELETE TO shop_view DO INSTEAD DELETE FROM shop WHERE role_id = OLD.role_id;