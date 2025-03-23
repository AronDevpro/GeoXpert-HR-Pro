import 'package:auto_route/auto_route.dart';
import 'app_routes.gr.dart';
import 'auth_guard.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, path: '/home',guards: [AuthGuard()] ),
    AutoRoute(page: SalaryRoute.page, path: '/salary',guards: [AuthGuard()] ),
    AutoRoute(page: LeaveRoute.page, path: '/leave',guards: [AuthGuard()] ),
    AutoRoute(page: HelpRoute.page, path: '/help',guards: [AuthGuard()] ),
    AutoRoute(page: LoginRoute.page, path: '/',initial: true, keepHistory: false),
  ];
}
