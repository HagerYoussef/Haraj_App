
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../home/presentation/view/home_view.dart';
import '../../view_model/login_cubit.dart';
import '../../view_model/login_states.dart';
import 'email_input_field.dart';
import 'login_button.dart';
import 'modal_header.dart';
import 'password_input_field.dart';
import 'policy_agreement.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({Key? key}) : super(key: key);

  @override
  State<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<LoginViewBody> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          await _handleLoginSuccess(state.token, context);
        } else if (state is LoginFailure) {
          Navigator.of(context).pop();
          _showSnackBar(context,'Login Failed', Colors.red);
        }
      },
      builder: (context, state) {
        return Wrap(

          children: [
            const ModalHeader(),
             SizedBox(height: 10.h),
            EmailInputField(controller: emailController),
             SizedBox(height: 10.h),
            PasswordInputField(controller: passwordController),
             SizedBox(height: 10.h),
            PolicyAgreement(
              isChecked: isChecked,
              onChanged: (value) {
                setState(() {
                  isChecked = value ?? false;
                });
              },
            ),
             SizedBox(height: 20.h),
            state is LoginLoading
                ? const CircularProgressIndicator()
                : LoginButton(
              isChecked: isChecked,
              emailController: emailController,
              passwordController: passwordController,
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLoginSuccess(String token, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('email', emailController.text);

    _showSnackBar(context, 'Login Successful!', Colors.green);
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, HomeView.routeName);
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
