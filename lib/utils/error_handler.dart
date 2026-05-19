import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static void show(BuildContext context, Object error, {String? customMessage}) {
    final message = customMessage ?? _extractMessage(error);

    if (context.mounted) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Закрыть',
            textColor: Colors.white,
            onPressed: () {
              messenger.hideCurrentSnackBar();
            },
          ),
        ),
      );
    }

    _logError(error);
  }

  static void showErrorDialog(
    BuildContext context,
    Object error, {
    String? customMessage,
    VoidCallback? onRetry,
    String retryButtonText = 'Повторить',
  }) {
    final message = customMessage ?? _extractMessage(error);

    if (context.mounted) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Закрыть'),
              ),
              if (onRetry != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onRetry();
                  },
                  child: Text(retryButtonText),
                ),
            ],
          );
        },
      );
    }

    _logError(error);
  }

  static void showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  static void showBanner(BuildContext context, Object error, {String? customMessage}) {
    final message = customMessage ?? _extractMessage(error);

    if (context.mounted) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showMaterialBanner(
        MaterialBanner(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          actions: [
            TextButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
              },
              child: const Text(
                'Закрыть',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    _logError(error);
  }

  static String _extractMessage(Object error) {
    if (error is String) {
      return error;
    }

    final errorString = error.toString();

    if (errorString.contains('SocketException') ||
        errorString.contains('HandshakeException')) {
      return 'Проблемы с подключением к интернету';
    }

    if (errorString.contains('TimeoutException')) {
      return 'Превышено время ожидания. Попробуйте позже';
    }

    if (errorString.contains('FormatException')) {
      return 'Ошибка формата данных';
    }

    if (errorString.contains('HttpException')) {
      return 'Ошибка сервера. Попробуйте позже';
    }

    return errorString
        .replaceAll('Exception: ', '')
        .replaceAll('FormatException: ', '')
        .replaceFirst(RegExp(r'^[A-Za-z]+Exception:\s*'), '');
  }

  static void _logError(Object error) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (error is Error) {
        debugPrint('Stack trace: ${error.stackTrace}');
      }
    }
  }

  static String handleApiError(int statusCode, String? message) {
    switch (statusCode) {
      case 400:
        return message ?? 'Неверные данные запроса';
      case 401:
        return 'Необходима авторизация';
      case 403:
        return 'Доступ запрещен';
      case 404:
        return 'Ресурс не найден';
      case 408:
        return 'Превышено время ожидания';
      case 429:
        return 'Слишком много запросов. Попробуйте позже';
      case 500:
        return 'Внутренняя ошибка сервера';
      case 502:
        return 'Сервер недоступен';
      case 503:
        return 'Сервис временно недоступен';
      default:
        return message ?? 'Ошибка сервера ($statusCode)';
    }
  }
}

class LoadingOverlay {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryButtonText;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryButtonText = 'Повторить',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryButtonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
