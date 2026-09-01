import 'package:equatable/equatable.dart';

enum SuggestionStatus { underReview, approved, rejected }

class ProductSuggestion extends Equatable {
  final String id;
  final String suggestedBy;
  final String productName;
  final String link;
  final SuggestionStatus status;
  final DateTime createdAt;

  const ProductSuggestion({
    required this.id,
    required this.suggestedBy,
    required this.productName,
    required this.link,
    required this.status,
    required this.createdAt,
  });

  ProductSuggestion copyWith({SuggestionStatus? status}) {
    return ProductSuggestion(
      id: id,
      suggestedBy: suggestedBy,
      productName: productName,
      link: link,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, suggestedBy, productName, link, status, createdAt];
}