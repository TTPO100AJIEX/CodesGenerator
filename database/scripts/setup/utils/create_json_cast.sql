CREATE PROCEDURE create_json_cast(from_type TEXT, to_type TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
	EXECUTE format('CREATE FUNCTION %2$I(input %1$I) RETURNS %2$I
					LANGUAGE SQL STABLE LEAKPROOF STRICT PARALLEL SAFE
					RETURN ( SELECT jsonb_populate_record(NULL::%2$I, to_jsonb(input)) )', from_type, to_type);
	EXECUTE format('CREATE CAST (%1$I AS %2$I) WITH FUNCTION %2$I(%1$I)', from_type, to_type);
END $$;


CREATE PROCEDURE create_json_casts(first_type TEXT, second_type TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    CALL create_json_cast(first_type, second_type);
    CALL create_json_cast(second_type, first_type);
END $$;