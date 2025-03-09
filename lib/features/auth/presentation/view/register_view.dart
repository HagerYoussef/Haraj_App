import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled22/features/auth/presentation/view/widgets/modal_header.dart';
import 'package:untitled22/features/auth/presentation/view/widgets/modal_input_field.dart';
import 'package:untitled22/features/auth/presentation/view/widgets/policy_agreement.dart';

import '../../../../core/themes/colors.dart';
import '../../../lang/language_manager.dart';
import '../../data/models/register_model.dart';
import '../view_model/register_cubit.dart';
import '../view_model/register_states.dart';
import 'widgets/register_button.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewtState createState() => _RegisterViewtState();
}

class _RegisterViewtState extends State<RegisterView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state)async {
           if (state is RegisterSuccess) {
            Navigator.pop(context);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', _usernameController.text);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Register Success'),
                backgroundColor: ColorApp.green_color,
              ),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, 'Home Screen');
            });
          } else if (state is RegisterFailure) {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(

              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Register Failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ModalHeader(),
                 SizedBox(height: 10.h),
                ModalInputField(
                  controller: _usernameController,
                  hintText: AppLocalizations.of(context)!.translate("user"),

                  icon: Icons.person_outline,

                  keyboardType: TextInputType.text, label: '',
                ),
                 SizedBox(height: 10.h),
                ModalInputField(
                  controller: _emailController,
                  hintText: AppLocalizations.of(context)!.translate("log"),
                  icon: Icons.email_outlined,

                  keyboardType: TextInputType.emailAddress, label: '',
                ),
                 SizedBox(height: 10.h),
                ModalInputField(
                  controller: _passwordController,
                  hintText:AppLocalizations.of(context)!.translate("pass"),
                  icon: Icons.lock_outline,

                  keyboardType: TextInputType.visiblePassword, label: '',
                ),
                 SizedBox(height: 10.h),
                PolicyAgreement(
                  isChecked: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                RegisterButton(
                  isChecked: isChecked,
                  onRegister: () {
                    if (isChecked) {
                      final registerModel = RegisterModel(
                        username: _usernameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      context.read<RegisterCubit>().registerUser(registerModel);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You must agree to the terms')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

