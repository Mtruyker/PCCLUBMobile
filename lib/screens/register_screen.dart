import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/client_api_service.dart';
import '../services/local_storage_service.dart';
import '../utils/error_handler.dart';
import '../utils/validation_utils.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final phone = ValidationUtils.cleanPhoneNumber(_phoneController.text.trim());
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ClientApiService>(context, listen: false);
      final clientId = await apiService.register(name, phone, password, email);
      await LocalStorageService.saveClientId(clientId);

      if (mounted) {
        ErrorHandler.showSuccess(context, 'Регистрация успешно завершена!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        gradient: AppColors.authGradientLight,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 20),
            child: Form(
              key: _formKey,
              child: Container(
                decoration: AppTheme.authCardDecoration,
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'РЕГИСТРАЦИЯ',
                      style: AppTheme.headingStyle.copyWith(
                        fontSize: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      validator: ValidationUtils.validateName,
                      decoration: AppTheme.textFieldDecorationSimple(
                        labelText: 'Имя',
                        prefixIcon: Icons.person,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: ValidationUtils.validatePhone,
                      decoration: AppTheme.textFieldDecorationSimple(
                        labelText: 'Номер телефона',
                        prefixIcon: Icons.phone,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return ValidationUtils.validateEmail(value);
                        }
                        return null; // Email необязательный
                      },
                      decoration: AppTheme.textFieldDecorationSimple(
                        labelText: 'Email (необязательно)',
                        prefixIcon: Icons.email,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: ValidationUtils.validatePassword,
                      decoration: AppTheme.textFieldDecorationSimple(
                        labelText: 'Пароль',
                        prefixIcon: Icons.lock,
                        suffixIcon: PasswordVisibilityButton(
                          isVisible: !_obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) => ValidationUtils.validatePasswordConfirmation(
                        value,
                        _passwordController.text,
                      ),
                      decoration: AppTheme.textFieldDecorationSimple(
                        labelText: 'Подтвердите пароль',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: PasswordVisibilityButton(
                          isVisible: !_obscureConfirmPassword,
                          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: AppTheme.primaryButtonStyle,
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? AppTheme.loadingIndicator()
                            : const Text(
                                'ЗАРЕГИСТРИРОВАТЬСЯ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
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
