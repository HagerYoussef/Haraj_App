import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light); // الوضع الافتراضي هو Light

  void toggleTheme() {
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark); // إذا كان في الوضع الفاتح، حوله للظلام
    } else {
      emit(ThemeMode.light); // إذا كان في الوضع المظلم، حوله للفاتح
    }
  }
}
