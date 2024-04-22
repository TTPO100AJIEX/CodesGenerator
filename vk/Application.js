import assert from 'assert';

export default class Application
{
    constructor(config)
    {
        this.v = config.v;
        this.wait = config.wait;
        this.token = config.token;
        this.group_id = config.group_id;
    }

    async request(method, endpoint, params = {})
    {
        params = new URLSearchParams({ v: this.v, group_id: this.group_id, ...params });
        const path = `https://api.vk.com/method/${endpoint}?${params.toString()}`;
        const res = await fetch(path, { method, headers: { "Authorization": `Bearer ${this.token}` } });
        return (await res.json()).response;
    }
    
    async setup()
    {
        const data = await this.request("POST", "groups.getLongPollServer");
        this.server = data.server; this.key = data.key; this.ts = data.ts;
    }

    start(callback)
    {
        assert('server' in this && 'key' in this && 'ts' in this);
        const endpoint = `${this.server}?act=a_check&key=${this.key}&ts=${this.ts}&wait=${this.wait}`;
        delete this.ts;
        fetch(endpoint, { method: "POST" }).then(response => response.json()).then(({ ts, updates }) =>
        {
            this.ts = ts;
            updates.forEach(callback);
            this.start(callback);
        });
    }
};