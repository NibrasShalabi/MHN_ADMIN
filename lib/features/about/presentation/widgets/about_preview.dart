import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../domain/entities/about_content.dart';

class AboutPreview extends StatelessWidget {
  final AboutContent content;

  const AboutPreview({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: AdminStrings.livePreview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content.heroTitle.isEmpty ? '—' : content.heroTitle, style: AdminTextStyles.pageTitle),
          const SizedBox(height: AdminConstants.spacingXs),
          Text(content.heroSubtitle, style: AdminTextStyles.caption),
          const SizedBox(height: AdminConstants.spacingLg),
          if (content.mission.isNotEmpty) ...[
            Text(content.mission, style: AdminTextStyles.body),
            const SizedBox(height: AdminConstants.spacingLg),
          ],
          if (content.goals.isNotEmpty) ...[
            Wrap(
              spacing: AdminConstants.spacingMd,
              runSpacing: AdminConstants.spacingMd,
              children: content.goals
                  .map((g) => SizedBox(
                width: 140,
                child: Column(
                  children: [
                    Icon(g.icon.data, color: AdminColors.gold, size: 28),
                    const SizedBox(height: AdminConstants.spacingXs),
                    Text(g.title, style: AdminTextStyles.label, textAlign: TextAlign.center),
                    Text(g.description, style: AdminTextStyles.caption, textAlign: TextAlign.center),
                  ],
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
          ],
          if (content.source.isNotEmpty) ...[
            Text(AdminStrings.aboutSource, style: AdminTextStyles.tableHeader),
            const SizedBox(height: AdminConstants.spacingXs),
            Text(content.source, style: AdminTextStyles.body),
            const SizedBox(height: AdminConstants.spacingLg),
          ],
          if (content.contactText.isNotEmpty) Text(content.contactText, style: AdminTextStyles.caption),
        ],
      ),
    );
  }
}