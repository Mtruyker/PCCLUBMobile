# Plan.md — PC Club Mobile

## Обзор проекта

Мобильное приложение (Flutter) для клуба игровых ПК. Позволяет просматривать новости, каталог товаров, бронировать ПК, просматривать историю сессий и управлять профилем. Backend: Railway API.

---

## Архитектура

Сейчас: простой layered MVC (models / services / screens), `setState` для состояния экранов, синглтоны для сервисов.

**Без state management библиотеки**, без DI, без middleware.

---

## Приоритет 1 — Критические проблемы

### 1.1. Безопасность: пароли в открытом виде
**Файл:** `lib/services/local_storage_service.dart`

Пароли хранятся и сравниваются в открытом виде. При регистрации и логине пароль передаётся как есть.

- Хешировать пароли (bcrypt/dart-scrypt или простой SHA-256 с солью)
- Не хранить пароль локально; хранить только токен сессии
- Перейти на токен-основанную авторизацию (JWT или сессионный токен)

### 1.2. Нет валидации ввода
**Файлы:** `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart`, `lib/screens/booking_screen.dart`

- Телефон: регулярное выражение, длина
- Email: формат RFC 5322
- Пароль: минимум 8 символов
- Продолжительность бронирования: числовой диапазон

### 1.3. Silent failure — ошибки не показываются пользователю
**Файлы:** все screen-файлы (все `catch` блоки только `debugPrint`)

- Показывать `SnackBar` с текстом ошибки на каждом экране
- Добавить `ErrorBanner` / централизованный `ErrorHandler`
- Показывать состояние ошибки с кнопкой повтора

---

## Приоритет 2 — Качество кода

### 2.1. Внедрить state management
Установить `provider` или `riverpod`. Рефакторинг:

- `CartService` → через `ChangeNotifierProvider` вместо ручного `addListener`
- `ClientApiService` → singleton через Provider
- `LocalStorageService` → Provider
- Данные профиля, новостей, каталога → отдельные провайдеры

### 2.2. Архитектура: разделить UI и бизнес-логику
Сейчас экраны содержат и API-вызовы, и UI.

- Создать `lib/repositories/` — один репозиторий на модель (`client_repository.dart`, `booking_repository.dart`, etc.)
- Репозитории инкапсулируют `ClientApiService`, кэширование, обработку ошибок
- Screens получают данные через Riverpod/Provider

### 2.3. API Base URL — захардкожен
**Файл:** `lib/services/client_api_service.dart`

```dart
static const String baseUrl = 'https://...';
```

- Вынести в environment config (`lib/config/env_config.dart`)
- Для debug/dev сборок — отдельный URL

### 2.4. Убрать дублирование кода
- Градиентный фон, стили TextField, кнопка видимости пароля — в `lib/theme/app_theme.dart` или виджет
- `_buildMenuTile` в `ClientProfileScreen` — отдельный виджет
- `ErrorHandler.show(context, error)` — утилита

### 2.5. Hive box не кэшируется
**Файл:** `lib/services/local_storage_service.dart`

`Hive.openBox` вызывается каждый раз при `saveClientProfile`.

```dart
static Box? _box; // кэш
static Box get box => _box ??= await Hive.openBox(...);
```

---

## Приоритет 3 — Функциональные доделки

### 3.1. OrderHistoryScreen — реальный API
**Файл:** `lib/screens/order_history_screen.dart`

Сейчас использует mock data. Добавить реальный endpoint или заглушку "в разработке".

### 3.2. SupportScreen — заглушки
**Файл:** `lib/screens/support_screen.dart`

Кнопки "Чат", "FAQ" не функциональны. Добавить реальную логику или пометить UI как "скоро".

### 3.3. NewsDetailScreen — кнопка "Поделиться"
**Файл:** `lib/screens/news_detail_screen.dart`

Реализовать через `Share.share()` (пакет `share_plus`).

### 3.4. ClubMapScreen — динамические данные
**Файл:** `lib/screens/club_map_screen.dart`

PC-позиции захардкожены. Получать с бэкенда список ПК с координатами и статусом.

---

## Приоритет 4 — Улучшения UX

### 4.1. Loading states
Добавить `CircularProgressIndicator` или skeleton shimmer на:
- NewsScreen при загрузке
- CatalogScreen при загрузке
- ProfileScreen при загрузке

### 4.2. Pull-to-refresh
Добавить на все экраны со списками (Bookings, Sessions, Orders).

### 4.3. Empty states
Улучшить empty states с иконками и текстом "Нет данных".

### 4.4. Темная тема
Проверить контрастность в dark theme, убедиться что все компоненты читаемы.

---

## Приоритет 5 — Технический долг

### 5.1. Константы и строки
- Все тексты ("Войти", "Регистрация", etc.) — в `lib/l10n/` (Flutter intl) или `lib/constants/strings.dart`
- Это упростит локализацию

### 5.2. Анализ кода
`flutter analyze` + исправить все warnings.

### 5.3. pubspec.yaml
- Обновить описание (`description`)
- Указать `flutter_lints` в dev_dependencies (уже есть)
- Добавить `provider` или `riverpod`
- Добавить `share_plus` (для шаринга)
- Добавить `flutter_secure_storage` (для хранения токенов)

### 5.4. Тесты
- Добавить widget tests для LoginScreen, BookingScreen
- Добавить unit tests для моделей
- Добавить integration tests для потока "логин → бронирование"

---

## Порядок действий (рекомендуемый)

1. ✅ `pubspec.yaml` — добавить зависимости (`provider`, `share_plus`, `flutter_secure_storage`)
2. ✅ `lib/theme/app_theme.dart` — вынести общие стили
3. ✅ `lib/utils/error_handler.dart` — централизованная обработка ошибок
4. ✅ Рефакторинг `LocalStorageService` (кэш box,secure storage для токенов)
5. ✅ Рефакторинг `ClientApiService` (env config, централизованный error handling)
6. ✅ Внедрить Provider — `CartService`, `ClientApiService` через провайдеры
7. ✅ Добавить валидацию в формы (LoginScreen, RegisterScreen)
8. ✅ Исправить silent failures на всех экранах
9. ✅ Реализовать OrderHistoryScreen и SupportScreen
10. ✅ Тесты