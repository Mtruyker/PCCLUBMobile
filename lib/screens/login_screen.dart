import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/client_api_service.dart';
import '../services/local_storage_service.dart';
import '../utils/error_handler.dart';
import '../utils/validation_utils.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = ValidationUtils.cleanPhoneNumber(_phoneController.text.trim());
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ClientApiService>(context, listen: false);
      final clientId = await apiService.login(phone, password);

      // Сохраняем полученный ID пользователя
      await LocalStorageService.saveClientId(clientId);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.show(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Container(
                decoration: AppTheme.authCardDecoration,
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CYBER CLUB',
                      style: AppTheme.headingStyle.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: ValidationUtils.validatePhone,
                      decoration: AppTheme.textFieldDecoration(
                        labelText: 'Номер телефона',
                        hintText: '+7 (999) 123-45-67',
                        prefixIcon: Icons.phone_android,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: ValidationUtils.validatePassword,
                      decoration: AppTheme.textFieldDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: PasswordVisibilityButton(
                          isVisible: !_obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: AppTheme.primaryButtonStyle,
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? AppTheme.loadingIndicator()
                            : const Text(
                                'ВОЙТИ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Нет аккаунта?',
                          style: AppTheme.bodyStyle,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Зарегистрироваться',
                            style: AppTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
