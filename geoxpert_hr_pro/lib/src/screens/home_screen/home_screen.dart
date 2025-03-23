import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoxpert_hr_pro/src/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../common_widget/header.dart';
import '../../constants/colors.dart';
import '../../model/AttendanceList.dart';
import '../../model/User.dart';
import '../../services/app_routes.gr.dart';
import '../../services/token_storage.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TokenStorage tk = TokenStorage();
  ApiService apiService = ApiService();
  User? user;
  Map<String, dynamic>? attendance;
  bool isLoading = false;
  String clockInAt = "";
  bool clockedIn = false;
  double todayHours = 0;
  List<AttendanceList>? attendanceList;
  int limit = 10;
  final ScrollController _scrollController = ScrollController();
  bool isPullLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchUser() async {
    try {
      final userData = await tk.getUser();
      setState(() {
        user = userData;
        isLoading = false;
      });
      getAttendance();
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String getFormattedTime() {
    DateTime now = DateTime.now();
    DateFormat timeFormat = DateFormat('HH:mm');
    return timeFormat.format(now);
  }

  Future<void> onRefresh() async {
    if (limit < 30) {
      setState(() {
        limit = limit + 5;
        getAttendance();
      });
    }
  }

  Future<void> _clockIn() async {
    try {
      setState(() {
        isLoading = true;
      });
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      String clockInTime = getFormattedTime();

      // Get current location (longitude, latitude)
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double longitude = position.longitude;
      double latitude = position.latitude;

      Map<String, dynamic> attendanceData = {
        'clockInTime': clockInTime,
        'longitude': longitude,
        'latitude': latitude,
      };

      final response =
          await apiService.post('attendances/${user?.id}', attendanceData);

      if (response.statusCode == 201) {
        var responseData = json.decode(response.body);
        setState(() {
          clockedIn = true;
          isLoading = false;
          clockInAt = responseData['data']['clockIn']['time'] ?? 'Unknown time';
        });
        print('Clock-in successful at $clockInAt!');
      } else {
        setState(() {
          isLoading = false;
        });
        var responseData = json.decode(response.body);
        String message = responseData['message'] ?? 'Failed to clock-in';
        Alert(
          context: context,
          type: AlertType.error,
          title: "Failed to clock-in",
          desc: message,
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
        print('Failed to clock-in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error during clock-in: $e");
      Alert(
        context: context,
        type: AlertType.error,
        title: "Error during clock-in",
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
        desc: "Something went wrong. Please try again later!",
      ).show();
    }
  }

  Future<void> _clockOut() async {
    try {
      setState(() {
        isLoading = true;
      });
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      String clockOutTime = getFormattedTime();

      // Get current location (longitude, latitude)
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double longitude = position.longitude;
      double latitude = position.latitude;

      Map<String, dynamic> attendanceData = {
        'clockOutTime': clockOutTime,
        'longitude': longitude,
        'latitude': latitude,
      };

      final response =
          await apiService.put('attendances/${user?.id}', attendanceData);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        setState(() {
          clockedIn = false;
          todayHours = responseData['data']['totalHours'];
          isLoading = false;
        });
        print('Clock-out successful - $todayHours!');
      } else {
        var responseData = json.decode(response.body);
        String message = responseData['message'] ?? 'Failed to clock-out';
        Alert(
          context: context,
          type: AlertType.error,
          title: "Failed to clock-out",
          desc: message,
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
        print('Failed to clock-out. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error during clock-out: $e");
      Alert(
        context: context,
        type: AlertType.error,
        title: "Error during clock-out",
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
        desc: "Something went wrong. Please try again later!",
      ).show();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Hello';
    }
  }

  Future<void> getAttendance() async {
    try {
      setState(() {
        isPullLoading = true;
      });
      final response =
          await apiService.get('attendances/${user?.id}?limit=$limit');
      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        final List<dynamic> contentData = jsonData['content'];

        List<AttendanceList> fetchedAttendanceList =
            contentData.map((json) => AttendanceList.fromJson(json)).toList();
        setState(() {
          attendanceList = fetchedAttendanceList;
        });
      } else {
        print(
            'Failed to fetch attendance data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
    } finally {
      setState(() {
        isPullLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (isPullLoading) {
      return;
    }
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Header(
      hasAppBar: false,
      currentRoute: '/home',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                  color: PRIMARY,
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (user != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${getGreeting()}, ${user?.name}!',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: WHITE,
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  getGreeting(),
                                  style: const TextStyle(color: WHITE),
                                ),
                              ),
                            Builder(
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: AlignmentDirectional.bottomEnd,
                height: 210,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Salary Button
                    GestureDetector(
                      onTap: () {
                        AutoRouter.of(context).replace(SalaryRoute());
                      },
                      child: _buildIconContainer(
                        context,
                        "Salary",
                        Icons.monetization_on,
                        GREY3,
                      ),
                    ),
                    // Leave Button
                    GestureDetector(
                      onTap: () {
                        AutoRouter.of(context).replace(LeaveRoute());
                      },
                      child: _buildIconContainer(
                        context,
                        "Leave",
                        Icons.calendar_today,
                        GREY3,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AutoRouter.of(context).replace(HelpRoute());
                      },
                      child: _buildIconContainer(
                        context,
                        "Help",
                        Icons.help,
                        GREY3,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 300,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE1F5FE), Color(0xFFBBDEFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.indigoAccent,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!clockedIn) ...[
                          // Clock In Button
                          ElevatedButton(
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12), // More rounded corners for the button
                                ),
                              ),
                              backgroundColor:
                                  const WidgetStatePropertyAll<Color>(
                                      Color(0xFF66BB6A)), // Green color
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 75, vertical: 18),
                              ),
                            ),
                            onPressed: _clockIn,
                            child: const Text(
                              'Clock In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Not Clocked in yet',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ] else ...[
                          // Clocked In State
                          const Icon(
                            Icons.access_time,
                            color: Colors.redAccent,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            clockInAt,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12), // Rounded corners
                                ),
                              ),
                              backgroundColor: const WidgetStatePropertyAll(
                                  Colors.redAccent),
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 75, vertical: 18),
                              ),
                            ),
                            onPressed: _clockOut,
                            child: const Text(
                              'Clock Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              controller: _scrollController,
              itemCount: isPullLoading
                  ? (attendanceList?.length ?? 0) + 1
                  : (attendanceList?.length ?? 0),
              itemBuilder: (context, index) {
                if (attendanceList == null || attendanceList!.isEmpty) {
                  return const Center(
                      child: Text(
                    'No attendance data available.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ));
                }

                if (index < attendanceList!.length) {
                  final attendance = attendanceList![index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: const Color(0xfff5f5f6),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.indigoAccent,
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      title: Text(
                        attendance.createdAt.toString().split(' ')[0],
                        style: const TextStyle(
                          color: Colors.indigoAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: attendance.totalHours != null
                          ? Text(
                              '${attendance.totalHours} hours',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            )
                          : null,
                      trailing: Text(
                        attendance.status,
                        style: TextStyle(
                          color: attendance.status == "Normal"
                              ? Colors.green
                              : Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Loading indicator
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                        strokeWidth: 3,
                      ),
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIconContainer(
      BuildContext context, String label, IconData iconData, Color color) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth / 4,
      height: screenWidth / 4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: Colors.white,
              size: 35,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
