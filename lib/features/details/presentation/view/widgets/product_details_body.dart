import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled22/features/details/presentation/view/widgets/product_description_and_images.dart';
import 'package:untitled22/features/details/presentation/view/widgets/product_header.dart';

class ProductDetailsBody extends StatelessWidget {
  final Map<String, dynamic> productDetails;
  final List<Map<String, dynamic>> similarProducts;

  const ProductDetailsBody({
    Key? key,
    required this.productDetails,
    required this.similarProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductHeader(productDetails: productDetails),
             SizedBox(height: 30.h),
            ProductDescriptionAndImages(productDetails: productDetails),
             SizedBox(height: 30.h),
            //SimilarProductsSection(similarProducts: similarProducts),
          ],
        ),
      ),
    );
  }
}
