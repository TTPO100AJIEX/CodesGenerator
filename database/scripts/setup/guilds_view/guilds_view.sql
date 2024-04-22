CREATE VIEW guilds_view AS
	SELECT
        guilds.*,
		ARRAY(SELECT wa.role_id FROM websiteaccess AS wa WHERE wa.guild_id = guilds.id) AS websiteaccess,
		ARRAY(SELECT mr.role_id FROM economics_market_roles AS mr WHERE mr.guild_id = guilds.id) AS economics_market_roles,
		ARRAY(SELECT ir.role_id FROM inventory_roles AS ir WHERE ir.guild_id = guilds.id) AS inventory_roles
	FROM guilds
    WHERE active;
	

	
CALL create_json_casts('guilds_view', 'guilds');



-- INSERT on guilds_view is defaulted



CREATE FUNCTION update_guilds_view() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	IF (NEW.websiteaccess != OLD.websiteaccess) THEN
		DELETE FROM websiteaccess WHERE guild_id = NEW.id;
		INSERT INTO websiteaccess (guild_id, role_id) (SELECT NEW.id, * FROM unnest(NEW.websiteaccess));
	END IF;
	
	IF (NEW.economics_market_roles != OLD.economics_market_roles) THEN
		DELETE FROM economics_market_roles WHERE guild_id = NEW.id;
		INSERT INTO economics_market_roles (guild_id, role_id) (SELECT NEW.id, * FROM unnest(NEW.economics_market_roles));
	END IF;
	
	IF (NEW.inventory_roles != OLD.inventory_roles) THEN
		DELETE FROM inventory_roles WHERE guild_id = NEW.id;
		INSERT INTO inventory_roles (guild_id, role_id) (SELECT NEW.id, * FROM unnest(NEW.inventory_roles));
	END IF;

	EXECUTE 'UPDATE guilds
            SET (' || (SELECT string_agg(format('%I', attname), ',') FROM table_columns('guilds')) || ') = ROW($1.*)
            WHERE id = $2' USING NEW::guilds, NEW.id;
	RETURN NEW;
END $$;
CREATE TRIGGER update_guilds_view_trigger INSTEAD OF UPDATE ON guilds_view FOR EACH ROW EXECUTE FUNCTION update_guilds_view();



-- DELETE on guilds_view is defaulted