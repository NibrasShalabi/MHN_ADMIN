import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../constants/admin_strings.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

class AdminImagePicker extends StatelessWidget {
  final List<Uint8List> images;
  final ValueChanged<List<Uint8List>> onChanged;

  const AdminImagePicker({super.key, required this.images, required this.onChanged});

  Future<void> _pickImages() async {
    const typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    final files = await openFiles(acceptedTypeGroups: [typeGroup]);
    if (files.isEmpty) return;
    final bytesList = await Future.wait(files.map((f) => f.readAsBytes()));
    onChanged([...images, ...bytesList]);
  }

  void _remove(int index) {
    final next = [...images]..removeAt(index);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AdminConstants.spacingSm,
      runSpacing: AdminConstants.spacingSm,
      children: [
        for (var i = 0; i < images.length; i++)
          _Thumb(bytes: images[i], onRemove: () => _remove(i)),
        _AddTile(onTap: _pickImages),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final Uint8List bytes;
  final VoidCallback onRemove;

  const _Thumb({required this.bytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
          child: Image.memory(bytes, width: 84, height: 84, fit: BoxFit.cover),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AdminColors.danger,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: AdminColors.canvas,
          borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
          border: Border.all(color: AdminColors.border, width: AdminConstants.borderThin),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, color: AdminColors.gold, size: 22),
            const SizedBox(height: 4),
            Text(AdminStrings.addImages, style: AdminTextStyles.caption),
          ],
        ),
      ),
    );
  }
}