import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const ShopVerseApp(),
    ),
  );
}

class ShopVerseApp extends StatelessWidget {
  const ShopVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandRed = Color(0xFFFF3232);
    
    return MaterialApp(
      title: 'ShopVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandRed,
          primary: brandRed,
          secondary: const Color(0xFFFFC107), // Blinkit yellow
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const MainScreen() : const LoginScreen();
        },
      ),
    );
  }
}
