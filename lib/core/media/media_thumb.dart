import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_colors.dart';
import 'media_config.dart';
import 'media_image.dart';

/// A small rounded preview of a stored or picked image — lists and pickers.
class MediaThumb extends StatelessWidget {
  final MediaImage? image;
  final double width;
  final double height;
  final IconData placeholder;

  const MediaThumb({
    super.key,
    required this.image,
    required this.width,
    double? height,
    this.placeholder = Icons.image_outlined,
  }) : height = height ?? width;

  @override
  Widget build(BuildContext context) {
    final empty = Container(
      width: width,
      height: height,
      color: AdminColors.surfaceRaised,
      child: Icon(placeholder, size: height / 2, color: AdminColors.textDisabled),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
      child: switch (image) {
        null => empty,
        PickedImage(:final bytes) => Image.memory(bytes, width: width, height: height, fit: BoxFit.cover),
        StoredImage(:final path) => Image.network(
            MediaConfig.url(path),
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => empty,
          ),
      },
    );
  }
}
