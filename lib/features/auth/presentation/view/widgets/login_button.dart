import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../lang/language_manager.dart';
import '../../view_model/login_cubit.dart';

class LoginButton extends StatelessWidget {
  final bool isChecked;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginButton({
    Key? key,
    required this.isChecked,
    required this.emailController,
    required this.passwordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isChecked
          ? () {
        context.read<LoginCubit>().loginUser(
          emailController.text,
          passwordController.text,
        );
      }
          : null,
      child: Container(
        width: double.infinity,
        padding:  EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: isChecked ? ColorApp.green_color : ColorApp.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child:  Text(
          AppLocalizations.of(context)!.translate("login2"),
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
