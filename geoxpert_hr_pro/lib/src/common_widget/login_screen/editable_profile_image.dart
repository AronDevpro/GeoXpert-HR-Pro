import 'package:flutter/material.dart';
import 'dart:io';

class EditableProfileImage extends StatelessWidget {
  final String? photoUrl;
  final File? localImage;
  final VoidCallback onEdit;

  const EditableProfileImage({
    super.key,
    required this.photoUrl,
    required this.localImage,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipOval(
          child: (localImage != null
              ? Image.file(
                  localImage!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
              : (photoUrl != null && photoUrl!.isNotEmpty
                  ? Image.network(
                      photoUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ))),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
