import Discord from 'discord.js';

export default async function getCategoryChannels(bot, guildId)
{
    const guild = bot.guilds.resolve(guildId);
    if (!guild) return [ ];
    const list = await guild.channels.fetch();
    return list.filter(channel => channel.type == Discord.ChannelType.GuildCategory).map(channel => ([ guildId, channel.id, channel.name ]));
}