import 'package:flutter/material.dart';

import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../domain/entities/support_message.dart';

extension SupportTopicX on SupportTopic {
  String get label => switch (this) {
    SupportTopic.complaint => AdminStrings.topicComplaint,
    SupportTopic.suggestion => AdminStrings.topicSuggestion,
    SupportTopic.bug => AdminStrings.topicBug,
    SupportTopic.other => AdminStrings.topicOther,
  };
}

extension SupportStatusX on SupportStatus {
  String get label => switch (this) {
    SupportStatus.open => AdminStrings.open,
    SupportStatus.resolved => AdminStrings.resolved,
  };

  Color get color => switch (this) {
    SupportStatus.open => AdminColors.gold,
    SupportStatus.resolved => AdminColors.primary,
  };
}