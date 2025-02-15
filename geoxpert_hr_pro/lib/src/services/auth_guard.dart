import 'package:auto_route/auto_route.dart';
import 'app_routes.gr.dart';
import 'auth_service.dart';

class AuthGuard extends AutoRouteGuard {
  final AuthService _authService = AuthService();

  @override
  Future<void> onNavigation(
      NavigationResolver resolver, StackRouter router) async {
    if (await _authService.checkAuthStatus()) {
      resolver.next(true);
    } else {
      resolver.redirect(LoginRoute());
    }
  }
}
