CREATE FUNCTION table_columns(tablename TEXT) RETURNS TABLE(attname TEXT)
LANGUAGE SQL STABLE LEAKPROOF STRICT PARALLEL SAFE
AS $$
	SELECT pg_attribute.attname
	FROM pg_attribute INNER JOIN pg_type ON pg_attribute.attrelid = pg_type.typrelid
	WHERE pg_type.typname = tablename AND pg_attribute.attnum > 0
	ORDER BY pg_attribute.attnum;
$$;