import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/common_widget/login_screen/background_and_card.dart';
import 'package:geoxpert_hr_pro/src/constants/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return BackgroundAndCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text("ENTER NEW PASSWORD", style: TextStyle(color: WHITE, fontWeight: FontWeight.w700, fontSize: 10, height: 2.0)),
      const SizedBox(height: 2,),
       TextField(
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        obscureText: _obscureNewPassword,
        decoration: InputDecoration(
          fillColor: TEXTFIELD,
          filled: true,
          hintText: 'PASSWORD',
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNewPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
      const SizedBox(height: 15.0,),
      const Text("CONFIRM PASSWORD", style: TextStyle(color: WHITE, fontWeight: FontWeight.w700, fontSize: 10)),
      const SizedBox(height: 2,),
            TextField(
              obscureText: _obscureConfirmPassword,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 2.0),
              decoration: InputDecoration(
          fillColor: TEXTFIELD,
          filled: true,
          hintText: 'PASSWORD',
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
            const SizedBox(height: 15,),
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
                child: const Text('CHANGE PASSWORD', style: TextStyle(color: WHITE, fontSize: 13, fontWeight: FontWeight.w700)),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
            ),
      ],
      ),
    );
  }
}
