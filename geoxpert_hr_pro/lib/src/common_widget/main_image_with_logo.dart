import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../constants/api_url.dart';
import '../constants/colors.dart';
import '../model/PublicSetting.dart';

class MainImageWithLogo extends StatefulWidget {
  final Widget child;

  const MainImageWithLogo({super.key, required this.child});

  @override
  State<MainImageWithLogo> createState() => _MainImageWithLogoState();
}

class _MainImageWithLogoState extends State<MainImageWithLogo> {
  PublicSetting? _settings;

  Future<void> _fetchPublicSettings() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiUrl.baseUrl}settings/public'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _settings = PublicSetting.fromJson(data);
        });
      } else {
        print("Failed to fetch public settings: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching public settings: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPublicSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      return const Scaffold(
        backgroundColor: SLATE,
        body: Center(
          child: CircularProgressIndicator(color: WHITE),
        ),
      );
    }

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SLATE, SKY],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: (_settings?.logo.isNotEmpty ?? false)
                    ? Image.network(
                        _settings!.logo,
                        width: 300,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : Text(
                        _settings!.siteName,
                        style: const TextStyle(
                          color: WHITE,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: widget.child),
              ),
            )
          ],
        ),
      ),
    );
  }
}
