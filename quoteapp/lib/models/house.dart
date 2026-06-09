import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  final String id;
  final String customerName;
  final String nickname;
  final String address;
  final String phoneNumber;
  final String details;

  House({
    required this.id,
    required this.customerName,
    required this.nickname,
    required this.address,
    required this.phoneNumber,
    required this.details,
  });

  factory House.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return House(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      nickname: data['nickname'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      details: data['details'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'nickname': nickname,
      'address': address,
      'phoneNumber': phoneNumber,
      'details': details,
    };
  }
}
