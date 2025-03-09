import 'package:flutter/material.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../lang/language_manager.dart';

class ModalHeader extends StatelessWidget {
  const ModalHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.translate("can"), style: TextStyle(color: ColorApp.green_color)),
        ),
        Expanded(
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.translate("log/reg"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
