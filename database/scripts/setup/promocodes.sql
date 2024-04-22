CREATE TABLE promocodes
(
    name TEXT PRIMARY KEY,
    uses INT NOT NULL CHECK(uses >= 0) DEFAULT 1,
    message TEXT,
    created_by BIGINT UNIQUE
);