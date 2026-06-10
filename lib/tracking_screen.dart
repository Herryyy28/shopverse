import 'package:flutter/material.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    // Simulate order progress
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _currentStep = 2);
    });
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _currentStep = 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Arriving in 8 mins', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18)),
            Text('Order ${widget.orderId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Mock Map Area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.grey[100],
              child: Stack(
                children: [
                  // Fake Map background
                  Opacity(
                    opacity: 0.3,
                    child: Image.network(
                      'https://miro.medium.com/v2/resize:fit:1400/1*qV92Z4S9uY-59uO1I4iCqg.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Animated Marker
                  AnimatedPositioned(
                    duration: const Duration(seconds: 2),
                    top: _currentStep == 1 ? 400 : (_currentStep == 2 ? 200 : 100),
                    left: _currentStep == 1 ? 50 : (_currentStep == 2 ? 150 : 250),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Rider is here', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const Icon(Icons.delivery_dining, color: Color(0xFFFF3232), size: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Status Panel
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                children: [
                  _buildStep(
                    icon: Icons.receipt_long,
                    title: 'Order Received',
                    subtitle: 'Wait for shop to accept',
                    isDone: _currentStep >= 1,
                    isActive: _currentStep == 1,
                  ),
                  _buildStep(
                    icon: Icons.local_mall,
                    title: 'Order Packed',
                    subtitle: 'Ready for pickup',
                    isDone: _currentStep >= 2,
                    isActive: _currentStep == 2,
                  ),
                  _buildStep(
                    icon: Icons.delivery_dining,
                    title: 'Out for Delivery',
                    subtitle: 'Rider is on the way',
                    isDone: _currentStep >= 3,
                    isActive: _currentStep == 3,
                  ),
                ],
              ),
            ),
          ),
          
          // Rider Info
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=rider'),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rahul Kumar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text('Your delivery partner', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.call, color: Colors.white, size: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({required IconData icon, required String title, required String subtitle, required bool isDone, required bool isActive}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : icon, color: isDone ? Colors.green : Colors.grey[300]),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: isActive ? Colors.black : (isDone ? Colors.black87 : Colors.grey))),
              Text(subtitle, style: TextStyle(fontSize: 12, color: isDone ? Colors.black54 : Colors.grey[400])),
            ],
          ),
        ],
      ),
    );
  }
}
