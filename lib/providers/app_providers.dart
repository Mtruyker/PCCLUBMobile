import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../services/client_api_service.dart';
import '../services/cart_service.dart';
import 'theme_provider.dart';

List<SingleChildWidget> get appProviders => [
  Provider<ClientApiService>.value(value: ClientApiService()),
  ChangeNotifierProvider<CartService>(create: (_) => CartService()),
  ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
];