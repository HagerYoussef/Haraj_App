import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/colors.dart';

class ProductHeader extends StatelessWidget {
  final Map<String, dynamic> productDetails;

  const ProductHeader({Key? key, required this.productDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfffaf9fc),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              productDetails['title'],
              style: TextStyle(
                fontSize: 24.sp,
                color: ColorApp.green_color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
           SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    "منذ 5 ساعات",
                    style: const TextStyle(color: Colors.grey),
                  ),
                   SizedBox(width: 8.w),
                  const Icon(Icons.access_time, color: Colors.grey),
                ],
              ),
               SizedBox(width: 10.w),
              Row(
                children: [
                  Text(
                    "غير متوفر",
                    style:  TextStyle(fontSize: 16.sp),
                  ),
                   SizedBox(width: 8.w),
                  const Icon(Icons.location_on, color: Colors.grey),
                ],
              ),
            ],
          ),
           SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'اسم الشخص',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorApp.green_color,
                ),
              ),
              const SizedBox(width: 5),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(productDetails['image']),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
