class ValidationUtils {
  /// Валидация телефона
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }

    // Убираем все символы кроме цифр
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    // Проверяем длину (10 или 11 цифр)
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return 'Номер телефона должен содержать 10-11 цифр';
    }

    // Проверяем формат российского номера
    final phoneRegex = RegExp(r'^(\+7|7|8)?[0-9]{10}$');
    if (!phoneRegex.hasMatch(digitsOnly)) {
      return 'Неверный формат номера телефона';
    }

    return null;
  }

  /// Валидация email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }

    // RFC 5322 упрощенная версия
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Неверный формат email';
    }

    return null;
  }

  /// Валидация пароля
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }

    if (value.length < 8) {
      return 'Пароль должен содержать минимум 8 символов';
    }

    // Проверяем наличие хотя бы одной цифры
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Пароль должен содержать хотя бы одну цифру';
    }

    // Проверяем наличие хотя бы одной буквы
    if (!RegExp(r'[a-zA-Zа-яА-Я]').hasMatch(value)) {
      return 'Пароль должен содержать хотя бы одну букву';
    }

    return null;
  }

  /// Валидация подтверждения пароля
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Подтвердите пароль';
    }

    if (value != password) {
      return 'Пароли не совпадают';
    }

    return null;
  }

  /// Валидация имени
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя';
    }

    if (value.trim().length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }

    // Проверяем, что имя содержит только буквы, пробелы и дефисы
    if (!RegExp(r'^[a-zA-Zа-яА-Я\s\-]+$').hasMatch(value.trim())) {
      return 'Имя может содержать только буквы, пробелы и дефисы';
    }

    return null;
  }

  /// Валидация продолжительности бронирования
  static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите продолжительность';
    }

    final duration = int.tryParse(value);
    if (duration == null) {
      return 'Введите число';
    }

    if (duration < 1) {
      return 'Минимальная продолжительность - 1 час';
    }

    if (duration > 12) {
      return 'Максимальная продолжительность - 12 часов';
    }

    return null;
  }

  /// Валидация суммы пополнения
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите сумму';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Введите корректную сумму';
    }

    if (amount < 1) {
      return 'Минимальная сумма - 1 рубль';
    }

    if (amount > 10000) {
      return 'Максимальная сумма - 10000 рублей';
    }

    return null;
  }

  /// Валидация обязательного поля
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Поле "$fieldName" обязательно для заполнения';
    }
    return null;
  }

  /// Форматирование номера телефона для отображения
  static String formatPhoneNumber(String phone) {
    // Убираем все символы кроме цифр
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length == 11 && digitsOnly.startsWith('7')) {
      // +7 (XXX) XXX-XX-XX
      return '+7 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7, 9)}-${digitsOnly.substring(9)}';
    } else if (digitsOnly.length == 10) {
      // +7 (XXX) XXX-XX-XX
      return '+7 (${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6, 8)}-${digitsOnly.substring(8)}';
    }

    return phone; // Возвращаем как есть, если не удалось отформатировать
  }

  /// Очистка номера телефона (только цифры)
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }
}