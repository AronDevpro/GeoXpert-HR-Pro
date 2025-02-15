import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/common_widget/login_screen/background_and_card.dart';
import 'package:geoxpert_hr_pro/src/constants/colors.dart';

class VerifyOtp extends StatelessWidget {
  const VerifyOtp({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundAndCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ENTER THE 5 DIGIT CODE WE SENT TO YOUR EMAIL", style: TextStyle(color: WHITE, fontWeight: FontWeight.w700, fontSize: 10),
          ),
          const SizedBox(height: 5,),
          Row(
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: TextFormField(
                  autofocus: true,
                  onSaved: (pin1){},
                  onChanged: (value){
                    if (value.length ==1){
                      FocusScope.of(context).nextFocus();
                    } else {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    counterText: "",
                    fillColor: TEXTFIELD,
                    filled: true,
                    border:    OutlineInputBorder(
                        borderSide: BorderSide(
                            color: PRIMARY, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: PRIMARY, width: 2)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:  BorderSide(color: PRIMARY, width: 2),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 5,),
              SizedBox(
                height: 50,
                width: 50,
                child: TextFormField(
                  autofocus: true,
                  onSaved: (pin2){},
                  onChanged: (value){
                    if (value.length ==1){
                      FocusScope.of(context).nextFocus();
                    } else {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    counterText: "",
                    fillColor: TEXTFIELD,
                    filled: true,
                    border:    OutlineInputBorder(
                        borderSide: BorderSide(
                            color: PRIMARY, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: PRIMARY, width: 2)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:  BorderSide(color: PRIMARY, width: 2),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 5,),
              SizedBox(
                height: 50,
                width: 50,
                child: TextFormField(
                  autofocus: true,
                  onSaved: (pin3){},
                  onChanged: (value){
                    if (value.length ==1){
                      FocusScope.of(context).nextFocus();
                    } else {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    counterText: "",
                    fillColor: TEXTFIELD,
                    filled: true,
                    border:    OutlineInputBorder(
                        borderSide: BorderSide(
                            color: PRIMARY, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: PRIMARY, width: 2)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:  BorderSide(color: PRIMARY, width: 2),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 5,),
              SizedBox(
                height: 50,
                width: 50,
                child: TextFormField(
                  autofocus: true,
                  onSaved: (pin4){},
                  onChanged: (value){
                    if (value.length ==1){
                      FocusScope.of(context).nextFocus();
                    } else {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    counterText: "",
                    fillColor: TEXTFIELD,
                    filled: true,
                    border:    OutlineInputBorder(
                        borderSide: BorderSide(
                            color: PRIMARY, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: PRIMARY, width: 2)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:  BorderSide(color: PRIMARY, width: 2),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 5,),
              SizedBox(
                height: 50,
                width: 50,
                child: TextFormField(
                  autofocus: true,
                  onSaved: (pin5){},
                  onChanged: (value){
                    if (value.length ==1){
                      FocusScope.of(context).nextFocus();
                    } else {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    counterText: "",
                    fillColor: TEXTFIELD,
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: PRIMARY, width: 2)),
                        focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: PRIMARY, width: 2)),
                        enabledBorder: OutlineInputBorder(
                        borderSide:  BorderSide(color: PRIMARY, width: 2),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
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
              child: const Text('VERIFY', style: TextStyle(color: WHITE, fontSize: 13, fontWeight: FontWeight.w700)),
              onPressed: () {
                Navigator.pushNamed(context, '/change-password');
              },
            ),
          ),
        ],
      ),
    );
  }
}
