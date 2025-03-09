import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/colors.dart';
import '../../view_model/splash_view_model.dart';

class SplashViewBody extends StatelessWidget {
  const SplashViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    SplashViewModel().navigateToHome(context);
    return Scaffold(
      backgroundColor: ColorApp.green_color,
      body: Center(child: Text("حراج المملكه" , style: TextStyle(
        color: ColorApp.white_color,
        fontWeight: FontWeight.bold,
        fontSize: 50.sp,
        fontFamily: 'Cairo'
      ),)),
    );
  }
}
//157347