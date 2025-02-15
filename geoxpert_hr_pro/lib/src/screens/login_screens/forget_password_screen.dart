import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/common_widget/login_screen/background_and_card.dart';
import 'package:geoxpert_hr_pro/src/constants/colors.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundAndCard(
      child: Column(
        children: [
          const TextField(
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 2.0),
            decoration: InputDecoration(
              fillColor: TEXTFIELD,
              filled: true,
              hintText: 'ENTER YOUR EMAIL ADDRESS',
            ),
          ),
          const SizedBox(height: 10,),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                backgroundColor: const WidgetStatePropertyAll<Color>(GREY),
              ),
              child: const Text('NEXT', style: TextStyle(color: WHITE, fontSize: 13, fontWeight: FontWeight.w700)),
              onPressed: () {
                Navigator.pushNamed(context, '/verify-otp');
              },
            ),
          ),
        ],
      ),
    );
  }
}
