// lib/models/note.dart
class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdTime;
  final int color;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdTime,
    required this.color,
  });

  Note copy({
    int? id,
    String? title,
    String? content,
    DateTime? createdTime,
    int? color,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        createdTime: createdTime ?? this.createdTime,
        color: color ?? this.color,
      );

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json['id'] as int?,
        title: json['title'] as String,
        content: json['content'] as String,
        createdTime: DateTime.parse(json['createdTime'] as String),
        color: json['color'] as int,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdTime': createdTime.toIso8601String(),
        'color': color,
      };
}
