import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../constants/admin_strings.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';
import '../media/media_image.dart';
import '../media/media_thumb.dart';

/// Stored and newly picked images together. The first is the main one;
/// tapping another makes it first. Uploading happens on save.
class AdminImagePicker extends StatelessWidget {
  final List<MediaImage> images;
  final ValueChanged<List<MediaImage>> onChanged;

  const AdminImagePicker({super.key, required this.images, required this.onChanged});

  Future<void> _pickImages() async {
    const typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    final files = await openFiles(acceptedTypeGroups: [typeGroup]);
    if (files.isEmpty) return;
    final bytesList = await Future.wait(files.map((f) => f.readAsBytes()));
    onChanged([...images, for (final b in bytesList) PickedImage(b)]);
  }

  void _makeMain(int index) => onChanged([images[index], ...images.whereIndexed((i, _) => i != index)]);

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
          _Thumb(image: images[i], isMain: i == 0, onTap: () => _makeMain(i), onRemove: () => _remove(i)),
        _AddTile(onTap: _pickImages),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final MediaImage image;
  final bool isMain;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _Thumb({required this.image, required this.isMain, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(onTap: onTap, child: MediaThumb(image: image, width: 84)),
        if (isMain)
          const Positioned(bottom: 2, left: 2, child: Icon(Icons.star_rounded, size: 18, color: AdminColors.gold)),
        Positioned(
          top: 2,
          right: 2,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: AdminColors.danger, shape: BoxShape.circle),
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