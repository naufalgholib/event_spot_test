import 'package:flutter/material.dart';

class IconOption {
  final String name;
  final String value;
  final IconData icon;

  const IconOption({
    required this.name,
    required this.value,
    required this.icon,
  });
}

class IconConstants {
  static const List<IconOption> categoryIcons = [
    IconOption(
      name: 'Music Note',
      value: 'music-note',
      icon: Icons.music_note,
    ),
    IconOption(
      name: 'Business',
      value: 'briefcase',
      icon: Icons.business,
    ),
    IconOption(
      name: 'Technology',
      value: 'laptop',
      icon: Icons.laptop,
    ),
    IconOption(
      name: 'Palette',
      value: 'palette',
      icon: Icons.palette,
    ),
    IconOption(
      name: 'Sports',
      value: 'football',
      icon: Icons.sports_soccer,
    ),
    IconOption(
      name: 'Restaurant',
      value: 'utensils',
      icon: Icons.restaurant,
    ),
    IconOption(
      name: 'School',
      value: 'graduation-cap',
      icon: Icons.school,
    ),
    IconOption(
      name: 'Favorite',
      value: 'heart-pulse',
      icon: Icons.favorite,
    ),
  ];

  static IconData getIconData(String iconName) {
    final icon = categoryIcons.firstWhere(
      (icon) => icon.value == iconName.toLowerCase(),
      orElse: () => const IconOption(
        name: 'Category',
        value: 'category',
        icon: Icons.category,
      ),
    );
    return icon.icon;
  }
}
