import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/common_widget/header.dart';

@RoutePage()
class HelpScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Header(
      currentRoute: "Help",
      hasAppBar: true,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "We're here to help you! Please fill out the form below and our support team will get back to you.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Name',
                icon: Icons.person,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: 'Subject',
                icon: Icons.help_outline,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: 'Message',
                icon: Icons.message,
                maxLines: 5,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle form submission
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Submitting help request...')),
                    );
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
