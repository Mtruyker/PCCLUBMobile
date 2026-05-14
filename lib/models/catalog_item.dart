class CatalogItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  CatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      category: json['category'] ?? 'General',
    );
  }
}
