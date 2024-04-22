export default async function getRoles(bot, guildId)
{
    const guild = bot.guilds.resolve(guildId);
    if (!guild) return [ ];
    const list = await guild.roles.fetch();
    return list.map(role => ([ guildId, role.id, role.name ]));
}