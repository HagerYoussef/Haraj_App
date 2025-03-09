

import 'package:untitled22/features/home/data/models/sub_category_model.dart';

import 'creator_model.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final String price;
  final String location;
  final int subcategoryId;
  final int userId;
  final String status;
  final List<String> images;
  final Creator creator;
  final SubCategory subCategory;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.subcategoryId,
    required this.userId,
    required this.status,
    required this.images,
    required this.creator,
    required this.subCategory,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      location: json['location'],
      subcategoryId: json['subcategory_id'],
      userId: json['user_id'],
      status: json['status'],
      images: List<String>.from(json['images'] ?? []),
      creator: Creator.fromJson(json['creator']),
      subCategory: SubCategory.fromJson(json['subcategory']),
    );
  }
}



