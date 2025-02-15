import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/common_widget/header.dart';
import 'package:geoxpert_hr_pro/src/model/Salary.dart';

import '../../model/User.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';

@RoutePage()
class LeaveScreen extends StatefulWidget {
  LeaveScreen({super.key});

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
  List<Salary>? salaryList;

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

  Future<void> getAttendance() async {
    try {
      setState(() {
        isPullLoading = true;
      });
      final response =
      await apiService.get('payrolls/${user?.id}?limit=${limit}');
      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        final List<dynamic> contentData = jsonData['content'];

        List<Salary> fetchedSalaryList =
        contentData.map((json) => Salary.fromJson(json)).toList();
        setState(() {
          salaryList = fetchedSalaryList;
        });
      } else {
        print(
            'Failed to fetch salary data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching salary data: $e');
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

  Future<void> onRefresh() async {
    if (limit < 30) {
      setState(() {
        limit = limit + 5;
        getAttendance();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Header(
      currentRoute: 'salary',
      hasAppBar: true,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(5),
                controller: _scrollController,
                itemCount: isPullLoading
                    ? (salaryList?.length ?? 0) + 1
                    : (salaryList?.length ?? 0),
                itemBuilder: (context, index) {
                  if (salaryList == null || salaryList!.isEmpty) {
                    return const Center(child: Text('No Salary data available.'));
                  }

                  if (index < salaryList!.length) {
                    final salary = salaryList![index];
                    return Card(
                      color: Colors.blue,
                      child: ListTile(
                        leading: const Icon(Icons.circle),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        title: Text(salary.period),
                        subtitle: Text(salary.netSalary.toString()),
                        trailing: Text(salary.status),
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
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
