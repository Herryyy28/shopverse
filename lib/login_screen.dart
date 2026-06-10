import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final Color brandRed = const Color(0xFFFF3232);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final error = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: brandRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: brandRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_checkout,
                      size: 64,
                      color: brandRed,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ShopVerse',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: brandRed,
                        letterSpacing: -1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quick commerce, delivered instantly',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.normal),
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined, color: brandRed),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.normal),
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock_outline, color: brandRed),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: brandRed, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text(
                          'LOG IN',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New to ShopVerse?",
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: Text(
                        'Create Account',
                        style: TextStyle(color: brandRed, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
