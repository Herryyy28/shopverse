import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/cart_provider.dart';
import 'package:shopverse/providers/wallet_provider.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:shopverse/widgets/custom_button.dart';

class SharedCartScreen extends StatefulWidget {
  const SharedCartScreen({super.key});

  @override
  State<SharedCartScreen> createState() => _SharedCartScreenState();
}

class _SharedCartScreenState extends State<SharedCartScreen> {
  final String _roomId = "SV-7829";
  bool _joined = false;
  
  final List<Map<String, dynamic>> _groupMembers = [
    {
      'name': 'You (Host)',
      'avatar': 'https://ui-avatars.com/api/?name=You&background=random',
      'items': [
        {'name': 'Amul Taaza Milk', 'price': 27.0, 'qty': 2},
      ]
    },
    {
      'name': 'Rahul Kumar',
      'avatar': 'https://i.pravatar.cc/150?u=rider_herry',
      'items': [
        {'name': 'Swift-Run Nitro Shoes', 'price': 120.0, 'qty': 1},
      ]
    },
    {
      'name': 'Herry Praja',
      'avatar': 'https://ui-avatars.com/api/?name=Herry&background=random',
      'items': [
        {'name': 'Aura Wireless Headphones', 'price': 299.0, 'qty': 1},
      ]
    }
  ];

  int _yesVotes = 2;
  int _noVotes = 1;
  bool _hasVoted = false;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [
    'Rahul Kumar: Aura headphones are super worth it!',
    'Herry Praja: I voted yes, the discount code is active.',
  ];

  double get _totalCartVal {
    double total = 0;
    for (var member in _groupMembers) {
      for (var item in member['items'] as List<Map<String, dynamic>>) {
        total += (item['price'] as double) * (item['qty'] as int);
      }
    }
    return total;
  }

  void _splitBillEqual() {
    final splitVal = _totalCartVal / _groupMembers.length;
    final wallet = Provider.of<WalletProvider>(context, listen: false);
    if (wallet.balance >= splitVal) {
      wallet.pay(splitVal, 'GROUP-$_roomId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully paid split share: ₹${splitVal.toStringAsFixed(2)}!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient wallet balance to pay split share!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Group Buy & Split', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ACTIVE ROOM CODE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            _roomId,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Room link copied! Invite sent.'), backgroundColor: Colors.blue, behavior: SnackBarBehavior.floating),
                        );
                      },
                      icon: const Icon(Icons.share, size: 14),
                      label: const Text('INVITE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Group Members & Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),

              // Members List
              ..._groupMembers.map((member) {
                double memberTotal = 0;
                for (var it in member['items'] as List<Map<String, dynamic>>) {
                  memberTotal += (it['price'] as double) * (it['qty'] as int);
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(member['avatar'] as String),
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 6),
                            ...(member['items'] as List).map((item) {
                              return Text(
                                '${item['qty']}x ${item['name']} (₹${item['price'].toInt()})',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              );
                            }),
                          ],
                        ),
                      ),
                      Text(
                        '₹${memberTotal.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),
              const Text(
                'Active Group Cart Polls',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),

              // Decisions Poll Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2F) : Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.poll_outlined, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('DECISION POLL', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: 11)),
                              Text('Buy Aura Wireless Headphones?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Vote ratio progress indicator
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _yesVotes + _noVotes > 0 ? _yesVotes / (_yesVotes + _noVotes) : 0.5,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        valueColor: const AlwaysStoppedAnimation(Colors.green),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Yes: $_yesVotes votes', style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('No: $_noVotes votes', style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _hasVoted
                                ? null
                                : () {
                                    setState(() {
                                      _yesVotes++;
                                      _hasVoted = true;
                                    });
                                  },
                            icon: const Icon(Icons.thumb_up, size: 14),
                            label: const Text('APPROVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _hasVoted
                                ? null
                                : () {
                                    setState(() {
                                      _noVotes++;
                                      _hasVoted = true;
                                    });
                                  },
                            icon: const Icon(Icons.thumb_down, size: 14),
                            label: const Text('REJECT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    const Text('Discussion Thread', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    ..._comments.map((comment) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            comment,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        )),
                    const SizedBox(height: 12),

                    // Add comment form
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: 'Ask group or suggest items...',
                              isDense: true,
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blueAccent),
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              setState(() {
                                _comments.add('You: ${_commentController.text}');
                                _commentController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Total & Split Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Group Bill:', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  Text('₹${_totalCartVal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your Equal Share (1/3):', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  Text(
                    '₹${(_totalCartVal / 3).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'PAY MY SPLIT SHARE',
                      onPressed: _splitBillEqual,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
