import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/screens/auth/login_screen.dart';
import 'package:shopverse/screens/core/main_screen.dart';
import 'package:shopverse/providers/recent_provider.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/wishlist_provider.dart';
import 'package:shopverse/providers/auth_provider.dart';
import 'package:shopverse/providers/location_provider.dart';
import 'package:shopverse/providers/order_provider.dart';
import 'package:shopverse/providers/wallet_provider.dart';
import 'package:shopverse/providers/admin_provider.dart';
import 'package:shopverse/providers/product_provider.dart';
import 'package:shopverse/providers/category_provider.dart';
import 'package:shopverse/providers/user_provider.dart';
import 'package:shopverse/providers/notification_provider.dart';
import 'package:shopverse/providers/theme_provider.dart';
import 'package:shopverse/providers/compare_provider.dart';
import 'package:shopverse/services/firebase_service.dart';
import 'package:shopverse/utils/app_theme.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await FirebaseService.initialize();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CompareProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => RecentProvider()),
      ],
      child: const ShopVerseApp(),
    ),
  );
}

class ShopVerseApp extends StatelessWidget {
  const ShopVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'ShopVerse',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return auth.isAuthenticated ? const MainScreen() : const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
