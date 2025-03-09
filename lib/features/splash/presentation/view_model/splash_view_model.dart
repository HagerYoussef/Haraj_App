
import 'package:flutter/material.dart';

import '../../../home/presentation/view/home_view.dart';

class SplashViewModel {
  void navigateToHome(BuildContext context) {
      Future.delayed(const Duration(seconds: 3), () {
         Navigator.pushReplacementNamed(context, HomeView.routeName);
    });
  }
}
