import 'package:flutter/material.dart';
import 'category_taps.dart'; // تأكد من أن هذا هو المسار الصحيح
import 'header_section.dart'; // تأكد من أن هذا هو المسار الصحيح

class HomeBody extends StatelessWidget {
  final List<dynamic> products;
  final List<dynamic> categories; // إضافة الفئات

  const HomeBody({
    Key? key,
    required this.products,
    required this.categories, // تمرير الفئات إلى HomeBody
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderSection();
  }
}
