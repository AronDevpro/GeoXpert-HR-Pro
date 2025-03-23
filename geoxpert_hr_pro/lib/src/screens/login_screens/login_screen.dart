import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/common_widget/login_screen/background_and_card.dart';
import 'package:geoxpert_hr_pro/src/constants/colors.dart';
import 'package:geoxpert_hr_pro/src/services/api_service.dart';
import 'package:geoxpert_hr_pro/src/services/app_routes.gr.dart';
import 'package:geoxpert_hr_pro/src/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../model/User.dart';
import '../../providers/auth_notifier.dart';
import '../../services/token_storage.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _authService = AuthService();
  final TokenStorage tk = TokenStorage();
  final ApiService api = ApiService();
  User? user;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = "ideatidy@gmail.com";
    _passwordController.text = "password123";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    bool isLogged = await _authService.checkAuthStatus();
    if (isLogged) {
      _logOneSignal();
      authNotifier.setLoggedIn(true);
      AutoRouter.of(context).replace(HomeRoute());
    } else {
      print("User data is null");
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _logOneSignal() async {
    final userData = await tk.getUser();
    if (userData != null) {
      setState(() {
        user = userData;
      });
    }
  }

  void _fetchLogin(BuildContext context) async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final isSuccess = await _authService.login(
        _emailController.text, _passwordController.text, authNotifier);

    if (isSuccess) {
      AutoRouter.of(context).replace(const HomeRoute());
    } else {
      Alert(
        context: context,
        type: AlertType.error,
        title: "Login Failed",
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            width: 120,
            child: const Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
        desc: "Please try again!",
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundAndCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("EMAIL ADDRESS",
              style: TextStyle(
                  color: WHITE, fontWeight: FontWeight.w700, fontSize: 10)),
          const SizedBox(
            height: 3,
          ),
          TextField(
            controller: _emailController,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, height: 2.0),
            decoration: const InputDecoration(
              fillColor: TEXTFIELD,
              filled: true,
              hintText: 'ENTER YOUR EMAIL ADDRESS',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(7)),
              ),
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          const Text("PASSWORD",
              style: TextStyle(
                  color: WHITE, fontWeight: FontWeight.w700, fontSize: 10)),
          const SizedBox(
            height: 3,
          ),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, height: 2.0),
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(7)),
              ),
              fillColor: TEXTFIELD,
              filled: true,
              hintText: 'ENTER YOUR PASSWORD',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
            textAlignVertical: TextAlignVertical.center,
          ),
          const SizedBox(
            height: 1.0,
          ),
          TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero, foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pushNamed(context, '/forget-password');
            },
            child: const Text(
              "FORGET PASSWORD ?",
              style: TextStyle(
                  color: WHITE, fontWeight: FontWeight.w700, fontSize: 10),
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
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
              child: const Text('LOGIN',
                  style: TextStyle(
                      color: WHITE, fontSize: 13, fontWeight: FontWeight.w700)),
              onPressed: () => _fetchLogin(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
