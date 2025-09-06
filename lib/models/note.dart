import 'package:flutter/animation.dart';

class Note {
  String id;
  String title;
  String content;
  DateTime date;
  Color bgColor;
  Color textColor;

  Note({
    String? id,
    required this.title,
    required this.content,
    required this.date,
    required this.bgColor,
    required this.textColor,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
}
