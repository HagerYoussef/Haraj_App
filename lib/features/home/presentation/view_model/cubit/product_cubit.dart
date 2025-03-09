import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:untitled22/features/home/presentation/view_model/cubit/prodyuct_state.dart';

import '../../../data/models/product_model.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  Future<void> fetchProducts({int? id, int? categoryId, int? subCategoryId}) async {
    emit(ProductsLoading());

    final baseUrl = 'https://harajalmamlaka.com/api/products';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '3|HEuIaDZxdEJWF0AKEi5gWFZqOW6UDZi4XLBl5bkk02a82950';

      final headers = {'Authorization': 'Bearer $token'};

      // بناء الرابط بناءً على الـ id
      String fetchUrl = baseUrl;
      if (id != null) {
        fetchUrl = '$fetchUrl/$id'; // إذا كان هناك id محدد
      } else if (subCategoryId != null) {
        fetchUrl = '$fetchUrl?subcategory=$subCategoryId';
      } else if (categoryId != null) {
        fetchUrl = '$fetchUrl?category=$categoryId';
      }

      final response = await http.get(Uri.parse(fetchUrl), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        final products = data.map((item) => Product.fromJson(item)).toList();
        emit(ProductsLoaded(products));
      } else {
        emit(ProductsError('Failed to load products: ${response.body}'));
      }
    } catch (e) {
      emit(ProductsError('Error: $e'));
    }
  }
}
