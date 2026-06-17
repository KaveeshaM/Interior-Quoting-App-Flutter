import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomProvider extends ChangeNotifier {
  final CollectionReference _roomsCollection = FirebaseFirestore.instance
      .collection('rooms');

  List<Room> _rooms = [];
  List<Room> get rooms => _rooms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchRooms(String houseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _roomsCollection
          .where('houseId', isEqualTo: houseId)
          .get();
      _rooms = snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching rooms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRoom({
    required String houseId,
    required String name,
    String? notes,
    String? imageUrl,
  }) async {
    await _roomsCollection.add({
      'houseId': houseId,
      'name': name,
      'notes': notes,
      'imageUrl': imageUrl,
    });
    await fetchRooms(houseId);
  }

  Future<void> updateRoom(Room room) async {
    await _roomsCollection.doc(room.id).update(room.toMap());
    await fetchRooms(room.houseId);
  }

  Future<void> deleteRoom(String roomId, String houseId) async {
    try {
      await _roomsCollection.doc(roomId).delete();
      await fetchRooms(houseId);
    } catch (e) {
      debugPrint('Error deleting room: $e');
      rethrow;
    }
  }
}
