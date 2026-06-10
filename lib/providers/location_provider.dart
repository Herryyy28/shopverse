import 'package:flutter/material.dart';

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

    // Simulate GPS fetch and Geocoding
    await Future.delayed(const Duration(seconds: 2));
    
    final newAddress = Address(
      id: DateTime.now().toString(),
      label: 'Current Location',
      addressLine: 'Near Huda City Centre',
      area: 'Sector 29, Gurgaon',
      deliveryTimeMinutes: 10,
    );

    _addresses.add(newAddress);
    _selectedAddressIndex = _addresses.length - 1;
    _isFetchingLocation = false;
    notifyListeners();
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
