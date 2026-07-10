import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shopverse/utils/app_colors.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String orderId;
  const LiveTrackingScreen({super.key, required this.orderId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  
  // Set default coordinates (e.g. Mumbai/Delhi central points for demo)
  static const LatLng _storeLocation = LatLng(19.0760, 72.8777);
  static const LatLng _deliveryLocation = LatLng(19.0820, 72.8820);
  
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      const Marker(
        markerId: MarkerId('store'),
        position: _storeLocation,
        infoWindow: InfoWindow(title: 'Warehouse/Store'),
      ),
    );
    _markers.add(
      const Marker(
        markerId: MarkerId('delivery'),
        position: _deliveryLocation,
        infoWindow: InfoWindow(title: 'Your Location'),
      ),
    );

    _polylines.add(
      const Polyline(
        polylineId: PolylineId('route'),
        points: [_storeLocation, _deliveryLocation],
        color: AppColors.brandRed,
        width: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId} Tracking', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _storeLocation,
              zoom: 14.5,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green[50],
                    child: const Icon(Icons.directions_bike, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Rahul Sharma', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Text('On the way • 4 mins away', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
