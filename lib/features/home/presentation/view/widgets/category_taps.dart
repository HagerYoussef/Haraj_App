import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'category_tap.dart'; // لتحويل الاستجابة من الـ API

class CategoryTabs extends StatelessWidget {
  final Function(int) onCategorySelected; // عند اختيار التصنيف
  final List<dynamic> categories; // إضافة معلمة الفئات

  const CategoryTabs({
    Key? key,
    required this.onCategorySelected,
    required this.categories, // استلام الفئات كمعامل
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding:  EdgeInsets.only(right: 15.w),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              return CategoryTab(
                label: category['name'], // اسم الفئة من الـ API
                isSelected: false,  // يمكن تخصيص هذه القيمة حسب الحاجة
                onTap: () {
                  onCategorySelected(category['id']); // عند النقر على الفئة
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
