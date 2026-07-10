CREATE TABLE users (
  id BIGINT PRIMARY KEY,
  role VARCHAR(20) NOT NULL CHECK (role IN ('tutor', 'nanny', 'client')),
  first_name VARCHAR(120) NOT NULL,
  last_name VARCHAR(120) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(40) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE specialist_profiles (
  id BIGINT PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL CHECK (type IN ('tutor', 'nanny')),
  status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'review', 'published', 'hidden')),
  first_name VARCHAR(120) NOT NULL,
  last_name VARCHAR(120) NOT NULL,
  city VARCHAR(120) NOT NULL,
  district VARCHAR(120),
  photo_url TEXT,
  rating NUMERIC(3,2) NOT NULL DEFAULT 0,
  reviews_count INTEGER NOT NULL DEFAULT 0,
  views_count INTEGER NOT NULL DEFAULT 0,
  responses_count INTEGER NOT NULL DEFAULT 0,
  experience_years INTEGER NOT NULL DEFAULT 0,
  experience_level VARCHAR(40) NOT NULL,
  price_per_hour INTEGER NOT NULL,
  about TEXT NOT NULL,
  keywords TEXT,
  time_from TIME,
  time_to TIME,
  home_visit BOOLEAN NOT NULL DEFAULT FALSE,
  home_work BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE profile_filter_values (
  id BIGINT PRIMARY KEY,
  profile_id BIGINT NOT NULL REFERENCES specialist_profiles(id) ON DELETE CASCADE,
  filter_group VARCHAR(80) NOT NULL,
  filter_value VARCHAR(160) NOT NULL
);

CREATE INDEX idx_profile_filter_values_profile ON profile_filter_values(profile_id);
CREATE INDEX idx_profile_filter_values_group_value ON profile_filter_values(filter_group, filter_value);

CREATE TABLE reviews (
  id BIGINT PRIMARY KEY,
  profile_id BIGINT NOT NULL REFERENCES specialist_profiles(id) ON DELETE CASCADE,
  client_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  text TEXT NOT NULL,
  specialist_answer TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE requests (
  id BIGINT PRIMARY KEY,
  profile_id BIGINT NOT NULL REFERENCES specialist_profiles(id) ON DELETE CASCADE,
  specialist_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  client_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'accepted', 'rejected', 'completed')),
  text TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE conversations (
  id BIGINT PRIMARY KEY,
  profile_id BIGINT NOT NULL REFERENCES specialist_profiles(id) ON DELETE CASCADE,
  specialist_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  client_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE messages (
  id BIGINT PRIMARY KEY,
  conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE favorites (
  client_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  profile_id BIGINT NOT NULL REFERENCES specialist_profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (client_id, profile_id)
);

CREATE INDEX idx_profiles_catalog ON specialist_profiles(status, type, city, price_per_hour, rating);
CREATE INDEX idx_profiles_search ON specialist_profiles(first_name, last_name, city);
CREATE INDEX idx_requests_specialist ON requests(specialist_user_id, status);
CREATE INDEX idx_requests_client ON requests(client_id, status);
CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at);

INSERT INTO users (id, role, first_name, last_name, email, phone, password_hash)
VALUES
  (101, 'tutor', 'Ирина', 'Иванова', 'tutor@example.ru', '+79001112233', 'demo-123456'),
  (102, 'nanny', 'Наталья', 'Орлова', 'nanny@example.ru', '+79004445566', 'demo-123456'),
  (103, 'client', 'Анна', 'Петрова', 'client@example.ru', '+79007778899', 'demo-123456');

INSERT INTO specialist_profiles (
  id, user_id, type, status, first_name, last_name, city, district, rating, reviews_count,
  views_count, responses_count, experience_years, experience_level, price_per_hour, about,
  keywords, time_from, time_to, home_visit, home_work
)
VALUES
  (201, 101, 'tutor', 'published', 'Ирина', 'Иванова', 'Москва', 'Хамовники', 4.90, 42, 128, 17, 8, 'Опытный', 1600,
   'Готовлю к ОГЭ и ЕГЭ, закрываю пробелы по математике, работаю спокойно и системно.',
   'математика огэ егэ школьная программа алгебра геометрия', '10:00', '20:00', TRUE, FALSE),
  (202, 102, 'nanny', 'published', 'Наталья', 'Орлова', 'Москва', 'Сокол', 4.80, 31, 96, 21, 10, 'Опытный', 1200,
   'Няня с педагогическим образованием. Режим дня, прогулки, развивающие занятия.',
   'няня прогулки режим развивающие занятия педагогика', '09:00', '18:00', FALSE, TRUE);

INSERT INTO profile_filter_values (id, profile_id, filter_group, filter_value)
VALUES
  (1, 201, 'subjects', 'Математика'),
  (2, 201, 'subjects', 'Подготовка к школе'),
  (3, 201, 'educationLevels', 'Средняя школа'),
  (4, 201, 'lessonFormats', 'Индивидуальные'),
  (5, 201, 'lessonFormats', 'Онлайн'),
  (6, 201, 'tutorSkills', 'Подготовка к ЕГЭ'),
  (7, 201, 'tutorSkills', 'Подготовка к ОГЭ'),
  (8, 201, 'teachingLanguages', 'Русский'),
  (9, 202, 'childAges', 'От 1 до 3 лет'),
  (10, 202, 'childAges', 'От 3 до 6 лет'),
  (11, 202, 'employmentTypes', 'Частичная занятость'),
  (12, 202, 'employmentTypes', 'Автоняня'),
  (13, 202, 'nannySkills', 'Педагогическое образование'),
  (14, 202, 'nannySkills', 'Первая помощь'),
  (15, 202, 'careMethods', 'Игровые методики'),
  (16, 202, 'careMethods', 'Развивающие занятия');
