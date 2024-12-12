CREATE TABLE table_one (
    id INTEGER UNIQUE GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    num DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT NOW()
);
COPY table_one(name, num, created_at)
FROM '/docker-entrypoint-initdb.d/table_one.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE table_two (
    id INTEGER UNIQUE GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    num DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT NOW()
);
COPY table_two(name, num, created_at)
FROM '/docker-entrypoint-initdb.d/table_two.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE table_three (
    id INTEGER UNIQUE GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    num DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT NOW()
);
COPY table_three(name, num, created_at)
FROM '/docker-entrypoint-initdb.d/table_three.csv'
DELIMITER ','
CSV HEADER;