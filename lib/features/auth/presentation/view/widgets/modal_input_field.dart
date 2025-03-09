import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModalInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final TextEditingController controller;

  const ModalInputField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.keyboardType,
    required this.controller,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        if (label.isNotEmpty)
          Align(

            child: Text(label),
          ),
         SizedBox(height: 10.h),
        Container(
          padding:  EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(

            children: [
              Icon(icon, color: Colors.grey),
               SizedBox(width: 10.w),
              Expanded(
                child: TextFormField(
                  controller: controller,

                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                  keyboardType: keyboardType,
                  obscureText: keyboardType == TextInputType.visiblePassword,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
