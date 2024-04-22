CREATE VIEW embeds_view AS
	SELECT
        embeds.*,
        embeds_used.message_id,
		ARRAY(SELECT row_to_json(fields.*) FROM fields WHERE fields.embed_id = embeds.id) AS fields,
		char_length(COALESCE(title, '')) + char_length(COALESCE(description, '')) + char_length(COALESCE(author_name, '')) + char_length(COALESCE(footer_text, '')) +
			( SELECT COALESCE(SUM(length)::integer, 0) FROM fields_view WHERE embed_id = embeds.id ) AS length
	FROM embeds
	LEFT OUTER JOIN embeds_used ON embeds_used.embed_id = embeds.id;



CALL create_json_casts('embeds_view', 'embeds');
CALL create_json_casts('embeds_view', 'embeds_data');



CREATE RULE embeds_view_insert_override AS ON INSERT TO embeds_view DO INSTEAD
	INSERT INTO embeds OVERRIDING USER VALUE VALUES ((NEW::embeds).*) RETURNING ((embeds::embeds_view).*);



CREATE FUNCTION embeds_view_update() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE
AS $$
BEGIN
	EXECUTE 'UPDATE embeds
			SET (' || (SELECT string_agg(format('%I', attname), ',') FROM table_columns('embeds_data')) || ') = ROW($1.*)
			WHERE id = $2' USING NEW::embeds_data, NEW.id;
	RETURN NEW;
END $$;
CREATE TRIGGER embeds_view_update_trigger INSTEAD OF UPDATE ON embeds_view FOR EACH ROW EXECUTE FUNCTION embeds_view_update();


    
CREATE RULE embeds_view_delete_override AS ON DELETE TO embeds_view DO INSTEAD DELETE FROM embeds WHERE id = OLD.id;