import TelegramBot from 'node-telegram-bot-api';
import { Database } from "common/PostgreSQL/PostgreSQL.js";
import config from "common/configs/config.json" assert { type: "json" };

const app = new TelegramBot(config.telegram.token, { polling: true });

app.on('message', async ({ text, chat }) =>
{
    const read_query_string = `SELECT * FROM promocodes WHERE name = $1 AND uses > 0`;
    const promocode = await Database.execute(read_query_string, [ text ], { one_response: true });
    if (!promocode) return app.sendMessage(chat.id, config.telegram.no_promocode);

    const write_query_string = `UPDATE promocodes SET uses = uses - 1 WHERE name = $1`;
    return Promise.all([
        Database.execute(write_query_string, [ promocode.name ]),
        app.sendMessage(chat.id, promocode.message ?? config.telegram.activated)
    ]); 
});