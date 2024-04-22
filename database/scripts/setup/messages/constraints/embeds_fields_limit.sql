CREATE PROCEDURE check_embeds_fields_limit(embedIds INT[])
LANGUAGE plpgsql
AS $$
BEGIN
	IF EXISTS( SELECT 1 FROM embeds_view WHERE id = ANY(embedIds) AND COALESCE(ARRAY_LENGTH(fields, 1), 0) > 25 ) THEN
		RAISE EXCEPTION SQLSTATE '21000' USING
			MESSAGE = 'MaxChildren Constraint violation',
			DETAIL = 'You cannot have more than 25 fields for one embed',
			HINT = 'Please, remove any excessive fields';
	END IF;
END $$;


CREATE FUNCTION embed_fields_fieldlimit_check() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE AS $$
DECLARE
	embedIds INT[];
BEGIN
	SELECT ARRAY_AGG(DISTINCT embed_id) FROM NEWTABLE INTO embedIds;
	CALL check_embeds_fields_limit(embedIds);
	RETURN NEW;
END $$;

CREATE TRIGGER fields_insert_embed_check_fieldlimit_trigger AFTER INSERT ON fields
REFERENCING NEW TABLE AS NEWTABLE FOR EACH STATEMENT EXECUTE FUNCTION embed_fields_fieldlimit_check();

CREATE TRIGGER fields_update_embed_check_fieldlimit_trigger AFTER UPDATE ON fields
REFERENCING NEW TABLE AS NEWTABLE FOR EACH STATEMENT EXECUTE FUNCTION embed_fields_fieldlimit_check();