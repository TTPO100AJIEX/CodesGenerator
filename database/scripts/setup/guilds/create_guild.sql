CREATE PROCEDURE create_guild(l_id DISCORD_ID, l_locale LOCALE, l_owner DISCORD_ID)
LANGUAGE plpgsql AS $$
DECLARE
	embed_id INT;
	message_id INT;
BEGIN
	CASE l_locale
		WHEN 'RU' THEN

			-- TODO


		WHEN 'EN' THEN
			INSERT INTO guilds (id, active, locale, owner, newusers_buttonlabel, giveaways_buttonlabel, autochannels_name)
				VALUES (l_id, true, l_locale, l_owner, 'Remove the newbie role', 'Participate', 'Channel of {{displayName}}');

			INSERT INTO messages(guild_id, name, content) VALUES (l_id, 'Welcome message', 'Welcome to the server!') RETURNING id INTO message_id;
			UPDATE guilds SET newusers_dmmessage = message_id WHERE id = l_id;

			INSERT INTO embeds(guild_id, name, color, title) VALUES (l_id, 'Ban message embed', x'ff0000'::INT, 'You have been banned!') RETURNING id INTO embed_id;
			INSERT INTO fields(embed_id, name, value) VALUES (embed_id, 'Reason:', '{{reason}}'), (embed_id, 'Moderator:', '{{author}} ({{authorId}})');
			INSERT INTO messages(guild_id, name) VALUES (l_id, 'Ban message') RETURNING id INTO message_id;
			INSERT INTO embeds_used(message_id, embed_id) VALUES (message_id, embed_id);
			UPDATE guilds SET ban_banmessage = message_id WHERE id = l_id;

			INSERT INTO embeds(guild_id, name, color, title) VALUES (l_id, 'Unban message embed', x'00ff00'::INT, 'You have been unbanned!') RETURNING id INTO embed_id;
			INSERT INTO fields(embed_id, name, value) VALUES (embed_id, 'Reason:', '{{reason}}'), (embed_id, 'Moderator:', '{{author}} ({{authorId}})');
			INSERT INTO messages(guild_id, name) VALUES (l_id, 'Unban message') RETURNING id INTO message_id;
			INSERT INTO embeds_used(message_id, embed_id) VALUES (message_id, embed_id);
			UPDATE guilds SET ban_unbanmessage = message_id WHERE id = l_id;

			INSERT INTO embeds(guild_id, name, color, title) VALUES (l_id, 'Kick message embed', x'00ff00'::INT, 'You have been kicked!') RETURNING id INTO embed_id;
			INSERT INTO fields(embed_id, name, value) VALUES (embed_id, 'Reason:', '{{reason}}'), (embed_id, 'Moderator:', '{{author}} ({{authorId}})');
			INSERT INTO messages(guild_id, name) VALUES (l_id, 'Kick message') RETURNING id INTO message_id;
			INSERT INTO embeds_used(message_id, embed_id) VALUES (message_id, embed_id);
			UPDATE guilds SET kick_message = message_id WHERE id = l_id;

			INSERT INTO embeds(guild_id, name, color, title) VALUES (l_id, 'Mute message embed', x'ff8800'::INT, 'You have been muted!') RETURNING id INTO embed_id;
			INSERT INTO fields(embed_id, name, value) VALUES (embed_id, 'Reason:', '{{reason}}'), (embed_id, 'Moderator:', '{{author}} ({{authorId}})'), (embed_id, 'Duration:', '{{duration}}');
			INSERT INTO messages(guild_id, name) VALUES (l_id, 'Mute message') RETURNING id INTO message_id;
			INSERT INTO embeds_used(message_id, embed_id) VALUES (message_id, embed_id);
			UPDATE guilds SET mute_mutemessage = message_id WHERE id = l_id;

			INSERT INTO embeds(guild_id, name, color, title) VALUES (l_id, 'Unmutes message embed', x'ff8800'::INT, 'You have been unmuted!') RETURNING id INTO embed_id;
			INSERT INTO fields(embed_id, name, value) VALUES (embed_id, 'Reason:', '{{reason}}'), (embed_id, 'Moderator:', '{{author}} ({{authorId}})');
			INSERT INTO messages(guild_id, name) VALUES (l_id, 'Unmute message') RETURNING id INTO message_id;
			INSERT INTO embeds_used(message_id, embed_id) VALUES (message_id, embed_id);
			UPDATE guilds SET mute_endmessage = message_id WHERE id = l_id;
			
			INSERT INTO messages(guild_id, name, content) VALUES (l_id, 'Auto ban message', 'You have been banned for getting to many mutes!') RETURNING id INTO message_id;
			UPDATE guilds SET mute_autobanmessage = message_id WHERE id = l_id;

			INSERT INTO embeds(guild_id, name, color, title) VALUES (l_id, 'Warn message embed', x'ffff00'::INT, 'You have been warned!') RETURNING id INTO embed_id;
			INSERT INTO fields(embed_id, name, value) VALUES (embed_id, 'Reason:', '{{reason}}'), (embed_id, 'Moderator:', '{{author}} ({{authorId}})');
			INSERT INTO messages(guild_id, name) VALUES (l_id, 'Warn message') RETURNING id INTO message_id;
			INSERT INTO embeds_used(message_id, embed_id) VALUES (message_id, embed_id);
			UPDATE guilds SET warn_message = message_id WHERE id = l_id;
			
			INSERT INTO messages(guild_id, name, content) VALUES (l_id, 'Auto mute message', 'You have been muted for getting to many warns!') RETURNING id INTO message_id;
			UPDATE guilds SET warn_automutemessage = message_id WHERE id = l_id;
			
			INSERT INTO embeds(guild_id, name, color, title) VALUES (l_id, 'Giveaways winners embed', x'0000ff'::INT, 'The giveaway has ended!') RETURNING id INTO embed_id;
			INSERT INTO fields(embed_id, name, value) VALUES (embed_id, 'Winners:', '{{winners_list}}');
			INSERT INTO messages(guild_id, name) VALUES (l_id, 'Giveaways winners message') RETURNING id INTO message_id;
			INSERT INTO embeds_used(message_id, embed_id) VALUES (message_id, embed_id);
			UPDATE guilds SET giveaways_winnersmessage = message_id WHERE id = l_id;
	END CASE;
END $$;
