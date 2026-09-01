import 'package:equatable/equatable.dart';

class LoyaltyRules extends Equatable {
  final bool purchaseRuleEnabled;
  final bool purchaseIsPercentage;
  final double purchaseValue;

  final bool appRatingRuleEnabled;
  final int appRatingPoints;

  final bool suggestionRuleEnabled;
  final int suggestionPoints;

  final bool expiryEnabled;
  final int expiryMonths;

  final int minRedemption;

  const LoyaltyRules({
    this.purchaseRuleEnabled = true,
    this.purchaseIsPercentage = false,
    this.purchaseValue = 1,
    this.appRatingRuleEnabled = true,
    this.appRatingPoints = 50,
    this.suggestionRuleEnabled = true,
    this.suggestionPoints = 30,
    this.expiryEnabled = false,
    this.expiryMonths = 12,
    this.minRedemption = 100,
  });

  LoyaltyRules copyWith({
    bool? purchaseRuleEnabled,
    bool? purchaseIsPercentage,
    double? purchaseValue,
    bool? appRatingRuleEnabled,
    int? appRatingPoints,
    bool? suggestionRuleEnabled,
    int? suggestionPoints,
    bool? expiryEnabled,
    int? expiryMonths,
    int? minRedemption,
  }) {
    return LoyaltyRules(
      purchaseRuleEnabled: purchaseRuleEnabled ?? this.purchaseRuleEnabled,
      purchaseIsPercentage: purchaseIsPercentage ?? this.purchaseIsPercentage,
      purchaseValue: purchaseValue ?? this.purchaseValue,
      appRatingRuleEnabled: appRatingRuleEnabled ?? this.appRatingRuleEnabled,
      appRatingPoints: appRatingPoints ?? this.appRatingPoints,
      suggestionRuleEnabled: suggestionRuleEnabled ?? this.suggestionRuleEnabled,
      suggestionPoints: suggestionPoints ?? this.suggestionPoints,
      expiryEnabled: expiryEnabled ?? this.expiryEnabled,
      expiryMonths: expiryMonths ?? this.expiryMonths,
      minRedemption: minRedemption ?? this.minRedemption,
    );
  }

  @override
  List<Object?> get props => [
    purchaseRuleEnabled,
    purchaseIsPercentage,
    purchaseValue,
    appRatingRuleEnabled,
    appRatingPoints,
    suggestionRuleEnabled,
    suggestionPoints,
    expiryEnabled,
    expiryMonths,
    minRedemption,
  ];
}