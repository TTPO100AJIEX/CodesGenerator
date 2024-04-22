CREATE PROCEDURE add_timed_role(guildId DISCORD_ID, memberId DISCORD_ID, roleId DISCORD_ID, action DISCORD_ROLE_ACTION, duration INTERVAL)
LANGUAGE SQL AS
$$
	INSERT INTO timedroles(guild_id, member_id, role_id, action, timestamp)
	VALUES (guildId, memberId, roleId, action, NOW() + duration)
	ON CONFLICT (guild_id, member_id, role_id) DO UPDATE SET
		action = excluded.action,
		timestamp = (
			CASE WHEN timedroles.action != excluded.action THEN excluded.timestamp
			ELSE GREATEST(timedroles.timestamp, excluded.timestamp) END
		);
$$;