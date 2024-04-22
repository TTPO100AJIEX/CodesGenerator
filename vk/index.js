import Application from "./Application.js";
import { Database } from "common/PostgreSQL/PostgreSQL.js";
import config from "common/configs/config.json" assert { type: "json" };

const app = new Application(config.vk);
await app.setup();

function generatePromocode()
{
    const chars = config.application.available_charaters;
    const generateCharacter = () => chars[Math.floor(Math.random() * chars.length)];
    return Array(config.application.promocode_length).fill(null).map(generateCharacter).join();
}

async function createUserPromocode({ from_id: user_id })
{
    let message;
    if (await app.request("GET", "groups.isMember", { user_id }))
    {
        message = generatePromocode();
        const query_string = `INSERT INTO promocodes(name, created_by) VALUES ($1, $2)`;
        try { await Database.execute(query_string, [ message, user_id ]); }
        catch(e) { message = config.vk.already_has_promocode; }
    }
    else
    {
        message = config.vk.not_a_member;
    }
    if (message) await app.request("POST", "messages.send", { user_id, random_id: 0, message });
}

async function createAdminPromocode({ text, from_id: user_id })
{
    text = text.substr(config.vk.command.length + 1);
    const uses = text.substr(0, text.indexOf(" "));
    const message = text.substr(text.indexOf(" "));
    const promocode = generatePromocode();
    const query_string = `INSERT INTO promocodes(name, uses, message) VALUES ($1, $2, $3)`;
    await Database.execute(query_string, [ promocode, uses, message ]);
    await app.request("POST", "messages.send", { user_id, random_id: 0, message: promocode });
}

app.start(async ({ type, object }) =>
{
    if (type != "message_new") return;
    const { message } = object;
    if (message.text == config.vk.message) await createUserPromocode(message);
    if (message.text.startsWith(config.vk.command) && config.vk.admins.includes(message.from_id)) await createAdminPromocode(message);
});