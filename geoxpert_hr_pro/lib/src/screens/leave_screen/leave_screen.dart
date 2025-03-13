import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/common_widget/header.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../model/Leave.dart';
import '../../model/LeaveTypes.dart';
import '../../model/User.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';

@RoutePage()
class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final TokenStorage tk = TokenStorage();
  bool isPullLoading = false;
  ApiService apiService = ApiService();
  int limit = 10;
  User? user;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  List<Leave>? leaveList;
  List<LeaveTypes>? leaveTypesList;
  TextEditingController reasonController = TextEditingController();
  String? leaveType;

  DateTime? startDate;
  DateTime? endDate;
  bool isHalfDay = false;

  Future<void> _fetchUser() async {
    try {
      final userData = await tk.getUser();
      setState(() {
        user = userData;
        isLoading = false;
      });
      getLeaveList();
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getLeaveList() async {
    try {
      setState(() {
        isPullLoading = true;
      });
      final response = await apiService.get('leaves/${user?.id}?limit=$limit');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        final List<dynamic> contentData = jsonData['content'];

        List<Leave> fetchedLeaveList =
            contentData.map((json) => Leave.fromJson(json)).toList();
        setState(() {
          leaveList = fetchedLeaveList;
        });
      } else {
        print(
            'Failed to fetch leave data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching leave data: $e');
    } finally {
      setState(() {
        isPullLoading = false;
      });
    }
  }

  Future<void> getLeaveTypes(String query) async {
    try {
      final response = await apiService.get('leaveTypes?limit=5&search=$query');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        final List<dynamic> contentData = jsonData['content'];

        List<LeaveTypes> fetchedLeaveList =
            contentData.map((json) => LeaveTypes.fromJson(json)).toList();
        setState(() {
          leaveTypesList = fetchedLeaveList;
        });
      } else {
        print(
            'Failed to fetch leave data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching leave data: $e');
    }
  }

  Future<void> createLeave() async {
    try {
      setState(() {
        isLoading = true;
      });
      final Map<String, dynamic> leaveData = {
        'leaveType': leaveType,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String() ?? startDate?.toIso8601String(),
        'isHalfDay': isHalfDay,
        'employee': user?.id
      };
      final response = await apiService.post('leaves', leaveData);
      if (response.statusCode == 201) {
        getLeaveList();
        // Reset the text and dates
        setState(() {
          leaveType = null;
          startDate = null;
          endDate = null;
          isHalfDay = false;
          reasonController.clear();
        });
        Alert(
          context: context,
          type: AlertType.success,
          title: 'Leave created successfully!',
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
      } else {
        Alert(
          context: context,
          type: AlertType.error,
          title: 'Failed to Create leave',
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
      print('Error fetching leave data: $e');
      Alert(
        context: context,
        type: AlertType.error,
        title: 'Error creating leave:',
        desc: '$e',
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _isFormValid() {
    return leaveType != null && leaveType!.isNotEmpty && startDate != null;
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

  Future<void> onRefresh() async {
    if (limit < 30) {
      setState(() {
        limit = limit + 5;
        getLeaveList();
      });
    }
  }

  void _onReasonChanged() {
    getLeaveTypes(reasonController.text);
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _scrollController.addListener(_scrollListener);
    reasonController.addListener(_onReasonChanged);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Header(
      currentRoute: 'Leave',
      hasAppBar: true,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.indigo, Colors.cyan],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(4, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Column(
                        children: [
                          const Text(
                            "Apply Leave",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: DropdownMenu<String>(
                                  width: screenWidth / 2 - 20,
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                  inputDecorationTheme:
                                      const InputDecorationTheme(
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white70),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white70),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white70),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white70),
                                    ),
                                  ),
                                  controller: reasonController,
                                  initialSelection: leaveType,
                                  requestFocusOnTap: true,
                                  dropdownMenuEntries: leaveTypesList
                                          ?.map(
                                              (e) => DropdownMenuEntry<String>(
                                                    value: e.name,
                                                    label: e.name,
                                                  ))
                                          .toList() ??
                                      [],
                                  onSelected: (String? newValue) {
                                    setState(() {
                                      leaveType = newValue;
                                      reasonController.text = newValue ?? "";
                                    });
                                  },
                                ),
                              ),
                              // Switch
                              Row(
                                children: [
                                  const Text('is Half Day',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Switch(
                                    inactiveTrackColor: Colors.white70,
                                    activeColor: Colors.indigoAccent,
                                    activeTrackColor: Colors.white70,
                                    value: isHalfDay,
                                    onChanged: (bool newValue) {
                                      setState(() {
                                        isHalfDay = newValue;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (isHalfDay)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.white70)),
                                  onPressed: () async {
                                    DateTime? selectedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        startDate = selectedDate;
                                      });
                                    }
                                  },
                                  child: Text(
                                    startDate == null
                                        ? 'Select Date'
                                        : startDate!.toString().split(' ')[0],
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.indigo),
                                  ),
                                ),
                                Center(
                                  child: ElevatedButton.icon(
                                    style: const ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.indigo)),
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed:
                                        _isFormValid() ? createLeave : null,
                                    label: const Text('Apply',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white)),
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.white70)),
                                  onPressed: () async {
                                    DateTime? selectedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        startDate = selectedDate;
                                      });
                                    }
                                  },
                                  child: Text(
                                      startDate == null
                                          ? 'Select Start Date'
                                          : startDate!.toString().split(' ')[0],
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.indigo)),
                                ),
                                ElevatedButton(
                                  style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.white70)),
                                  onPressed: () async {
                                    DateTime? selectedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        endDate = selectedDate;
                                      });
                                    }
                                  },
                                  child: Text(
                                      endDate == null
                                          ? 'Select End Date'
                                          : endDate!.toString().split(' ')[0],
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.indigo)),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(
                            height: 10,
                          ),
                          if (!isHalfDay)
                            Center(
                              child: ElevatedButton.icon(
                                style: const ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(Colors.indigo)),
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _isFormValid() ? createLeave : null,
                                label: const Text('Apply',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                controller: _scrollController,
                itemCount: isPullLoading
                    ? (leaveList?.length ?? 0) + 1
                    : (leaveList?.length ?? 0),
                itemBuilder: (context, index) {
                  if (leaveList == null || leaveList!.isEmpty) {
                    return const Center(
                        child: Text(
                      'No Leave data available.',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ));
                  }

                  if (index < leaveList!.length) {
                    final leaves = leaveList![index];
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.circle,
                          color: Colors.indigoAccent,
                          size: 30,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        title: Text(
                          leaves.leaveType,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigoAccent,
                          ),
                        ),
                        subtitle: Text(
                          '${leaves.startDate.toString().split(' ')[0]} - ${leaves.endDate.toString().split(' ')[0]}',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        trailing: Text(
                          leaves.status,
                          style: TextStyle(
                            color: leaves.status == "Approved"
                                ? Colors.green
                                : leaves.status == "Pending"
                                    ? Colors.amber
                                    : Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
            )
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
