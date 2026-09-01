import 'package:flutter/material.dart';

import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../domain/entities/product_suggestion.dart';

extension SuggestionStatusX on SuggestionStatus {
  String get label => switch (this) {
    SuggestionStatus.underReview => AdminStrings.statusUnderReview,
    SuggestionStatus.approved => AdminStrings.statusApproved,
    SuggestionStatus.rejected => AdminStrings.statusRejected,
  };

  Color get color => switch (this) {
    SuggestionStatus.underReview => AdminColors.gold,
    SuggestionStatus.approved => AdminColors.primary,
    SuggestionStatus.rejected => AdminColors.danger,
  };
}