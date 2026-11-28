<?php
class Database {
    private static ?mysqli $conn = null;

    public static function getConnection(): mysqli {
        if (self::$conn === null) {
            self::$conn = new mysqli("db", "user", "password", "travelDB");
            if (self::$conn->connect_error) {
                http_response_code(500);
                die("Ошибка подключения к БД: " . self::$conn->connect_error);
            }
            self::$conn->set_charset("utf8mb4");
        }
        return self::$conn;
    }

    public static function startDbSession(): void {
        $mysqli = self::getConnection();

        session_set_save_handler(
            fn($path, $name) => true,
            fn() => true,
            function($id) use ($mysqli) {
                $stmt = $mysqli->prepare("SELECT data FROM sessions WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $row = $stmt->get_result()->fetch_assoc();
                return $row ? $row['data'] : "";
            },
            function($id, $data) use ($mysqli) {
                $access = time();
                $stmt = $mysqli->prepare("REPLACE INTO sessions (id, data, access) VALUES (?, ?, ?)");
                $stmt->bind_param("ssi", $id, $data, $access);
                return $stmt->execute();
            },
            function($id) use ($mysqli) {
                $stmt = $mysqli->prepare("DELETE FROM sessions WHERE id = ?");
                $stmt->bind_param("s", $id);
                return $stmt->execute();
            },
            function($max) use ($mysqli) {
                $old = time() - $max;
                $stmt = $mysqli->prepare("DELETE FROM sessions WHERE access < ?");
                $stmt->bind_param("i", $old);
                return $stmt->execute();
            }
        );

        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
    }
}