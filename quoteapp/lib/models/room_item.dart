import 'package:cloud_firestore/cloud_firestore.dart';

class RoomItem {
  final String id;
  final String roomId;
  final String type; // "window" or "floor"
  final String? name;
  final int widthMm;
  final int heightMm;
  final String? productId;
  final String? selectedColour;

  RoomItem({
    required this.id,
    required this.roomId,
    required this.type,
    this.name,
    required this.widthMm,
    required this.heightMm,
    this.productId,
    this.selectedColour,
  });

  factory RoomItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoomItem(
      id: doc.id,
      roomId: data['roomId'] ?? '',
      type: data['type'] ?? 'window',
      name: data['name'],
      widthMm: data['widthMm'] ?? 0,
      heightMm: data['heightMm'] ?? 0,
      productId: data['productId'],
      selectedColour: data['selectedColour'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'type': type,
      'name': name,
      'widthMm': widthMm,
      'heightMm': heightMm,
      'productId': productId,
      'selectedColour': selectedColour,
    };
  }
}
