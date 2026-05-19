import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Часто задаваемые вопросы'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFaqSection('Правила клуба', [
            _buildFaqItem(
              'Какие правила действуют в клубе?',
              'В клубе запрещено курение, употребление алкоголя, громкие разговоры. Необходимо бережно относиться к оборудованию и соблюдать чистоту.',
            ),
            _buildFaqItem(
              'Можно ли приносить свою еду и напитки?',
              'Нет, в клубе действует собственное кафе. Внешняя еда и напитки запрещены.',
            ),
            _buildFaqItem(
              'Есть ли возрастные ограничения?',
              'Дети до 14 лет допускаются только в сопровождении взрослых. Игры 18+ доступны только совершеннолетним.',
            ),
          ]),
          const SizedBox(height: 24),
          _buildFaqSection('Тарифы и оплата', [
            _buildFaqItem(
              'Какие тарифы действуют?',
              'Стандартный тариф: 150₽/час в будни, 200₽/час в выходные. VIP-зона: 250₽/час. Ночной тариф (22:00-08:00): 100₽/час.',
            ),
            _buildFaqItem(
              'Какие способы оплаты принимаются?',
              'Наличные, банковские карты, СБП, баланс в приложении. Возможна предоплата через приложение.',
            ),
            _buildFaqItem(
              'Есть ли скидки?',
              'Студентам - 10% по будням до 18:00. Постоянным клиентам - накопительная система скидок до 15%.',
            ),
          ]),
          const SizedBox(height: 24),
          _buildFaqSection('Оборудование и игры', [
            _buildFaqItem(
              'Какое оборудование в клубе?',
              'ПК: Intel i7/AMD Ryzen 7, RTX 4060/4070, 16-32GB RAM, SSD. Мониторы: 24-27" 144Hz. Периферия: игровые клавиатуры, мыши, наушники.',
            ),
            _buildFaqItem(
              'Какие игры установлены?',
              'Steam, Epic Games, Battle.net со всеми популярными играми. Постоянно обновляем библиотеку по запросам клиентов.',
            ),
            _buildFaqItem(
              'Можно ли установить свою игру?',
              'Да, можно установить игру с вашего аккаунта или принести на флешке (после проверки антивирусом).',
            ),
          ]),
          const SizedBox(height: 24),
          _buildFaqSection('Бронирование и время', [
            _buildFaqItem(
              'Как забронировать место?',
              'Через приложение, по телефону или на месте. Рекомендуем бронировать заранее, особенно в выходные.',
            ),
            _buildFaqItem(
              'Можно ли отменить бронь?',
              'Да, отмена возможна не позднее чем за 2 часа до начала сеанса без штрафа.',
            ),
            _buildFaqItem(
              'Что если опоздал на бронь?',
              'Бронь держится 15 минут. После этого место может быть передано другому клиенту.',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildFaqSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}