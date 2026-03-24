import 'package:flutter/material.dart';

class CategoryIcons {
  static IconData getIcon(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('food') || categoryLower.contains('meal')) {
      return Icons.restaurant;
    } else if (categoryLower.contains('drink') ||
        categoryLower.contains('beverage')) {
      return Icons.local_drink;
    } else if (categoryLower.contains('dessert') ||
        categoryLower.contains('sweet')) {
      return Icons.cake;
    } else if (categoryLower.contains('appetizer') ||
        categoryLower.contains('starter')) {
      return Icons.fastfood;
    } else if (categoryLower.contains('salad')) {
      return Icons.eco;
    } else if (categoryLower.contains('soup')) {
      return Icons.soup_kitchen;
    } else if (categoryLower.contains('pizza')) {
      return Icons.local_pizza;
    } else if (categoryLower.contains('burger') ||
        categoryLower.contains('sandwich')) {
      return Icons.lunch_dining;
    } else if (categoryLower.contains('coffee') ||
        categoryLower.contains('tea')) {
      return Icons.coffee;
    } else if (categoryLower.contains('alcohol') ||
        categoryLower.contains('beer') ||
        categoryLower.contains('wine')) {
      return Icons.wine_bar;
    } else {
      return Icons.category;
    }
  }

  static Color getIconColor(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('food') || categoryLower.contains('meal')) {
      return Colors.orange;
    } else if (categoryLower.contains('drink') ||
        categoryLower.contains('beverage')) {
      return Colors.blue;
    } else if (categoryLower.contains('dessert') ||
        categoryLower.contains('sweet')) {
      return Colors.pink;
    } else if (categoryLower.contains('appetizer') ||
        categoryLower.contains('starter')) {
      return Colors.amber;
    } else if (categoryLower.contains('salad')) {
      return Colors.green;
    } else if (categoryLower.contains('soup')) {
      return Colors.deepOrange;
    } else if (categoryLower.contains('pizza')) {
      return Colors.red;
    } else if (categoryLower.contains('burger') ||
        categoryLower.contains('sandwich')) {
      return Colors.brown;
    } else if (categoryLower.contains('coffee') ||
        categoryLower.contains('tea')) {
      return Colors.brown.shade700;
    } else if (categoryLower.contains('alcohol') ||
        categoryLower.contains('beer') ||
        categoryLower.contains('wine')) {
      return Colors.purple;
    } else {
      return Colors.grey;
    }
  }
}
