CREATE FUNCTION user_admin(guildId DISCORD_ID, userId DISCORD_ID, userRoles DISCORD_ID[]) RETURNS BOOL
LANGUAGE SQL STABLE LEAKPROOF STRICT PARALLEL SAFE
RETURN (SELECT owner = userId OR (userRoles && websiteaccess) FROM guilds_view WHERE id = guildId);