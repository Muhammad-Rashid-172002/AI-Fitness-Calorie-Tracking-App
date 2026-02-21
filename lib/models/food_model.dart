import 'package:cloud_firestore/cloud_firestore.dart';

class Food {
  final String name;
  final String shortMsg;
  final double? calories;
  final double? fats;
  final double? carbs;    
  final double? protein;  

  Food({
    required this.name,
    required this.shortMsg,
    this.calories,
    this.fats,
    this.carbs,     
    this.protein,   
  });
}

// Scan model
class Scan {
  final String id;
  final String result;
  final String? imagePath;
  final DateTime timestamp;

  Scan({
    required this.id,
    required this.result,
    this.imagePath,
    required this.timestamp,
  });

  factory Scan.fromMap(String id, Map<String, dynamic> map) {
    return Scan(
      id: id,
      result: map['result'] ?? "",
      imagePath: map['imagePath'],
      timestamp: (map['createdAt'] as Timestamp?)?.toDate() ??
          (map['timestamp'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }
}