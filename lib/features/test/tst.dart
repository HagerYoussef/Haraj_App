import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class X extends StatefulWidget {
  const X({Key? key}) : super(key: key);

  @override
  State<X> createState() => _XState();
}

class _XState extends State<X> {
  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = fetchCategories();
  }

  Future<List<dynamic>> fetchCategories() async {
    final url = Uri.parse('https://harajalmamlaka.com/api/categories/ar/index');
    const token = '34|eKQPS9mSyPk26h9UHo7uEh3MyqY5e23KkAFTpzrjb9ed3605'; // استبدل YOUR_TOKEN_HERE بالتوكن الخاص بك.

    try {
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data;
      } else {
        throw Exception('Failed to load categories: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:  Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category['name']),
                  subtitle: Text('ID: ${category['id']}'),
                );
              },
            );
          } else {
            return const Center(child: Text('No categories found.'));
          }
        },
      ),
    ));
  }
}
