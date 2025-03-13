import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/common_widget/header.dart';
import 'package:geoxpert_hr_pro/src/model/Salary.dart';

import '../../model/User.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';

@RoutePage()
class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
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
      getSalary();
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getSalary() async {
    try {
      setState(() {
        isPullLoading = true;
      });
      final response =
          await apiService.get('payrolls/${user?.id}?limit=$limit');
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
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      onRefresh();
    }
  }

  Future<void> onRefresh() async {
    if (limit < 30) {
      setState(() {
        limit = limit + 5;
        getSalary();
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
                padding: const EdgeInsets.all(15),
                controller: _scrollController,
                itemCount: isPullLoading
                    ? (salaryList?.length ?? 0) + 1
                    : (salaryList?.length ?? 0),
                itemBuilder: (context, index) {
                  if (salaryList == null || salaryList!.isEmpty) {
                    return const Center(
                        child: Text(
                      'No Salary data available.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ));
                  }

                  if (index < salaryList!.length) {
                    final salary = salaryList![index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 5,
                      // Adding elevation for card shadow
                      color: Colors.blue.shade50,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        leading: Icon(
                          Icons.attach_money,
                          color: Colors.blue.shade800,
                          size: 30,
                        ),
                        title: Text(
                          salary.period,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        subtitle: Text(
                          '\$${salary.netSalary.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        trailing: Text(
                          salary.status,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: salary.status == 'Paid'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: Colors.blue,
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
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
