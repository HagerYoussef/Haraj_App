import 'package:flutter/material.dart';

import '../../../../lang/language_manager.dart';
import 'modal_input_field.dart';

class PasswordInputField extends StatelessWidget {
  final TextEditingController controller;

  const PasswordInputField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalInputField(
      label: '',
      hintText: AppLocalizations.of(context)!.translate("pass"),

      icon: Icons.lock_outline,
      
      controller: controller, keyboardType: TextInputType.visiblePassword,
    );
  }
}
