import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../lang/language_manager.dart';

class RegisterButton extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onRegister;

  const RegisterButton({
    Key? key,
    required this.isChecked,
    required this.onRegister,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isChecked ? onRegister : null,
      child: Container(
        width: double.infinity,
        padding:  EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: isChecked ? ColorApp.green_color : Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child:  Text(
          AppLocalizations.of(context)!.translate("register"),
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
