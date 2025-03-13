import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/services/app_routes.gr.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../model/User.dart';
import '../providers/auth_notifier.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

class Header extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final bool hasAppBar;

  const Header(
      {super.key,
      required this.child,
      required this.currentRoute,
      required this.hasAppBar});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late String selectedTile;
  bool hasAppBar = true;
  final _authService = AuthService();
  final TokenStorage tk = TokenStorage();
  User? user;
  bool isLoading = false;

  Future<void> _fetchUser() async {
    try {
      final userData = await tk.getUser();
      setState(() {
        user = userData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedTile = widget.currentRoute;
    hasAppBar = widget.hasAppBar;
    _fetchUser();
  }

  void _logout() {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    _authService.logout(authNotifier);
    context.router.push(LoginRoute());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: hasAppBar
          ? AppBar(
              backgroundColor: PRIMARY,
              automaticallyImplyLeading: false,
              leading: Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Icon(
                    Icons.menu,
                    color: WHITE,
                    size: 25,
                  ),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        (selectedTile ?? "").substring(0, 1).toUpperCase() +
                            (selectedTile ?? "").substring(1).toLowerCase(),
                        style: const TextStyle(
                          fontFamily: "Bruce Forever",
                          color: WHITE,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: WHITE,
                      size: 20,
                    ),
                  ),
                ),
              ],
            )
          : null,
      // appBar: AppBar(backgroundColor: PRIMARY,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      // ),
      body: Container(
        child: widget.child,
      ),
      // child: SafeArea()),
      drawer: Drawer(
        backgroundColor: DARK,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: DARK,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const ClipOval(
                          child: Icon(
                        Icons.person,
                        color: WHITE,
                        size: 40,
                      )),
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape:
                                WidgetStatePropertyAll<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            backgroundColor:
                                const WidgetStatePropertyAll<Color>(GREY),
                          ),
                          onPressed: _logout,
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Text('LOGOUT',
                                  style: TextStyle(
                                      color: WHITE,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      user?.name ?? 'Loading...',
                      style: const TextStyle(
                          color: WHITE, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, 'HOME', Icons.home, '/home'),
            _buildDrawerItem(
                context, 'ATTENDANCE HISTORY', Icons.timer, '/attendance'),
            _buildDrawerItem(
                context, 'SALARY HISTORY', Icons.monetization_on, '/salary'),
            _buildDrawerItem(
                context, 'APPLY LEAVE', Icons.calendar_today, '/leave'),
            _buildDrawerItem(context, 'HELP', Icons.help, '/help'),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData iconData, String? route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedTile == route ? PRIMARY : WHITE.withOpacity(0.6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
          color: SECONDARY.withOpacity(0.6),
        ),
        child: ListTile(
          leading: Icon(
            iconData,
            color: WHITE,
            size: 20,
          ),
          title: Text(title,
              style: const TextStyle(
                  color: WHITE, fontSize: 11, fontWeight: FontWeight.w700)),
          onTap: route != null
              ? () {
                  setState(() {
                    selectedTile = route;
                  });

                  if (route == '/home') {
                    AutoRouter.of(context).replace(const HomeRoute());
                  } else if (route == '/attendance') {
                    // AutoRouter.of(context).replace(AttendanceRoute());
                  } else if (route == '/salary') {
                    AutoRouter.of(context).replace(SalaryRoute());
                  } else if (route == '/leave') {
                    AutoRouter.of(context).replace(LeaveRoute());
                  } else if (route == '/help') {
                    // AutoRouter.of(context).replace(HelpRoute());
                  }
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildDrawerSubItem(
      BuildContext context, String title, String assetPath, String? route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedTile == route ? PRIMARY : WHITE.withOpacity(0.6),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
            color: SECONDARY.withOpacity(0.6),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.history,
              size: 25,
              color: BLUE2,
            ),
            //leading: Image.asset(assetPath, width: 20, color: BLUE2),
            title: Text(title,
                style: const TextStyle(
                    color: WHITE, fontSize: 11, fontWeight: FontWeight.w700)),
            onTap: route != null
                ? () {
                    setState(() {
                      selectedTile = route;
                    });
                    Navigator.pop(context);
                    Navigator.pushNamed(context, route);
                  }
                : null,
          ),
        ),
      ),
    );
  }
}
