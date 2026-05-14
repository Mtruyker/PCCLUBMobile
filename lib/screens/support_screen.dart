import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

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
                  const SnackBar(content: Text('Чат временно недоступен')),
                );
              },
            ),
            _buildSupportOption(
              context,
              icon: Icons.phone_outlined,
              title: 'Позвонить в клуб',
              subtitle: '+7 (999) 000-00-00',
              onTap: () {
                // В реальном приложении здесь был бы вызов url_launcher
              },
            ),
            _buildSupportOption(
              context,
              icon: Icons.question_answer_outlined,
              title: 'Часто задаваемые вопросы',
              subtitle: 'Правила клуба, тарифы и оборудование',
              onTap: () {
                // Переход на экран FAQ
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Написать нам',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Опишите вашу проблему...',
                border: OutlineInputBorder(),
              ),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ваше сообщение отправлено')),
                  );
                },
                child: const Text('ОТПРАВИТЬ'),
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
