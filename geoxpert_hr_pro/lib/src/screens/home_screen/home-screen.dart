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
          clockInAt = responseData['data']['clockIn']['time'] ?? 'Unknown time';
        });
        print('Clock-in successful at $clockInAt!');
        print(clockedIn);
      } else {
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
      return 'Good night';
    }
  }

  Future<void> getAttendance() async {
    try {
      setState(() {
        isPullLoading = true;
      });
      final response =
          await apiService.get('attendances/${user?.id}?limit=${limit}');
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
    ;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                      const SizedBox(height: 25),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: AlignmentDirectional.bottomEnd,
                height: 210,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: (){
                        AutoRouter.of(context).replace(SalaryRoute());
                      },
                      child: Container(
                        width: screenWidth / 4,
                        height: screenWidth / 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: GREY3,
                          borderRadius:
                              BorderRadiusDirectional.all(Radius.circular(5)),
                        ),
                        child: const Center(
                          child: Text(
                            "Salary",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        AutoRouter.of(context).replace(LeaveRoute());
                      },
                      child: Container(
                        width: screenWidth / 4,
                        height: screenWidth / 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: GREY3,
                          borderRadius:
                              BorderRadiusDirectional.all(Radius.circular(5)),
                        ),
                        child: const Center(
                          child: Text(
                            "Leave",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: screenWidth / 4,
                      height: screenWidth / 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: GREY3,
                        borderRadius:
                            BorderRadiusDirectional.all(Radius.circular(5)),
                      ),
                      child: const Center(
                        child: Text(
                          "Leave",
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: GREY3),
                shape: BoxShape.rectangle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!clockedIn) ...[
                    SizedBox(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          backgroundColor:
                              WidgetStateProperty.all<Color>(GREEN),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 75, vertical: 25),
                          ),
                        ),
                        onPressed: _clockIn,
                        child: const Text(
                          'Clock In',
                          style: TextStyle(
                            color: WHITE,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Not Clocked in yet',
                      style: TextStyle(color: GREY, fontSize: 12),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.access_time,
                      color: RED,
                      size: 40,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      clockInAt,
                      style: const TextStyle(
                        color: BLACK,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          backgroundColor:
                              WidgetStateProperty.all<Color>(RED),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 75, vertical: 25),
                          ),
                        ),
                        onPressed: _clockOut,
                        child: const Text(
                          'Clock Out',
                          style: TextStyle(
                            color: WHITE,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
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
              padding: const EdgeInsets.all(5),
              controller: _scrollController,
              itemCount: isPullLoading
                  ? (attendanceList?.length ?? 0) + 1
                  : (attendanceList?.length ?? 0),
              itemBuilder: (context, index) {
                if (attendanceList == null || attendanceList!.isEmpty) {
                  return const Center(
                      child: Text('No attendance data available.'));
                }

                if (index < attendanceList!.length) {
                  final attendance = attendanceList![index];
                  print(attendance);

                  return Card(
                    color: Colors.blue,
                    child: ListTile(
                      leading: const Icon(Icons.circle),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      title:
                          Text(attendance.createdAt.toString().split(' ')[0]),
                      subtitle: Text(
                        attendance.totalHours != null
                            ? '${attendance.totalHours} hours'
                            : '',
                      ),
                      trailing: Text(attendance.status),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
