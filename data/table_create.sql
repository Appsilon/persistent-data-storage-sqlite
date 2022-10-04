CREATE TABLE IF NOT EXISTS app_data_storage (
    id TEXT NOT NULL PRIMARY KEY UNIQUE,
    data TEXT NOT NULL,
    name TEXT NOT NULL,
    timestamp TEXT NOT NULL
);
