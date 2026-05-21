class EnvConfig {
  static const String apiBaseUrl =
      'https://serverpcclub-production.up.railway.app/api';

  // Базовые таймауты
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration apiTimeoutLong = Duration(seconds: 15);

  // Адаптивные таймауты для разных типов запросов
  static const Duration quickRequestTimeout = Duration(seconds: 5);   // Для простых GET запросов
  static const Duration normalRequestTimeout = Duration(seconds: 10); // Для обычных запросов
  static const Duration uploadTimeout = Duration(seconds: 30);        // Для загрузки файлов
  static const Duration authTimeout = Duration(seconds: 15);          // Для авторизации

  // Настройки retry
  static const int maxRetryAttempts = 3;
  static const Duration retryBaseDelay = Duration(seconds: 1);
  static const Duration retryMaxDelay = Duration(seconds: 10);

  // Настройки кэширования
  static const Duration defaultCacheTtl = Duration(minutes: 30);
  static const Duration shortCacheTtl = Duration(minutes: 5);
  static const Duration longCacheTtl = Duration(hours: 2);

  // Получить таймаут в зависимости от типа запроса
  static Duration getTimeoutForRequest(RequestType type) {
    switch (type) {
      case RequestType.quick:
        return quickRequestTimeout;
      case RequestType.normal:
        return normalRequestTimeout;
      case RequestType.upload:
        return uploadTimeout;
      case RequestType.auth:
        return authTimeout;
    }
  }

  // Получить TTL кэша в зависимости от типа данных
  static Duration getCacheTtl(CacheType type) {
    switch (type) {
      case CacheType.short:
        return shortCacheTtl;
      case CacheType.normal:
        return defaultCacheTtl;
      case CacheType.long:
        return longCacheTtl;
    }
  }
}

enum RequestType {
  quick,    // Быстрые запросы (проверка статуса)
  normal,   // Обычные запросы
  upload,   // Загрузка файлов
  auth,     // Авторизация
}

enum CacheType {
  short,    // Короткий кэш (часто меняющиеся данные)
  normal,   // Обычный кэш
  long,     // Долгий кэш (редко меняющиеся данные)
}
