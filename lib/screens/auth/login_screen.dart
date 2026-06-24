import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/auth_provider.dart';
import 'package:shopverse/screens/auth/signup_screen.dart';
import 'package:shopverse/widgets/custom_button.dart';
import 'package:shopverse/widgets/custom_text_field.dart';
import 'package:shopverse/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isPhoneLogin = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? error;
      
      if (_isPhoneLogin) {
        error = await authProvider.signInWithPhone(_phoneController.text.trim());
        if (mounted && error == null) {
          _showOtpDialog();
        }
      } else {
        error = await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppColors.brandRed),
          );
        }
      }
    }
  }

  void _googleSignIn() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.signInWithGoogle();
    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.brandRed),
        );
      }
    }
  }

  void _biometricSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authenticated = await authProvider.authenticateBiometric();
    if (authenticated) {
      // In a real app, you'd check if a user was previously logged in on this device
      // For this demo, we'll simulate a login if biometrics succeed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric Authentication Successful'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric Authentication Failed'), backgroundColor: AppColors.brandRed),
      );
    }
  }

  void _showOtpDialog() {
    final otpController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Verify Phone', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Enter the 6-digit code sent to ${_phoneController.text}', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                counterText: "",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final error = await authProvider.verifyOtp(_phoneController.text, otpController.text);
                  if (mounted) {
                    if (error == null) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('VERIFY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
                const SizedBox(height: 40),
                Center(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_cart_checkout, size: 64, color: AppColors.brandRed),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('ShopVerse', textAlign: TextAlign.center, 
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.brandRed, letterSpacing: -1)),
                const SizedBox(height: 32),
                
                // Toggle between Email and Phone
                Row(
                  children: [
                    _buildToggleButton('Email', !_isPhoneLogin, () => setState(() => _isPhoneLogin = false)),
                    const SizedBox(width: 12),
                    _buildToggleButton('Phone', _isPhoneLogin, () => setState(() => _isPhoneLogin = true)),
                  ],
                ),
                const SizedBox(height: 24),

                if (!_isPhoneLogin) ...[
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                ] else ...[
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    prefixIcon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                ],

                const SizedBox(height: 12),
                if (!_isPhoneLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?', style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.bold)),
                    ),
                  ),
                
                const SizedBox(height: 24),
                CustomButton(
                  text: _isPhoneLogin ? 'GET OTP' : 'LOG IN',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("OR", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold))),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Social Logins
                Row(
                  children: [
                    Expanded(child: _buildSocialButton('Google', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/768px-Google_\"G\"_logo.svg.png', _googleSignIn)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _biometricSignIn,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[200]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fingerprint, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Biometric', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New here?", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                      child: const Text('Create Account', style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.w900)),
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

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandRed : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, textAlign: TextAlign.center, 
            style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, String iconUrl, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey[200]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(iconUrl, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.login)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
