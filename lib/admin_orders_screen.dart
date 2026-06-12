import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/providers/order_provider.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    return StreamBuilder<List<OrderItem>>(
      stream: orderProv.ordersStream,
      builder: (context, snapshot) {
        final orders = snapshot.data ?? orderProv.orders;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Orders', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        title: Text('Order ID: ${order.id.length > 6 ? order.id.substring(order.id.length - 6).toUpperCase() : order.id}'),
                        subtitle: Text('Status: ${order.status} | ₹${order.amount}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.dateTime)}'),
                                const SizedBox(height: 8),
                                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                                ...order.products.map((p) => ListTile(
                                  title: Text(p['name'] ?? 'Product'),
                                  trailing: Text('x${p['quantity'] ?? 1}'),
                                )),
                                const Divider(),
                                const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Wrap(
                                  spacing: 8,
                                  children: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].map((status) {
                                    return ChoiceChip(
                                      label: Text(status),
                                      selected: order.status == status,
                                      onSelected: (selected) {
                                        if (selected) {
                                          orderProv.updateOrderStatus(order.id, status);
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
