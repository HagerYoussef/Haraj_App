import 'package:flutter/material.dart';

import '../../../../lang/language_manager.dart';
import 'modal_input_field.dart';

class EmailInputField extends StatelessWidget {
  final TextEditingController controller;

  const EmailInputField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalInputField(
      label: '',
      hintText:  AppLocalizations.of(context)!.translate("log"),
      icon: Icons.person_2_outlined,
     
      controller: controller, keyboardType: TextInputType.emailAddress,
    );
  }
}
