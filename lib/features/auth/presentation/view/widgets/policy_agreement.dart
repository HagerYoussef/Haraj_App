import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../lang/language_manager.dart';

class PolicyAgreement extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const PolicyAgreement({
    Key? key,
    required this.isChecked,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Checkbox(
          activeColor: ColorApp.green_color,
          value: isChecked,
          onChanged: onChanged,
        ),

        Expanded(
          child: RichText(

            text: TextSpan(
              text: AppLocalizations.of(context)!.translate("agree"),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),

              children: [
                TextSpan(
                  text:  AppLocalizations.of(context)!.translate("agree2"),
                  style: TextStyle(
                    fontSize: 25.sp,

                    fontWeight: FontWeight.bold,
                    color: ColorApp.green_color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
