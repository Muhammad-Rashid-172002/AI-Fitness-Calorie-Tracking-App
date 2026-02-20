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

class Scan {
  final String id;
  final String imageUrl;
  final String result;
  final DateTime timestamp;

  Scan({
    required this.id,
    required this.imageUrl,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Scan.fromMap(String id, Map<String, dynamic> map) {
    return Scan(
      id: id,
      imageUrl: map['imageUrl'],
      result: map['result'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}