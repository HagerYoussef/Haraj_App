import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// نموذج الفئة (Category)
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

/// الفئة الأساسية التي تمثل الحالة
abstract class CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;

  CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);
}

/// الكيوبت لجلب الفئات
class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(CategoryLoading());

  /// دالة لجلب الفئات من الـ API
  Future<void> fetchCategories() async {
    emit(CategoryLoading());
    final url = Uri.parse('https://harajalmamlaka.com/api/categories/ar/index');
    try {
      // جلب التوكن من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '130|TUHrXzvL11mrXtR73rrhCG2CTaosPrxzOpyvq8dK75862981';
      debugPrint('Token: $token');

      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // التحقق من حالة الاستجابة
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;

        if (data.isNotEmpty) {
          final categories =
          data.map((item) => Category.fromJson(item)).toList();
          emit(CategoryLoaded(categories));
        } else {
          emit(CategoryError('No categories found.'));
        }
      } else {
        emit(CategoryError(
            'Failed to load categories: ${response.reasonPhrase}'));
      }
    } catch (e) {
      debugPrint('Error: $e');
      emit(CategoryError('Error: $e'));
    }
  }
}
