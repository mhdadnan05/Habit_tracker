class Habit {
  String id;
  String name;
  List<bool> completedDays; // Last 7 days
  DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.completedDays,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'completedDays': completedDays,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      completedDays: List<bool>.from(json['completedDays']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Habit copyWith({
    String? id,
    String? name,
    List<bool>? completedDays,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      completedDays: completedDays ?? this.completedDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}