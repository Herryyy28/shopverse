import 'package:flutter/material.dart';

class WalletTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isCredit;

  WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isCredit,
  });
}

class WalletProvider with ChangeNotifier {
  double _balance = 1250.75;
  int _coinsBalance = 150;
  bool _hasSpunToday = false;

  final List<WalletTransaction> _transactions = [
    WalletTransaction(
      id: 't1',
      title: 'Added to Wallet',
      amount: 500.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isCredit: true,
    ),
    WalletTransaction(
      id: 't2',
      title: 'Order #ORD-5521',
      amount: 150.25,
      date: DateTime.now().subtract(const Duration(days: 2)),
      isCredit: false,
    ),
    WalletTransaction(
      id: 't3',
      title: 'Cashback Reward',
      amount: 25.0,
      date: DateTime.now().subtract(const Duration(days: 3)),
      isCredit: true,
    ),
  ];

  double get balance => _balance;
  int get coinsBalance => _coinsBalance;
  bool get hasSpunToday => _hasSpunToday;
  List<WalletTransaction> get transactions => [..._transactions];

  void addCoins(int amount, String title) {
    _coinsBalance += amount;
    notifyListeners();
  }

  void redeemCoins(int amount, String orderId) {
    if (_coinsBalance >= amount) {
      _coinsBalance -= amount;
      notifyListeners();
    }
  }

  void spinWheel(int coinsWon) {
    _hasSpunToday = true;
    addCoins(coinsWon, 'Daily Spin Reward');
  }

  void resetDailySpin() {
    _hasSpunToday = false;
    notifyListeners();
  }

  void addMoney(double amount) {
    _balance += amount;
    _transactions.insert(
      0,
      WalletTransaction(
        id: DateTime.now().toString(),
        title: 'Added to Wallet',
        amount: amount,
        date: DateTime.now(),
        isCredit: true,
      ),
    );
    notifyListeners();
  }

  void pay(double amount, String orderId) {
    if (_balance >= amount) {
      _balance -= amount;
      _transactions.insert(
        0,
        WalletTransaction(
          id: DateTime.now().toString(),
          title: 'Order #$orderId',
          amount: amount,
          date: DateTime.now(),
          isCredit: false,
        ),
      );
      notifyListeners();
    }
  }
}
