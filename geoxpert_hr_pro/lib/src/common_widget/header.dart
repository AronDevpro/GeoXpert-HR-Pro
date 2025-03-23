import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/services/api_service.dart';
import 'package:geoxpert_hr_pro/src/services/app_routes.gr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../constants/colors.dart';
import '../model/User.dart';
import '../providers/auth_notifier.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import 'package:http/http.dart' as http;

import 'login_screen/editable_profile_image.dart';

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
  final ApiService api = ApiService();
  User? user;
  bool isLoading = false;
  File? _profileImage;

  // Image picker setup
  final ImagePicker _picker = ImagePicker();

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

  // Handle Image Picking
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadImageToCloudinary(_profileImage!);
    }
  }

  // Handle Image Upload to Cloudinary
  Future<void> _uploadImageToCloudinary(File imageFile) async {
    try {
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/dhugpjgpm/image/upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = 'flutter';
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(responseData.body);
        String imageUrl = data['secure_url'];

        setState(() {
          user?.photo = imageUrl;
        });

        final Map<String, dynamic> payload = {
          'photo': imageUrl,
        };
        print(imageUrl);

        final response = await api.put('employees/${user?.id}', payload);
        if (response.statusCode != 200) {
          Alert(
            context: context,
            type: AlertType.error,
            title: 'Failed to upload image',
            desc: 'Please try again',
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
          ).show();
        }
      } else {
        print('Failed to upload image');
        Alert(
          context: context,
          type: AlertType.error,
          title: 'Failed to upload image',
          desc: 'Please try again',
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
        ).show();
      }
    } catch (e) {
      print('Error uploading image: $e');
      Alert(
        context: context,
        type: AlertType.error,
        title: 'Error uploading image',
        desc: 'Please try again',
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
      ).show();
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
                      EditableProfileImage(
                        photoUrl: user?.photo,
                        localImage: _profileImage,
                        onEdit: _pickImage,
                      ),
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
                    // } else if (route == '/attendance') {
                    // AutoRouter.of(context).replace(AttendanceRoute());
                  } else if (route == '/salary') {
                    AutoRouter.of(context).replace(const SalaryRoute());
                  } else if (route == '/leave') {
                    AutoRouter.of(context).replace(const LeaveRoute());
                  } else if (route == '/help') {
                    AutoRouter.of(context).replace(HelpRoute());
                  }
                }
              : null,
        ),
      ),
    );
  }
}
