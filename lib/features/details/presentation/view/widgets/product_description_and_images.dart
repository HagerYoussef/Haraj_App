import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'image_dialog.dart';

class ProductDescriptionAndImages extends StatelessWidget {
  final Map<String, dynamic> productDetails;

  const ProductDescriptionAndImages({Key? key, required this.productDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // التأكد من أن الصورة موجودة في المنتج
    final imageUrl = productDetails['image'];

    return Container(
      color: const Color(0xfff3f3f3),
      child: Column(
        children: [
          // عرض الوصف
          Text(
            productDetails['description'],
            style:  TextStyle(fontSize: 16.sp),
          ),
          // عرض الصور في قائمة قابلة للنقر
          Column(
            children: List.generate(4, (index) {
              return GestureDetector(
                onTap: () {
                  // عند النقر على الصورة، عرض الـ Dialog
                  showDialog(
                    context: context,
                    builder: (context) => ImageDialog(
                      imageUrls: [
                        imageUrl,
                        imageUrl,
                        imageUrl,
                      ],
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 500.h,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl), // تحميل الصورة من الرابط
                      fit: BoxFit.cover,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 5.0.w,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
