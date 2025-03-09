import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled22/features/home/presentation/view/widgets/product_card.dart';

class ProductList extends StatelessWidget {
  final List<dynamic> products;
  final int? categoryId;
  final int? subCategoryId;

  const ProductList({
    Key? key,
    required this.products,
    this.categoryId,
    this.subCategoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      if (subCategoryId != null) {
        return product['subcategory_id'] == subCategoryId;
      } else if (categoryId != null) {
        return product['category_id'] == categoryId;
      }
      return true; // إذا لم يتم تحديد أي من الفئات، عرض جميع المنتجات
    }).toList();

    return filteredProducts.isEmpty
        ? Center(
      child: Text(
        "لا توجد منتجات في هذا القسم",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    )
        : ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, displayIndex) {
        final product = filteredProducts[displayIndex];
        return ProductCard(product: product, displayIndex: displayIndex);
      },
    );
  }
}
