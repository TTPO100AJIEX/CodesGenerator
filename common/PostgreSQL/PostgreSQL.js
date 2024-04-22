import config from "common/configs/config.json" assert { type: "json" };

import pg from 'pg';
import pg_format from 'pg-format';
import JSONPointer from "jsonpointer";

export default class PostgreSQL
{
    #options;
    static #default_options = { parseInputDatesAsUTC: true, application_name: config.application.name };
    constructor(options)
    {
        this.#options = { ...PostgreSQL.#default_options, ...options };
    }

    get format() { return pg_format; }

    #client;
    get client()
    {
        if (this.#client) return this.#client;
        console.info(`Connected to PostgreSQL database ${this.#options.database}`);
        return this.#client = new pg.Pool(this.#options);
    }
    async end()
    {
        if (this.#client) await this.#client.end();
        this.#client = null;
    }


    #parsePointers(data)
    {
        const parseObjectPointers = (object) =>
        {
            let result = { };
            for (const key in object) JSONPointer.set(result, "/" + key, object[key]);
            return result;
        };
        return data.map(parseObjectPointers);
    }
    
    async execute(query, params, { one_response = false } = { })
    {
        const data = await this.client.query(query, params);
        const rows = this.#parsePointers(data.rows);
        return one_response ? rows[0] : rows;
    }

    async executeMultiple(queries = { })
    {
        const unifyQuery = (name, query) =>
        {
            const query_string = query.query ?? query;
            const one_response = query.one_response ?? false;
            return { name, query: query_string, one_response };
        };
        const plan = Object.entries(queries).map(entry => unifyQuery(entry[0], entry[1]));
        if (plan.length == 0) return Array.isArray(queries) ? [ ] : { };

        const raw_data = await this.client.query(plan.map(record => record.query).join(';\n'));
        const data = Array.isArray(raw_data) ? raw_data : [ raw_data ];
        const rows = data.map(res => this.#parsePointers(res.rows));

        const recordToResponse = (record, index) => record.one_response ? rows[index][0] : rows[index];
        const recordToResponseEntry = (record, index) => [ record.name, recordToResponse(record, index) ];
        return Array.isArray(queries) ? plan.map(recordToResponse) : Object.fromEntries(plan.map(recordToResponseEntry));
    }
};

export const Database = new PostgreSQL(config.postgreSQL);