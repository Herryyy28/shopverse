import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class SubscriptionSchedulerDialog extends StatefulWidget {
  final String productName;
  final double price;

  const SubscriptionSchedulerDialog({
    super.key,
    required this.productName,
    required this.price,
  });

  @override
  State<SubscriptionSchedulerDialog> createState() => _SubscriptionSchedulerDialogState();
}

class _SubscriptionSchedulerDialogState extends State<SubscriptionSchedulerDialog> {
  String _selectedFrequency = "Every 3 Days";
  final List<String> _frequencies = [
    "Daily",
    "Every Other Day",
    "Every 3 Days",
    "Weekly",
  ];

  final Map<String, bool> _weekdays = {
    "Mon": true,
    "Tue": false,
    "Wed": true,
    "Thu": false,
    "Fri": true,
    "Sat": false,
    "Sun": false,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.repeat_on_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Subscribe Staple',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Automate deliveries of ${widget.productName} on custom schedules.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Select frequency dropdown
            const Text('Deliver Frequency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFrequency,
                  isExpanded: true,
                  items: _frequencies.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(freq, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedFrequency = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Weekday toggles
            const Text('Deliver Days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _weekdays.keys.map((day) {
                final active = _weekdays[day]!;
                return ChoiceChip(
                  label: Text(day, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  selected: active,
                  onSelected: (val) {
                    setState(() {
                      _weekdays[day] = val;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'ACTIVATE (₹${widget.price.toInt()}/delivery)',
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Subscription active: ${widget.productName} will deliver $_selectedFrequency!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
