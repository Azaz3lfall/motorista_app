import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerDialog extends StatelessWidget {
  final Function(File?) onImagePicked;

  const ImagePickerDialog({
    super.key,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escolher Imagem'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Câmera'),
            onTap: () async {
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                onImagePicked(File(pickedFile.path));
              }
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galeria'),
            onTap: () async {
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                onImagePicked(File(pickedFile.path));
              }
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  static Future<void> show(BuildContext context, Function(File?) onImagePicked) {
    return showDialog<void>(
      context: context,
      builder: (context) => ImagePickerDialog(onImagePicked: onImagePicked),
    );
  }
}
