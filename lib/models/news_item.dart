class NewsItem {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime date;

  NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.date,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/300',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}
