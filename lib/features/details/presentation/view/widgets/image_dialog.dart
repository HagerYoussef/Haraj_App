import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageDialog extends StatelessWidget {
  final List<String> imageUrls;

  const ImageDialog({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PageController _controller = PageController();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Center(
          child: PageView.builder(
            controller: _controller,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Image.network(
                imageUrls[index],
                fit: BoxFit.contain,
                height: 500.h,
                width: 500.w,
              );
            },
          ),
        ),
      ),
    );
  }
}
