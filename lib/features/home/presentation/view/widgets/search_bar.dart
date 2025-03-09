import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xffD3D3D3)),
      ),
      child: Row(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // الأيقونة (تظهر في الجهة المعاكسة للاتجاه)
          const Icon(Icons.search, color: Colors.grey),

          // حقل البحث
          Expanded(
            child: TextField(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(
                hintText: isRTL ? 'ابحث في حراج' : 'Search in haraj',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}