CREATE TYPE ECONOMICS_MARKET_RULE_TYPE AS ENUM ('ALLOW', 'DENY');
CREATE TYPE INVENTORY_RULE_TYPE AS ENUM ('ALLOW', 'DENY');

CREATE TABLE guilds
(
    id DISCORD_ID PRIMARY KEY,
    active BOOL NOT NULL DEFAULT FALSE,
    locale LOCALE NOT NULL DEFAULT 'EN',
    owner DISCORD_ID NOT NULL,

    balance NUMERIC NOT NULL DEFAULT 50, /* TODO */
    last_balance_update TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    systemchannel DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id, systemchannel) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,


    enhanced_economics_subscription TIMESTAMPTZ,
    reduced_commission_subscription TIMESTAMPTZ,


    newusers_active BOOL NOT NULL DEFAULT FALSE, /* TODO */
    newusers_subscription TIMESTAMPTZ,
    newusers_role DISCORD_ID REFERENCES roles(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    newusers_interval INTERVAL CHECK(newusers_interval >= '10 minutes'),
    newusers_dmmessage INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    newusers_buttonlabel VARCHAR(80),
    newusers_buttonemoji VARCHAR(20),
    newusers_buttonstyle DISCORD_BUTTON_STYLE NOT NULL DEFAULT 'PRIMARY',
    FOREIGN KEY (id, newusers_role) REFERENCES roles(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, newusers_dmmessage) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,

    bannercounter_active BOOL NOT NULL DEFAULT FALSE,
    bannercounter_subscription TIMESTAMPTZ,
    bannercounter_background URL NOT NULL DEFAULT 'https://example.com',
    bannercounter_fontcolor COLOR NOT NULL DEFAULT 16777215,
    bannercounter_font FONT NOT NULL DEFAULT '2px solid sans-serif',
    bannercounter_total_top SMALLINT NOT NULL DEFAULT -1,
    bannercounter_total_left SMALLINT NOT NULL DEFAULT -1,
    bannercounter_online_top SMALLINT NOT NULL DEFAULT -1,
    bannercounter_online_left SMALLINT NOT NULL DEFAULT -1,
    bannercounter_voice_top SMALLINT NOT NULL DEFAULT -1,
    bannercounter_voice_left SMALLINT NOT NULL DEFAULT -1,

    logging_active BOOL NOT NULL DEFAULT FALSE,
    logging_subscription TIMESTAMPTZ,
    logging_guild DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_ban DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_member DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_scheduledevent DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_role DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_textchannel DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_voicechannel DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_thread DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_stageinstance DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_message DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_messagereaction DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_emoji DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_sticker DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_invite DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    logging_voice DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id, logging_guild) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_ban) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_member) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_scheduledevent) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_role) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_textchannel) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_voicechannel) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_thread) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_stageinstance) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_message) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_messagereaction) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_emoji) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_sticker) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_invite) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, logging_voice) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,

    giveaways_active BOOL NOT NULL DEFAULT FALSE,
    giveaways_subscription TIMESTAMPTZ,
    giveaways_buttonlabel VARCHAR(80),
    giveaways_buttonemoji VARCHAR(20) DEFAULT '🎉',
    giveaways_buttonstyle DISCORD_BUTTON_STYLE NOT NULL DEFAULT 'PRIMARY',
    giveaways_winnersmessage INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id, giveaways_winnersmessage) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    
    autochannels_active BOOL NOT NULL DEFAULT FALSE,
    autochannels_subscription TIMESTAMPTZ,
    autochannels_channel DISCORD_ID REFERENCES voicechannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    autochannels_name VARCHAR(100) NOT NULL CHECK (LENGTH(autochannels_name) > 0),
    autochannels_limit USMALLINT NOT NULL DEFAULT 2 CHECK(autochannels_limit < 100),
    FOREIGN KEY (id, autochannels_channel) REFERENCES voicechannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,


    rolemanagement_active BOOL NOT NULL DEFAULT FALSE,
    rolemanagement_subscription TIMESTAMPTZ,
    rolemanagement_logging DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id, rolemanagement_logging) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,

    inventory_active BOOL NOT NULL DEFAULT FALSE,
    inventory_subscription TIMESTAMPTZ,
    inventory_ruletype INVENTORY_RULE_TYPE NOT NULL DEFAULT 'ALLOW',

    activityroles_active BOOL NOT NULL DEFAULT FALSE,
    activityroles_subscription TIMESTAMPTZ,
    activityroles_voicetime_remove_old BOOL NOT NULL DEFAULT TRUE,
    activityroles_message_remove_old BOOL NOT NULL DEFAULT TRUE,

    donationroles_active BOOL NOT NULL DEFAULT FALSE,
    donationroles_subscription TIMESTAMPTZ,


    ban_active BOOL NOT NULL DEFAULT FALSE,
    ban_subscription TIMESTAMPTZ,
    ban_logging DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    ban_minreasonlength POSITIVE_SMALLINT NOT NULL CHECK (ban_minreasonlength <= 1024) DEFAULT 10,
    ban_banmessage INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    ban_unbanmessage INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id, ban_logging) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, ban_banmessage) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, ban_unbanmessage) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,

    kick_active BOOL NOT NULL DEFAULT FALSE,
    kick_subscription TIMESTAMPTZ,
    kick_logging DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    kick_minreasonlength POSITIVE_SMALLINT NOT NULL CHECK (kick_minreasonlength <= 1024) DEFAULT 10,
    kick_message INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id, kick_logging) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, kick_message) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    
    mute_active BOOL NOT NULL DEFAULT FALSE,
    mute_subscription TIMESTAMPTZ,
    mute_logging DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    mute_minreasonlength POSITIVE_SMALLINT NOT NULL CHECK (mute_minreasonlength <= 1024) DEFAULT 10,
    mute_minduration INTERVAL NOT NULL DEFAULT '1 minute' CHECK (mute_minduration >= '30 seconds' AND mute_minduration <= '28 days'),
    mute_mutemessage INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    mute_endmessage INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    mute_toban USMALLINT NOT NULL DEFAULT 0,
    mute_autobanmessage INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id, mute_logging) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, mute_mutemessage) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, mute_endmessage) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, mute_autobanmessage) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    
    warn_active BOOL NOT NULL DEFAULT FALSE,
    warn_subscription TIMESTAMPTZ,
    warn_logging DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    warn_minreasonlength POSITIVE_SMALLINT NOT NULL CHECK (warn_minreasonlength <= 1024) DEFAULT 10,
    warn_message INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    warn_tomute USMALLINT NOT NULL DEFAULT 0,
    warn_automutemessage INT REFERENCES messages(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    warn_automuteduration INTERVAL NOT NULL DEFAULT '1 day' CHECK (warn_automuteduration >= '30 seconds' AND warn_automuteduration <= '28 days'),
    FOREIGN KEY (id, warn_logging) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, warn_message) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (id, warn_automutemessage) REFERENCES messages(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,
    
    report_active BOOL NOT NULL DEFAULT FALSE,
    report_subscription TIMESTAMPTZ,
    report_channel DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    report_minreasonlength POSITIVE_SMALLINT NOT NULL CHECK (report_minreasonlength <= 1024) DEFAULT 10,
    FOREIGN KEY (id, report_channel) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,

    economics_active BOOL NOT NULL DEFAULT FALSE,
    economics_subscription TIMESTAMPTZ,
    economics_voicecoins UINT NOT NULL DEFAULT 1,
    economics_voiceinterval INTERVAL NOT NULL DEFAULT '1 minute' CHECK (economics_voiceinterval > '5 seconds'),
    CHECK (economics_voicecoins / EXTRACT(EPOCH FROM economics_voiceinterval) <= 1),
    economics_messagecoins UINT NOT NULL DEFAULT 1,
    economics_messageinterval POSITIVE_SMALLINT NOT NULL DEFAULT 1,
    CHECK (economics_messagecoins / economics_messageinterval <= 1),
    economics_timedupdateinterval INTERVAL NOT NULL DEFAULT '1 day' CHECK (economics_timedupdateinterval >= '1 hour'),
    economics_timedupdatenext TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    economics_buycoins_active BOOL NOT NULL DEFAULT FALSE,
    economics_buycoins_coins_0 POSITIVE_INT NOT NULL DEFAULT 2000,
    economics_buycoins_max_discount PERCENTAGE NOT NULL DEFAULT 30 CHECK (economics_buycoins_max_discount > 1),
    economics_buycoins_min_discount_point NUMERIC NOT NULL DEFAULT 5,
    economics_buycoins_mid_point NUMERIC NOT NULL DEFAULT 30,
    CHECK (economics_buycoins_mid_point > economics_buycoins_min_discount_point),

    economics_send_active BOOL NOT NULL DEFAULT FALSE,
    economics_send_sendtax PERCENTAGE NOT NULL DEFAULT 0,
    economics_send_minsend POSITIVE_INT NOT NULL DEFAULT 1,
    economics_send_logging DISCORD_ID REFERENCES textchannels(id) MATCH FULL ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id, economics_send_logging) REFERENCES textchannels(guild_id, id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT,

    economics_shop_active BOOL NOT NULL DEFAULT FALSE,
    economics_shop_subscription TIMESTAMPTZ,

    economics_market_active BOOL NOT NULL DEFAULT FALSE,
    economics_market_subscription TIMESTAMPTZ,
    economics_market_ruletype ECONOMICS_MARKET_RULE_TYPE NOT NULL DEFAULT 'ALLOW',

    economics_clans_active BOOL NOT NULL DEFAULT FALSE,
    economics_clans_subscription TIMESTAMPTZ,

    economics_events_active BOOL NOT NULL DEFAULT FALSE,
    economics_events_subscription TIMESTAMPTZ,

    economics_roll_active BOOL NOT NULL DEFAULT FALSE,
    economics_roll_subscription TIMESTAMPTZ,
    economics_roll_minbet POSITIVE_INT NOT NULL DEFAULT 1,
    economics_roll_maxbet POSITIVE_INT NOT NULL DEFAULT 2147483647 CHECK(economics_roll_maxbet >= economics_roll_minbet),

    economics_flip_active BOOL NOT NULL DEFAULT FALSE,
    economics_flip_subscription TIMESTAMPTZ,
    economics_flip_minbet POSITIVE_INT NOT NULL DEFAULT 1,
    economics_flip_maxbet POSITIVE_INT NOT NULL DEFAULT 2147483647 CHECK(economics_flip_maxbet >= economics_flip_minbet),

    economics_sos_active BOOL NOT NULL DEFAULT FALSE,
    economics_sos_subscription TIMESTAMPTZ,
    economics_sos_minbet POSITIVE_INT NOT NULL DEFAULT 1,
    economics_sos_maxbet POSITIVE_INT NOT NULL DEFAULT 2147483647 CHECK(economics_sos_maxbet >= economics_sos_minbet),
    economics_sos_botbet POSITIVE_NUMBER NOT NULL DEFAULT 3 CHECK(economics_sos_botbet > 1 AND economics_sos_botbet <= 10)
);
CREATE INDEX guilds_active_index ON guilds(active);
CREATE INDEX guilds_owner_index ON guilds(owner);
CREATE INDEX guilds_last_balance_update_index ON guilds(last_balance_update);
CREATE INDEX guilds_economics_active_index ON guilds(economics_active);
CREATE INDEX guilds_economics_timedupdatenext_index ON guilds(economics_timedupdatenext);


CREATE FUNCTION guilds_activation() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT PARALLEL SAFE AS $$
BEGIN
	NEW.last_balance_update = NOW();
	RETURN NEW;
END $$;

CREATE TRIGGER guilds_activation_trigger BEFORE UPDATE OF active ON guilds
FOR EACH ROW WHEN (OLD.active = false AND NEW.active = true) EXECUTE FUNCTION guilds_activation();