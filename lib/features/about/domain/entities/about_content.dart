import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum GoalIcon { quality, trust, speed, care, nature, support }

extension GoalIconX on GoalIcon {
  IconData get data => switch (this) {
    GoalIcon.quality => Icons.verified_outlined,
    GoalIcon.trust => Icons.shield_outlined,
    GoalIcon.speed => Icons.bolt_outlined,
    GoalIcon.care => Icons.favorite_outline,
    GoalIcon.nature => Icons.eco_outlined,
    GoalIcon.support => Icons.support_agent_outlined,
  };
}

class AboutGoal extends Equatable {
  final String id;
  final String title;
  final String description;
  final GoalIcon icon;

  const AboutGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  AboutGoal copyWith({String? title, String? description, GoalIcon? icon}) {
    return AboutGoal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [id, title, description, icon];
}

class AboutContent extends Equatable {
  final String heroTitle;
  final String heroSubtitle;
  final String mission;
  final List<AboutGoal> goals;
  final String source;
  final String contactText;

  const AboutContent({
    this.heroTitle = '',
    this.heroSubtitle = '',
    this.mission = '',
    this.goals = const [],
    this.source = '',
    this.contactText = '',
  });

  AboutContent copyWith({
    String? heroTitle,
    String? heroSubtitle,
    String? mission,
    List<AboutGoal>? goals,
    String? source,
    String? contactText,
  }) {
    return AboutContent(
      heroTitle: heroTitle ?? this.heroTitle,
      heroSubtitle: heroSubtitle ?? this.heroSubtitle,
      mission: mission ?? this.mission,
      goals: goals ?? this.goals,
      source: source ?? this.source,
      contactText: contactText ?? this.contactText,
    );
  }

  @override
  List<Object?> get props => [heroTitle, heroSubtitle, mission, goals, source, contactText];
}