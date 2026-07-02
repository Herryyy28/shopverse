import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class DigitalWrapperDialog extends StatefulWidget {
  final String productName;

  const DigitalWrapperDialog({
    super.key,
    required this.productName,
  });

  @override
  State<DigitalWrapperDialog> createState() => _DigitalWrapperDialogState();
}

class _DigitalWrapperDialogState extends State<DigitalWrapperDialog> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  bool _unwrapped = false;
  bool _isShaking = false;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _unwrapGift() async {
    if (_isShaking || _unwrapped) return;

    setState(() {
      _isShaking = true;
    });

    await _shakeController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 1));
    _shakeController.stop();

    setState(() {
      _isShaking = false;
      _unwrapped = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'YOU RECEIVED A GIFT!',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the gift box to unwrap it virtually',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Gift box shaking/reveal view
              GestureDetector(
                onTap: _unwrapGift,
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    double offset = 0;
                    if (_shakeController.isAnimating) {
                      offset = sin(_shakeController.value * pi * 8) * 8;
                    }
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _unwrapped ? Colors.green.withValues(alpha: 0.1) : Colors.pink.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      _unwrapped ? Icons.redeem_rounded : Icons.card_giftcard,
                      size: 80,
                      color: _unwrapped ? Colors.green : AppColors.brandRed,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_unwrapped) ...[
                Text(
                  widget.productName,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Enter Shipping Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Recipient Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'CLAIM PHYSICAL GIFT',
                    onPressed: () {
                      if (_nameController.text.isNotEmpty && _addressController.text.isNotEmpty) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gift registered! Delivering to ${_nameController.text}.'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all details to claim!'), backgroundColor: Colors.redAccent),
                        );
                      }
                    },
                  ),
                ),
              ] else ...[
                const Text(
                  'Tap Box to Unwrap',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'CLOSE',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
