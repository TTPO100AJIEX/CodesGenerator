export default async function getVoiceChannels(bot, guildId)
{
    const guild = bot.guilds.resolve(guildId);
    if (!guild) return [ ];
    const list = await guild.channels.fetch();
    return list.filter(channel => channel.isVoiceBased()).map(channel => ([ guildId, channel.id, channel.name ]));
}