import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String houseId;
  final String name;
  final String? notes;

  Room({
    required this.id,
    required this.houseId,
    required this.name,
    this.notes,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      houseId: data['houseId'] ?? '',
      name: data['name'] ?? '',
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'houseId': houseId, 'name': name, 'notes': notes};
  }
}
