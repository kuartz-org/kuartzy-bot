CREATE TABLE conversations (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `model` VARCHAR,
  `created_at` DATE
);

CREATE TABLE messages (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `role` VARCHAR,
  `content` VARCHAR,
  `conversation_id` INTEGER,
  `created_at` DATE
);
