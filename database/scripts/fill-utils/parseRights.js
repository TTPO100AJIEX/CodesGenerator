export default function parseRights(bot, guild_id, rights)
{
    const roles = bot.guilds.resolve(guild_id)?.roles?.cache;
    if (!roles) return [ ];

    let answer = [ ];
    roles.forEach(role =>
    {
        const perms = role.permissions.toArray().map(perm => perm.toLowerCase());
        const roles_flag = rights.roles.includes(role.id), perms_flag = rights.permissions.some(perm => perms.includes(perm.toLowerCase()));
        if ((rights.rolesType == 0 && rights.permissionsType == 0) && (roles_flag || perms_flag)) answer.push([ guild_id, role.id ]);
        if ((rights.rolesType == 0 && rights.permissionsType == 1) && (roles_flag && !perms_flag)) answer.push([ guild_id, role.id ]);
        if ((rights.rolesType == 1 && rights.permissionsType == 0) && (!roles_flag && perms_flag)) answer.push([ guild_id, role.id ]);
        if ((rights.rolesType == 1 && rights.permissionsType == 1) && (!roles_flag && !perms_flag)) answer.push([ guild_id, role.id ]);
    });
    return answer;
}