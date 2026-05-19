import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/error_handler.dart';
import 'faq_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall() async {
    const phoneNumber = 'tel:+79990000000';
    try {
      if (await canLaunchUrl(Uri.parse(phoneNumber))) {
        await launchUrl(Uri.parse(phoneNumber));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось совершить звонок')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.show(context, e);
      }
    }
  }

  Future<void> _submitMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Имитация отправки сообщения
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ваше сообщение отправлено! Мы ответим в течение часа.'),
            backgroundColor: Colors.green,
          ),
        );
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.show(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поддержка'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Как мы можем вам помочь?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              icon: Icons.chat_outlined,
              title: 'Чат с администратором',
              subtitle: 'Среднее время ответа: 2 минуты',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Чат временно недоступен. Используйте форму ниже или позвоните нам.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            _buildSupportOption(
              context,
              icon: Icons.phone_outlined,
              title: 'Позвонить в клуб',
              subtitle: '+7 (999) 000-00-00',
              onTap: _makePhoneCall,
            ),
            _buildSupportOption(
              context,
              icon: Icons.question_answer_outlined,
              title: 'Часто задаваемые вопросы',
              subtitle: 'Правила клуба, тарифы и оборудование',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FaqScreen()),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Написать нам',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Опишите вашу проблему или вопрос...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Пожалуйста, введите ваше сообщение';
                      }
                      if (value.trim().length < 10) {
                        return 'Сообщение должно содержать минимум 10 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isSubmitting ? null : _submitMessage,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('ОТПРАВИТЬ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
