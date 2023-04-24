CREATE TABLE conversations (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `model` VARCHAR,
  `topic` VARCHAR,
  `total_tokens` INTEGER,
  `created_at` DATE
);

CREATE TABLE messages (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `role` VARCHAR,
  `content` VARCHAR,
  `conversation_id` INTEGER,
  `created_at` DATE
);
