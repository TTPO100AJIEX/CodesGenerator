CREATE TYPE PAYMENT_STATUS AS ENUM ('CREATED', 'WAITING', 'PAID', 'REJECTED', 'PROCESSED');
CREATE TYPE PAYMENT_TYPE AS ENUM ('PREMIUM_BALANCE', 'PREMIUM_SUBSCRIPTIONS', 'PREMIUM_PACK', 'COINS', 'ROLE');
CREATE TYPE PAYMENT_METHOD AS ENUM ('QIWI');

CREATE TABLE payments
(
    type PAYMENT_TYPE NOT NULL,
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status PAYMENT_STATUS NOT NULL DEFAULT 'CREATED',
    last_checked TIMESTAMPTZ NOT NULL DEFAULT NOW(),
     
    price POSITIVE_NUMBER NOT NULL,
    discount PERCENTAGE NOT NULL DEFAULT 0,
    pay_url URL CHECK (status = 'CREATED' OR pay_url IS NOT NULL),
    pay_method PAYMENT_METHOD CHECK (status = 'CREATED' OR pay_method IS NOT NULL),
    commission PERCENTAGE CHECK (status != 'PROCESSED' OR commission IS NOT NULL),

    extra JSON,
    user_id DISCORD_ID NOT NULL,
    guild_id DISCORD_ID NOT NULL REFERENCES guilds(id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX payments_last_checked_index ON payments(last_checked);

CREATE VIEW payments_view AS
    SELECT
        ROUND(price, 2) AS price,
        ROUND(discount, 2) AS discount,
        ROUND(price * (1 - discount / 100), 2) AS to_pay,
        ROUND(price * discount / 100, 2) AS discount_amount,
        payments.type, payments.id, payments.status, payments.last_checked,
        payments.pay_url, payments.pay_method, payments.commission,
        payments.extra, payments.user_id, payments.guild_id,
        (CASE WHEN guilds.reduced_commission_subscription > NOW() THEN 10 ELSE 15 END) AS current_commission
    FROM payments INNER JOIN guilds ON payments.guild_id = guilds.id;