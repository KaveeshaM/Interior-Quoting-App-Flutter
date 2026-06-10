import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_item.dart';

class RoomItemProvider extends ChangeNotifier {
  final CollectionReference _itemsCollection = FirebaseFirestore.instance
      .collection('roomItems');

  List<RoomItem> _items = [];
  List<RoomItem> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchItems(String roomId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _itemsCollection
          .where('roomId', isEqualTo: roomId)
          .get();
      _items = snapshot.docs.map((doc) => RoomItem.fromFirestore(doc)).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem({
    required String roomId,
    required String type,
    String? name,
    required int widthMm,
    required int heightMm,
  }) async {
    await _itemsCollection.add({
      'roomId': roomId,
      'type': type,
      'name': name,
      'widthMm': widthMm,
      'heightMm': heightMm,
    });
    await fetchItems(roomId);
  }

  Future<void> updateItem(RoomItem item) async {
    await _itemsCollection.doc(item.id).update(item.toMap());
    await fetchItems(item.roomId);
  }

  Future<void> deleteItem(String itemId, String roomId) async {
    await _itemsCollection.doc(itemId).delete();
    await fetchItems(roomId);
  }
}
