export default async function getTextChannels(bot, guildId)
{
    const guild = bot.guilds.resolve(guildId);
    if (!guild) return [ ];
    const list = await guild.channels.fetch();
    return list.filter(channel => channel.isTextBased()).map(channel => ([ guildId, channel.id, channel.name ]));
}