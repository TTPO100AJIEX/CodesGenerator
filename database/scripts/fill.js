import Discord from "discord.js";
const INTERVAL_LIMIT = 5 * 365 * 24 * 60 * 60 * 1000;
import guilds from './data/guilds.json' assert { type: "json" };
import { Database } from "common/databases/PostgreSQL/PostgreSQL.js";
import config from "common/configs/config.json" assert { type: "json" };

import fixURL from "./fill-utils/fixURL.js";
import getRoles from "./fill-utils/getRoles.js";
import parseRights from "./fill-utils/parseRights.js";
import getTextChannels from "./fill-utils/getTextChannels.js";
import getVoiceChannels from "./fill-utils/getVoiceChannels.js";
import getCategoryChannels from "./fill-utils/getCategoryChannels.js";

const GUILD_FIELDS = `
id, active, locale, owner,
balance, last_balance_update, systemchannel,
enhanced_economics_subscription, reduced_commission_subscription,

newusers_active, newusers_subscription, newusers_role, newusers_interval, newusers_dmmessage, newusers_buttonlabel, newusers_buttonemoji, newusers_buttonstyle,
bannercounter_active, bannercounter_subscription, bannercounter_background, bannercounter_fontcolor, bannercounter_font,
    bannercounter_total_top, bannercounter_total_left, bannercounter_online_top, bannercounter_online_left, bannercounter_voice_top, bannercounter_voice_left,
logging_active, logging_subscription, logging_guild, logging_ban, logging_member, logging_scheduledevent, logging_role, logging_textchannel, logging_voicechannel,
    logging_thread, logging_stageinstance, logging_message, logging_messagereaction, logging_emoji, logging_sticker, logging_invite, logging_voice,
giveaways_active, giveaways_subscription, giveaways_buttonlabel, giveaways_buttonemoji, giveaways_buttonstyle, giveaways_winnersmessage,
autochannels_active, autochannels_subscription, autochannels_channel, autochannels_name, autochannels_limit,
  
rolemanagement_active, rolemanagement_subscription, rolemanagement_logging,
inventory_active, inventory_subscription, inventory_ruletype,
activityroles_active, activityroles_subscription, activityroles_voicetime_remove_old, activityroles_message_remove_old,
donationroles_active, donationroles_subscription,

ban_active, ban_subscription, ban_logging, ban_minreasonlength, ban_banmessage, ban_unbanmessage,
kick_active, kick_subscription, kick_logging, kick_minreasonlength, kick_message,
mute_active, mute_subscription, mute_logging, mute_minreasonlength, mute_minduration, mute_mutemessage, mute_endmessage, mute_toban, mute_autobanmessage,
warn_active, warn_subscription, warn_logging, warn_minreasonlength, warn_message, warn_tomute, warn_automutemessage, warn_automuteduration,
report_active, report_subscription, report_channel, report_minreasonlength,

economics_active, economics_subscription, economics_voicecoins, economics_voiceinterval, economics_messagecoins, economics_messageinterval, economics_timedupdateinterval, economics_timedupdatenext,
economics_buycoins_active, economics_buycoins_coins_0, economics_buycoins_max_discount, economics_buycoins_min_discount_point, economics_buycoins_mid_point,
economics_send_active, economics_send_sendtax, economics_send_minsend, economics_send_logging,
economics_shop_active, economics_shop_subscription,
economics_market_active, economics_market_subscription, economics_market_ruletype,
economics_clans_active, economics_clans_subscription,
economics_events_active, economics_events_subscription,
economics_roll_active, economics_roll_subscription, economics_roll_minbet, economics_roll_maxbet,
economics_flip_active, economics_flip_subscription, economics_flip_minbet, economics_flip_maxbet,
economics_sos_active, economics_sos_subscription, economics_sos_minbet, economics_sos_maxbet, economics_sos_botbet`;

const bot = new Discord.Client({ "intents": [ Discord.IntentsBitField.Flags.Guilds ] });
bot.on('ready', async () => 
{
    console.log('Bot started');
    let message_id = 0, embed_id = 0;
    let QUERIES = {
        "guilds": [ ],
        "roles": [ ],
        "textchannels": [ ],
        "voicechannels": [ ],
        "categorychannels": [ ],
        "fields": [ ],
        "embeds": [ ],
        "messages": [ ],
        "embeds_used": [ ],
        "websiteaccess": [ ],
        "members": [ ],
        "timed_roles": [ ],
        "mutes": [ ],
        "warns": [ ],
        "message_activityroles": [ ],
        "voicetime_activityroles": [ ],
        "shop": [ ],
        "economics_market_roles": [ ],
        "economics_market": [ ],
        "clans_levels": [ ],
        "clans": [ ],
        "clans_deputies": [ ],
        "events": [ ],
        "rolemanagement_rules": [ ],
        "inventory_roles": [ ],
        "inventory": [ ],
        "donationroles": [ ],
        "giveaways": [ ],
        "giveaways_participants": [ ]
    };
    for (const guild of guilds)
    {
        const roles = await getRoles(bot, guild.id);
        const textchannels = await getTextChannels(bot, guild.id);
        const voicechannels = await getVoiceChannels(bot, guild.id);
        const categorychannels = await getCategoryChannels(bot, guild.id);
        
        QUERIES.roles = QUERIES.roles.concat(roles);
        QUERIES.textchannels = QUERIES.textchannels.concat(textchannels);
        QUERIES.voicechannels = QUERIES.voicechannels.concat(voicechannels);
        QUERIES.categorychannels = QUERIES.categorychannels.concat(categorychannels);
        QUERIES.websiteaccess = QUERIES.websiteaccess.concat(parseRights(bot, guild.id, guild.data.rights[guild.settings.website_access]));
        
        let embed_indexes = new Map();
        for (let j = 0; j < guild.data.embeds.length; j++)
        {
            const embed = guild.data.embeds[j]; embed_id++;
            const length = (embed.title ?? "").length + (embed.description ?? "").length + (embed.author?.name ?? "").length + (embed.footer?.text ?? "").length + 
                            (embed.fields ?? []).reduce((prev, cur) => prev + (cur.name ?? "").length + (cur.value ?? "").length, 0);
            if (length == 0) embed.title = "EMPTY EMBED";
            QUERIES.embeds.push(Database.format(`(%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L)`, 
                embed_id, guild.id, `UnnamedEmbed${embed_id}`, embed.title, embed.description, embed.url, parseInt(embed.color.substring(1), 16),
                embed.author?.name, embed.author?.url, embed.author?.picture, embed.thumbnail, embed.image, embed.footer?.text, embed.footer?.picture)
            );
            embed_indexes.set(j, embed_id);
            for (let x = 0; x < (embed.fields ?? []).length; x++)
            {
                QUERIES.fields.push([ embed_id, embed.fields[x].title, embed.fields[x].content, embed.fields[x].inline ?? false ]);
            }
        }

        let message_indexes = new Map();
        for (let j = 0; j < guild.data.messages.length; j++)
        {
            const message = guild.data.messages[j]; message_id++;
            if ((message.content ?? "").length == 0 && (message.embeds ?? []).length == 0) message.content = "EMPTY MESSAGE";
            QUERIES.messages.push([ message_id, guild.id, `UnnamedMessage${message_id}`, message.content, false ]);
            message_indexes.set(j, message_id);

            message.embeds ??= [];
            for (let i = 0; i < (message.embeds ?? []).length; i++)
            {
                QUERIES.embeds_used.push([ message_id, embed_indexes.get(message.embeds[i]) ])
            }
        }
        
        embed_id++;
        message_id++;
        const giveaways_winnersmessage = message_id;
        QUERIES.embeds_used.push([ message_id, embed_id ]);
        QUERIES.fields.push([ embed_id, "Winners", "{{winners_list}}", false ]);
        QUERIES.messages.push([ message_id, guild.id, `Giveaways winners message`, null, false ]);
        QUERIES.embeds.push(`(${embed_id}, ${guild.id}, 'Giveaways winners embed', 'The giveaway has ended!', NULL, NULL, x'0000ff'::INT, NULL, NULL, NULL, NULL, NULL, NULL, NULL)`);
        

        function textchannel(id) { return textchannels.some(e => e[1] == id) ? id : null; }
        function voicechannel(id) { return voicechannels.some(e => e[1] == id) ? id : null; }
        function categorychannel(id) { return categorychannels.some(e => e[1] == id) ? id : null; }
        function role(id) { return roles.some(role => role[1] == id) ? id : null; }
        function message(id) { return message_indexes.get(id); }
        
        function interval(ms, discard_big = false)
        {
            if (discard_big && ms > INTERVAL_LIMIT) return undefined;
            return `${Math.min(Math.max(ms / 1000, 60), 1e9)}s`;
        }
        function color(color) { return parseInt(color.slice(1), 16); }
        function clamp(min, val, max) { return Math.max(min, Math.min(val, max)); }

        guild.logs = Object.fromEntries(guild.data.logs.logs.map(log => [ log.name, log.channel ]));
        guild.commands = Object.fromEntries(guild.data.commands.map(command => [ `${command.module}${command.name}`, command ]));
        
        QUERIES.guilds.push([
            guild.id, bot.guilds.resolve(guild.id) ? true : false, guild.locale == "ru" ? "RU" : "EN", bot.guilds.resolve(guild.id)?.ownerId ?? "387653546134208513",
            guild.balance, new Date(), textchannel(guild.systemchannel),
            null, null,

            guild.settings.newUsers.status == "on", null, role(guild.settings.newUsers.role), interval(Math.max(guild.settings.newUsers.time, 10 * 60 * 1000), true),
                message(guild.settings.newUsers.message), guild.settings.newUsers.button_label, null, 'PRIMARY',
            guild.settings.bannerCounter.status == "on", null, fixURL(guild.settings.bannerCounter.background), color(guild.settings.bannerCounter.color), guild.settings.bannerCounter.font,
                guild.settings.bannerCounter.all.y, guild.settings.bannerCounter.all.x, guild.settings.bannerCounter.online.y,
                guild.settings.bannerCounter.online.x, guild.settings.bannerCounter.voice.y, guild.settings.bannerCounter.voice.x,
            guild.settings.logs.status == "on", null, textchannel(guild.logs.guildUpdate), textchannel(guild.logs.guildBanAdd), textchannel(guild.logs.guildMemberAdd), null,
                textchannel(guild.logs.roleCreate), textchannel(guild.logs.channelCreate), textchannel(guild.logs.channelCreate), null, null,
                textchannel(guild.logs.messageUpdate) || textchannel(guild.logs.messageDelete), textchannel(guild.logs.messageReactionRemove), textchannel(guild.logs.emojiCreate),
                null, textchannel(guild.logs.inviteCreate), textchannel(guild.logs.voiceStateUpdate),
            guild.settings.giveaways.status == "on", null, guild.locale == "ru" ? "Участвовать" : "Participate", "🎉", 'PRIMARY', giveaways_winnersmessage,
            guild.settings.autochannels.status == "on", null, voicechannel(guild.data.autochannels.rules[0]?.channel),
                (guild.data.autochannels.rules[0]?.name ?? (guild.locale == "ru" ? "Канал {{displayName}}" : "Channel of {{displayName}}")).replaceAll("{{name}}", "{{displayName}}"),
                guild.data.autochannels.rules[0]?.limit ?? 0,

            guild.settings.customRoles.status == "on", null, textchannel(guild.commands.custom_rolesgiverole.extra.logs) || textchannel(guild.commands.custom_rolesremoverole.extra.logs),
            guild.settings.inventory.status == "on", null, guild.settings.inventory.type == 0 ? "DENY" : "ALLOW",
            guild.settings.roleRulesets.status == "on", null, guild.settings.roleRulesets.hours.some(rule => rule.type), guild.settings.roleRulesets.messages.some(rule => rule.type),
            guild.settings.donations.status == "on", null,

            guild.settings.ban.status == "on", null, textchannel(guild.commands.moderationban.extra.logs), clamp(1, guild.commands.moderationban.extra.minReason, 1024),
                message(guild.commands.moderationban.extra.message), message(guild.commands.moderationunban.extra.message),
            guild.settings.kick.status == "on", null, textchannel(guild.commands.moderationkick.extra.logs), clamp(1, guild.commands.moderationkick.extra.minReason, 1024),
                message(guild.commands.moderationkick.extra.message),
            guild.settings.mute.status == "on", null, textchannel(guild.commands.moderationmute.extra.logs), clamp(1, guild.commands.moderationmute.extra.minReason, 1024),
                interval(clamp(30 * 1000, guild.commands.moderationmute.extra.minTime, 28 * 24 * 60 * 60 * 1000)), message(guild.commands.moderationmute.extra.message),
                message(guild.commands.moderationunmute.extra.message), guild.settings.mute.toBan > 32767 ? 0 : Math.max(0, guild.settings.mute.toBan),
                message(guild.settings.mute.autoBanMessage),
            guild.settings.warn.status == "on", null, textchannel(guild.commands.moderationwarn.extra.logs), clamp(1, guild.commands.moderationwarn.extra.minReason, 1024),
                message(guild.commands.moderationwarn.extra.message), guild.settings.warn.toMute > 32767 ? 0 : Math.max(0, guild.settings.warn.toMute),
                message(guild.settings.warn.autoMuteMessage), interval(clamp(30 * 1000, guild.settings.warn.autoMuteTime, 28 * 24 * 60 * 60 * 1000)),
            guild.settings.report.status == "on", null, textchannel(guild.commands.moderationreport.extra.logs), clamp(1, guild.commands.moderationreport.extra.minReason, 1024),
            
            guild.settings.coins.status == "on", null, Math.min(guild.settings.coins.perMinutes.coins, guild.settings.coins.perMinutes.minutes / 1000),
                interval(guild.settings.coins.perMinutes.minutes), Math.min(guild.settings.coins.perMessage, 1), 1,
                interval(Math.max(guild.settings.coins.update, 60 * 60 * 1000)), new Date(guild.settings.coins.next_update),
            true, 2000, 30, 5, 30,
            guild.commands.coinssend.active, clamp(0, guild.commands.coinssend.extra.tax ?? 0, 100), guild.commands.coinssend.extra.min,
                textchannel(guild.commands.coinssend.extra.logs) ?? textchannel(guild.commands.coinsaddcoins.extra.logs) ?? textchannel(guild.commands.coinsaddhours.extra.logs) ?? textchannel(guild.commands.coinsaddmessages.extra.logs),
            guild.settings.shop.status == "on", null,
            guild.settings.market.status == "on", null, guild.settings.market.type == 0 ? "DENY" : "ALLOW",
            guild.settings.custom_commands?.roles?.status == "on", null,
            guild.settings.custom_commands?.events?.status == "on", null,
            guild.settings.roll.status == "on", null, Math.max(guild.commands.coins_gamesroll.extra.min, 1), Math.max(guild.commands.coins_gamesroll.extra.max, guild.commands.coins_gamesroll.extra.min, 1),
            guild.settings.flip.status == "on", null, Math.max(guild.commands.coins_gamesflip.extra.min, 1), Math.max(guild.commands.coins_gamesflip.extra.max, guild.commands.coins_gamesflip.extra.min, 1),
            guild.settings.sos.status == "on", null, Math.max(guild.commands.coins_gamessos.extra.min, 1), Math.max(guild.commands.coins_gamessos.extra.max, guild.commands.coins_gamessos.extra.min, 1), clamp(1.01, guild.commands.coins_gamessos.extra.botBet, 10),
        ]);
        

        for (const member of guild.data.members)
        {
            QUERIES.members.push([
                guild.id, member.id,
                interval(member.time ?? 0), clamp(0, member.coins ?? 0, 1e8), clamp(0, member.messages ?? 0, 1e8), interval(member.hours ?? 0),
                Math.min(member.coins_timed ?? 0, 2147483647), Math.min(member.messages_timed ?? 0, 2147483647), interval(member.hours_timed ?? 0), null
            ]);

            for (const mute of (member.mutes ?? [ ]))
            {
                QUERIES.mutes.push([ guild.id, member.id, mute.text, interval(mute.duration), new Date(mute.time) ]);
            }
            for (const warn of (member.warns ?? [ ]))
            {
                QUERIES.warns.push([ guild.id, member.id, warn.text, new Date(warn.time) ]);
            }
            for (const role_id of (member.inventory ?? [ ]))
            {
                if (!role(role_id)) continue;
                const record = QUERIES.inventory.find(el => el[0] == guild.id && el[1] == member.id && el[2] == role(role_id));
                if (!record) QUERIES.inventory.push([ guild.id, member.id, role(role_id), 1 ]);
                else record[3]++;
            }
        }

        for (const timed_role of guild.data.timed_roles)
        {
            for (const rule of timed_role.roles.filter(e => roles.some(role => role[1] == e.role)))
            {
                if (new Date(rule.remove_time) > new Date(Date.now() + INTERVAL_LIMIT)) continue;
                QUERIES.timed_roles.push([ guild.id, timed_role.member, role(rule.role), "REMOVE", interval(rule.remove_time - Date.now()) ]);
            }
        }

        for (const rule of guild.settings.roleRulesets.hours)
        {
            if (!role(rule.id) || rule.min <= 0 || rule.max <= rule.min) continue;
            QUERIES.message_activityroles.push([ rule.id, interval(rule.min * 60 * 60 * 1000), interval(rule.max * 60 * 60 * 1000) ]);
        }
        for (const rule of guild.settings.roleRulesets.messages)
        {
            if (!role(rule.id) || rule.min <= 0 || rule.max <= rule.min) continue;
            QUERIES.voicetime_activityroles.push([ rule.id, rule.min, rule.max ]);
        }
        
        for (const rule of guild.data.shop.roles)
        {
            if (!role(rule.id)) continue;
            QUERIES.shop.push([ rule.id, rule.cost, rule.timer ? interval(Math.max(rule.timer, 60 * 60 * 1000), true) : undefined, rule.allow_undo ? -rule.return : undefined, undefined ]);
        }
        
        for (const rule of guild.data.customRoles.rules)
        {
            if (!role(rule.id)) continue;
            let permission;
            if (rule.type == 0) permission = "ADD";
            else if (rule.type == 1) permission = "REMOVE";
            else if (rule.type == 2) permission = "FULL";
            const managers = parseRights(bot, guild.id, guild.data.rights[rule.rights]);
            for (const manager_role_id of managers.map(manager => manager[1]))
            {
                QUERIES.rolemanagement_rules.push([ guild.id, role(rule.id), manager_role_id, permission ])
            }
        }
        
        for (const id of guild.data.market.allowed_roles)
        {
            if (!role(id)) continue;
            QUERIES.economics_market_roles.push([ guild.id, role(id) ]);
        }
        
        for (const record of guild.data.market.roles)
        {
            if (!role(record.role)) continue;
            QUERIES.economics_market.push([ guild.id, record.seller, role(record.role), record.price ]);
        }
        
        for (const record of guild.data.custom_commands?.roles?.levels ?? [ ])
        {
            QUERIES.clans_levels.push([
                guild.id, Math.max(record.price, 0), clamp(1, record.user_limit, 32767),
                Math.max(guild.settings.custom_commands?.roles?.rolePosition ?? guild.settings.custom_commands?.clans?.rolePosition ?? 0, 0), record.voice, 0,
                categorychannel(guild.settings.custom_commands?.roles?.voiceCategory) ?? categorychannel(guild.settings.custom_commands?.clans?.voiceCategory),
                true, true, true, interval(Math.max(guild.settings.custom_commands?.roles?.time ?? 0, 24 * 60 * 60 * 1000)),
                guild.settings.custom_commands?.roles?.prolong_cost ?? 2000, message(guild.settings.custom_commands?.roles?.prolong_message),
                interval(Math.max(guild.settings.custom_commands?.roles?.prolong_time ?? 0, 60 * 60 * 1000))
            ]);
        }
        for (const record of guild.data.custom_commands?.roles?.list ?? [ ])
        {
            if (!role(record.role)) continue;
            const duration_ms = Math.max(guild.settings.custom_commands?.roles?.time ?? 0, 24 * 60 * 60 * 1000);
            QUERIES.clans.push([
                QUERIES.clans.length + 1, guild.id, record.owner, record.level, new Date(record.delete - duration_ms),
                false, role(record.role), voicechannel(record.voice)
            ]);
        }
        for (const record of guild.data.custom_commands?.clans?.list ?? [ ])
        {
            if (!role(record.role)) continue;
            if (bot.channels.cache.has(record.text)) try { await bot.channels.cache.get(record.text).delete(); } catch(err) { }

            const level = (guild.data.custom_commands?.roles?.levels ?? [ ]).length;
            QUERIES.clans.push([
                QUERIES.clans.length + 1, guild.id, record.owner, level, new Date(), false, role(record.role), voicechannel(record.voice)
            ]);
            if (record.deputy) QUERIES.clans_deputies.push([ QUERIES.clans.length, record.deputy ]);
        }

        for (const event of guild.settings.custom_commands?.events?.events ?? [ ])
        {
            QUERIES.events.push([ guild.id, event.name, 1e5, "1d", message(event.message) ]);
        }
        
        for (const id of guild.data.inventory.allowed_roles)
        {
            if (!role(id)) continue;
            QUERIES.inventory_roles.push([ guild.id, role(id) ]);
        }
        
        for (const rule of guild.data.donations.rules)
        {
            if (!role(rule.role) || rule.price < 0) continue;
            switch(rule.type)
            {
                case 0:
                    QUERIES.donationroles.push([ rule.role, rule.price, undefined, undefined, undefined ]);
                    break;
                case 1:
                    QUERIES.donationroles.push([ rule.role, undefined, undefined, rule.price, undefined ]);
                    break;
                case 2:
                    QUERIES.donationroles.push([ rule.role, rule.price, undefined, rule.price, undefined ]);
                    break;
            }
        }

        for (const giveaway of guild.settings.giveaways.rules)
        {
            if (!textchannel(giveaway.channel)) continue;
            
            QUERIES.giveaways.push([
                guild.id, textchannel(giveaway.channel), giveaway.msg, interval(giveaway.length), clamp(1, giveaway.winners, 50), Math.max(0, giveaway.extra.participate_cost),
                Math.max(0, giveaway.extra.min_messages), Math.max(giveaway.extra.max_messages, giveaway.extra.min_messages),
                interval(giveaway.extra.min_hours * 60 * 60 * 1000), interval(giveaway.extra.max_hours * 60 * 60 * 1000), new Date(giveaway.start)
            ]);

            for (const user of giveaway.users)
            {
                QUERIES.giveaways_participants.push([ guild.id, QUERIES.giveaways.length, user ]);
            }
        }

        for (const { text, voice } of guild.data.autochannels.createdChannels)
        {
            const text_channel = bot.channels.cache.get(text);
            const voice_channel = bot.channels.cache.get(voice);
            if (text_channel) try { await text_channel.delete(); } catch(err) { }
            if (!voice_channel || !voicechannel(voice)) continue;
            if (voice_channel.members.size == 0) try { await voice_channel.delete(); } catch(err) { }
            const owner = voice_channel.members.at(0);
            const member = QUERIES.members.find(member => member[0] == guild.id && member[1] == owner.id);
            if (!member) QUERIES.members.push([ guild.id, owner.id, 0, 0, 0, 0, 0, 0, 0, voice_channel.id ]);
            member[9] = voice_channel.id;
        }
    }

    const batch = new Database.AnonymousBatch();

    if (QUERIES.guilds.length != 0) batch.execute(Database.format(`INSERT INTO guilds (id, owner, autochannels_name) VALUES %L`, QUERIES.guilds.map(guild => [ guild[0], "387653546134208513", "None" ])));
    if (QUERIES.roles.length != 0) batch.execute(Database.format(`INSERT INTO roles (guild_id, id, name) VALUES %L`, QUERIES.roles));
    if (QUERIES.textchannels.length != 0) batch.execute(Database.format(`INSERT INTO textchannels (guild_id, id, name) VALUES %L`, QUERIES.textchannels));
    if (QUERIES.voicechannels.length != 0) batch.execute(Database.format(`INSERT INTO voicechannels (guild_id, id, name) VALUES %L`, QUERIES.voicechannels));
    if (QUERIES.categorychannels.length != 0) batch.execute(Database.format(`INSERT INTO categorychannels (guild_id, id, name) VALUES %L`, QUERIES.categorychannels));
    if (QUERIES.websiteaccess.length != 0) batch.execute(Database.format(`INSERT INTO websiteaccess (guild_id, role_id) VALUES %L`, QUERIES.websiteaccess));
    
    if (QUERIES.embeds.length != 0) batch.execute(Database.format(`INSERT INTO embeds (id, guild_id, name, title, description, url, color, author_name, author_url, author_icon, thumbnail, image, footer_text, footer_icon) OVERRIDING SYSTEM VALUE VALUES %s`, QUERIES.embeds));
    if (QUERIES.messages.length != 0) batch.execute(Database.format(`INSERT INTO messages (id, guild_id, name, content, suppressembeds) OVERRIDING SYSTEM VALUE VALUES %L`, QUERIES.messages));
    if (QUERIES.fields.length != 0) batch.execute(Database.format(`INSERT INTO fields (embed_id, name, value, inline) VALUES %L`, QUERIES.fields));
    if (QUERIES.embeds_used.length != 0) batch.execute(Database.format(`INSERT INTO embeds_used (message_id, embed_id) VALUES %L`, QUERIES.embeds_used));
    batch.execute(`SELECT setval(pg_get_serial_sequence('messages', 'id'), (select max(id) from messages))`);
    batch.execute(`SELECT setval(pg_get_serial_sequence('embeds', 'id'), (select max(id) from embeds))`);
    
    if (QUERIES.guilds.length != 0) batch.execute(Database.format(`INSERT INTO guilds (${GUILD_FIELDS}) VALUES %L ON CONFLICT(id) DO UPDATE SET (${GUILD_FIELDS}) = ROW(excluded.*)`, QUERIES.guilds));
    if (QUERIES.members.length != 0) batch.execute(Database.format(`INSERT INTO members (guild_id, id, coins_voicetime_remainder, coins, messages, voicetime, save_coins, save_messages, save_voicetime, autochannel) VALUES %L`, QUERIES.members));
    
    if (QUERIES.mutes.length != 0) batch.execute(Database.format(`INSERT INTO mutes (guild_id, member_id, reason, duration, created) VALUES %L`, QUERIES.mutes));
    if (QUERIES.warns.length != 0) batch.execute(Database.format(`INSERT INTO warns (guild_id, member_id, reason, created) VALUES %L`, QUERIES.warns));

    if (QUERIES.voicetime_activityroles.length != 0) batch.execute(Database.format(`INSERT INTO voicetime_activityroles (role_id, min, max) VALUES %L`, QUERIES.voicetime_activityroles));
    if (QUERIES.message_activityroles.length != 0) batch.execute(Database.format(`INSERT INTO message_activityroles (role_id, min, max) VALUES %L`, QUERIES.message_activityroles));
    
    if (QUERIES.shop.length != 0) batch.execute(Database.format(`INSERT INTO shop (role_id, add_price, add_duration, remove_price, remove_duration) VALUES %L`, QUERIES.shop));
    
    if (QUERIES.economics_market_roles.length != 0) batch.execute(Database.format(`INSERT INTO economics_market_roles (guild_id, role_id) VALUES %L`, QUERIES.economics_market_roles));
    if (QUERIES.economics_market.length != 0) batch.execute(Database.format(`INSERT INTO economics_market (guild_id, member_id, role_id, price) VALUES %L`, QUERIES.economics_market));

    if (QUERIES.clans_levels.length != 0) batch.execute(Database.format(`INSERT INTO clans_levels (guild_id, price, members_limit, role_position, has_voice, voice_position, voice_category, can_change_name, can_change_color, can_set_deputies, duration, prolongcost, prolongmessage, prolongtime) VALUES %L`, QUERIES.clans_levels));
    if (QUERIES.clans.length != 0) batch.execute(Database.format(`INSERT INTO clans (id, guild_id, member_id, level, last_paid_at, prolong_notification_sent, role_id, voice_id) OVERRIDING SYSTEM VALUE VALUES %L`, QUERIES.clans));
    if (QUERIES.clans_deputies.length != 0) batch.execute(Database.format(`INSERT INTO clans_deputies (clan_id, member_id) VALUES %L`, QUERIES.clans_deputies));
    batch.execute(`SELECT setval(pg_get_serial_sequence('clans', 'id'), (select max(id) from clans))`);
    
    if (QUERIES.events.length != 0) batch.execute(Database.format(`INSERT INTO events (guild_id, name, max_balance, periodicity, notification_id) VALUES %L`, QUERIES.events));
    
    if (QUERIES.rolemanagement_rules.length != 0) batch.execute(Database.format(`INSERT INTO rolemanagement_rules (guild_id, role_id, manager_role_id, permission) VALUES %L`, QUERIES.rolemanagement_rules));

    if (QUERIES.inventory_roles.length != 0) batch.execute(Database.format(`INSERT INTO inventory_roles (guild_id, role_id) VALUES %L`, QUERIES.inventory_roles));
    if (QUERIES.inventory.length != 0) batch.execute(Database.format(`INSERT INTO inventory (guild_id, member_id, role_id, amount) VALUES %L`, QUERIES.inventory));

    if (QUERIES.donationroles.length != 0) batch.execute(Database.format(`INSERT INTO donationroles (role_id, add_price, add_duration, remove_price, remove_duration) VALUES %L`, QUERIES.donationroles));
    
    if (QUERIES.giveaways.length != 0) batch.execute(Database.format(`INSERT INTO giveaways (guild_id, channel_id, message_id, duration, winners, participation_cost, min_messages, max_messages, min_voicetime, max_voicetime, started) VALUES %L`, QUERIES.giveaways));
    if (QUERIES.giveaways_participants.length != 0) batch.execute(Database.format(`INSERT INTO giveaways_participants (guild_id, giveaway_id, member_id) VALUES %L`, QUERIES.giveaways_participants));

    QUERIES.timed_roles.forEach(rule => batch.execute(Database.format(`DO LANGUAGE plpgsql $$ BEGIN CALL add_timed_role(%L, %L, %L, %L, %L); END $$`, ...rule)));
    
    await batch.commit();

    console.info(`Filled all`);
    await Database.end();
    bot.destroy();
});
bot.login(config.discord.token);