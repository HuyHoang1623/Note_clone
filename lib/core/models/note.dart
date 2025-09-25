import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final Color backgroundColor;
  final Color textColor;
  final List<String> imagePaths;
  final List<String> videoPaths;

  Note({
    String? id,
    required this.title,
    required this.content,
    required this.date,
    required this.backgroundColor,
    required this.textColor,
    this.imagePaths = const [],
    this.videoPaths = const [],
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    Color? backgroundColor,
    Color? textColor,
    List<String>? imagePaths,
    List<String>? videoPaths,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      imagePaths: imagePaths ?? this.imagePaths,
      videoPaths: videoPaths ?? this.videoPaths,
    );
  }
}
