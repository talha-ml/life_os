// lib/models/category.dart
import 'package:flutter/material.dart'; // 🚀 NEW: Required for Color object

class Category {
  final int? id;
  final String name;
  final String colorCode; // Stored as Hex (e.g., "#6C63FF" or "6C63FF")
  final String? iconPath;

  Category({
    this.id,
    required this.name,
    required this.colorCode,
    this.iconPath,
  });

  // 🚀 ELITE UPGRADE: Smart getter to convert Hex String to Flutter Color instantly
  Color get color {
    try {
      String hex = colorCode.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add 100% opacity if not provided
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey; // Safe fallback if hex is invalid
    }
  }

  // 🚀 BEST PRACTICE: copyWith method for immutable state updates
  Category copyWith({
    int? id,
    String? name,
    String? colorCode,
    String? iconPath,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorCode: colorCode ?? this.colorCode,
      iconPath: iconPath ?? this.iconPath,
    );
  }

  // Convert Category object to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_code': colorCode,
      'icon_path': iconPath,
    };
  }

  // Convert SQLite Map to Category object
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      colorCode: map['color_code'] as String,
      iconPath: map['icon_path'] as String?,
    );
  }
}