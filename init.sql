CREATE DATABASE IF NOT EXISTS travelDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'user'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON travelDB.* TO 'user'@'%';
FLUSH PRIVILEGES;

USE travelDB;
SET NAMES utf8mb4;

-- 1. Организаторы и пользователи
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  login VARCHAR(60) NOT NULL UNIQUE,
  email VARCHAR(120) NOT NULL,
  role ENUM('traveler', 'organizer') DEFAULT 'traveler',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Совместные поездки
CREATE TABLE IF NOT EXISTS trips (
  id INT AUTO_INCREMENT PRIMARY KEY,
  organizer_id INT NOT NULL,
  title VARCHAR(150) NOT NULL,
  origin VARCHAR(100) NOT NULL,
  destination VARCHAR(100) NOT NULL,
  travel_date DATE NOT NULL,
  seats_total INT NOT NULL,
  seats_left INT NOT NULL,
  price_share DECIMAL(10, 2) NOT NULL,
  description TEXT,
  pdf_file VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (organizer_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Бронирования мест попутчиками
CREATE TABLE IF NOT EXISTS bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  trip_id INT NOT NULL,
  passenger_name VARCHAR(100) NOT NULL,
  seats_booked INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Сессии пользователей в БД
CREATE TABLE IF NOT EXISTS sessions (
  id VARCHAR(128) PRIMARY KEY,
  data TEXT NOT NULL,
  access INT UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO users (id, login, email, role) VALUES
(1, 'daria_travel', 'daria@tripmate.local', 'organizer'),
(2, 'alex_road', 'alex@tripmate.local', 'organizer');

INSERT IGNORE INTO trips (id, organizer_id, title, origin, destination, travel_date, seats_total, seats_left, price_share, description) VALUES
(1, 1, 'Выходные в Казани на авто', 'Москва', 'Казань', '2026-12-12', 4, 3, 2500.00, 'Выезд рано утром по трассе М-12, делим топливо и платный участок.'),
(2, 2, 'Зимний уикенд в Санкт-Петербурге', 'Москва', 'Санкт-Петербург', '2026-12-19', 3, 2, 2200.00, 'Комфортный кроссовер, остановки на кофе, берем небольшой багаж.'),
(3, 1, 'Поездка в Красную Поляну', 'Сочи', 'Красная Поляна', '2026-12-26', 4, 4, 800.00, 'Трансфер до подъемников и совместное катание.');

INSERT IGNORE INTO bookings (id, trip_id, passenger_name, seats_booked) VALUES
(1, 1, 'Мария Соколова', 1),
(2, 2, 'Иван Петров', 1);