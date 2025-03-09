// import 'dart:convert';
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
//
// class CategoryCubit extends Cubit<CategoryState> {
//   CategoryCubit() : super(CategoryInitial());
//
//   Future<String> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token') ?? '';
//   }
//
//   Future<void> fetchCategories() async {
//     emit(CategoryLoading());
//     final url = Uri.parse('https://harajalmamlaka.com/api/categories/ar/index');
//     final token = await _getToken();
//
//     if (token.isEmpty) {
//       emit(CategoryError('Token not found'));
//       return;
//     }
//
//     try {
//       final headers = {'Authorization': 'Bearer $token'};
//       final response = await http.get(url, headers: headers);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body)['data'] as List;
//         emit(CategoriesLoaded(data));
//       } else {
//         emit(CategoryError('Failed to load categories: ${response.body}'));
//       }
//     } catch (e) {
//       emit(CategoryError('Error: $e'));
//     }
//   }
//
//   Future<void> fetchSubcategories(int categoryId) async {
//     emit(CategoryLoading());
//     final url = Uri.parse('https://harajalmamlaka.com/api/categories/$categoryId');
//     final token = await _getToken();
//
//     if (token.isEmpty) {
//       emit(CategoryError('Token not found'));
//       return;
//     }
//
//     try {
//       final headers = {'Authorization': 'Bearer $token'};
//       final response = await http.get(url, headers: headers);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body)['data'];
//         final List<dynamic> subcategories = data['subcategories'] ?? [];
//         emit(SubcategoriesLoaded(subcategories));
//       } else {
//         emit(CategoryError('Failed to load subcategories: ${response.body}'));
//       }
//     } catch (e) {
//       emit(CategoryError('Error: $e'));
//     }
//   }
//
//   Future<void> fetchProducts(int subcategoryId) async {
//     emit(CategoryLoading());
//     final url =
//     Uri.parse('https://harajalmamlaka.com/api/subcategories/$subcategoryId');
//     final token = await _getToken();
//
//     if (token.isEmpty) {
//       emit(CategoryError('Token not found'));
//       return;
//     }
//
//     try {
//       final headers = {'Authorization': 'Bearer $token'};
//       final response = await http.get(url, headers: headers);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body)['data'];
//         final products = data['products'] ?? [];
//         emit(ProductsLoaded(products));
//       } else {
//         emit(CategoryError('Failed to load products: ${response.body}'));
//       }
//     } catch (e) {
//       emit(CategoryError('Error: $e'));
//     }
//   }
// }
