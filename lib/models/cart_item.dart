import 'catalog_item.dart';

class CartItem {
  final CatalogItem product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.productPrice * quantity;
}

extension on CatalogItem {
  // В модели CatalogItem поле называется price. Добавим геттер для удобства если нужно
  double get productPrice => price;
}
