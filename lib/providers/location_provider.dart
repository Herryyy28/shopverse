import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Address {
  final String id;
  final String label; // Home, Work, Other
  final String addressLine;
  final String area;
  final int deliveryTimeMinutes;

  Address({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.area,
    required this.deliveryTimeMinutes,
  });
}

class LocationProvider with ChangeNotifier {
  final List<Address> _addresses = [
    Address(
      id: '1',
      label: 'Home',
      addressLine: 'Flat No. 402, Sunshine Apartments',
      area: 'Sector 45, Gurgaon',
      deliveryTimeMinutes: 8,
    ),
    Address(
      id: '2',
      label: 'Work',
      addressLine: 'Cyber Hub, Tower B, 5th Floor',
      area: 'DLF Phase 3, Gurgaon',
      deliveryTimeMinutes: 12,
    ),
  ];

  int _selectedAddressIndex = 0;
  bool _isFetchingLocation = false;

  List<Address> get addresses => [..._addresses];
  Address get selectedAddress => _addresses[_selectedAddressIndex];
  bool get isFetchingLocation => _isFetchingLocation;

  void selectAddress(int index) {
    if (index >= 0 && index < _addresses.length) {
      _selectedAddressIndex = index;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentLocation() async {
    _isFetchingLocation = true;
    notifyListeners();

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      } 

      Position position = await Geolocator.getCurrentPosition();

      // Reverse geocode using OpenStreetMap Nominatim
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
      final response = await http.get(url, headers: {
        'User-Agent': 'ShopVerse/1.0',
      });

      String addressLine = 'Location found';
      String area = 'Lat: ${position.latitude.toStringAsFixed(2)}, Lng: ${position.longitude.toStringAsFixed(2)}';

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['address'] != null) {
          final addr = data['address'];
          area = addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['state_district'] ?? area;
          
          final road = addr['road'];
          final suburb = addr['suburb'];
          if (road != null && suburb != null) {
            addressLine = '$road, $suburb';
          } else if (road != null) {
            addressLine = road;
          } else if (suburb != null) {
            addressLine = suburb;
          } else {
            addressLine = data['display_name'] ?? addressLine;
          }
        }
      }

      final newAddress = Address(
        id: DateTime.now().toString(),
        label: 'Current Location',
        addressLine: addressLine,
        area: area,
        deliveryTimeMinutes: 10,
      );

      _addresses.add(newAddress);
      _selectedAddressIndex = _addresses.length - 1;

    } catch (e) {
      debugPrint("Error fetching location: $e");
      // Fallback
      final newAddress = Address(
        id: DateTime.now().toString(),
        label: 'Current Location (Fallback)',
        addressLine: 'Location unavailable',
        area: 'Please select manually',
        deliveryTimeMinutes: 10,
      );
      _addresses.add(newAddress);
      _selectedAddressIndex = _addresses.length - 1;
    } finally {
      _isFetchingLocation = false;
      notifyListeners();
    }
  }

  void addAddress(String label, String line, String area) {
    final newAddress = Address(
      id: DateTime.now().toString(),
      label: label,
      addressLine: line,
      area: area,
      deliveryTimeMinutes: (8 + (15 * (1 - 0.5))).toInt(), // Random mock time
    );
    _addresses.add(newAddress);
    _selectedAddressIndex = _addresses.length - 1;
    notifyListeners();
  }

  void removeAddress(String id) {
    if (_addresses.length <= 1) return;
    _addresses.removeWhere((a) => a.id == id);
    _selectedAddressIndex = 0;
    notifyListeners();
  }
}
