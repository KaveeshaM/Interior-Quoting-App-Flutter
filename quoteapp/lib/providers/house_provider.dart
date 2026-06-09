import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/house.dart';

class HouseProvider extends ChangeNotifier {
  final CollectionReference _housesCollection = FirebaseFirestore.instance
      .collection('houses');
  List<House> _houses = [];
  List<House> get houses => _houses;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchHouses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _housesCollection.get();
      _houses = snapshot.docs.map((doc) => House.fromFirestore(doc)).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHouse({
    required String customerName,
    required String nickname,
    required String address,
    required String phoneNumber,
    required String details,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _housesCollection.add({
        'customerName': customerName,
        'nickname': nickname,
        'address': address,
        'phoneNumber': phoneNumber,
        'details': details,
      });
      await fetchHouses(); // refresh list
    } catch (e) {
      debugPrint('Error adding house: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
