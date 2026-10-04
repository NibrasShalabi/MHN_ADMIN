import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repository/reviews_repository.dart';
import '../../domain/entities/app_review.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late Future<List<AppReview>> _future;
  final _repo = GetIt.instance<ReviewsRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _repo.getPendingReviews();
    });
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppReview>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data!;
        if (reviews.isEmpty) {
          return Center(
            child: Text('لا توجد تقييمات معلقة', style: AdminTextStyles.caption),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AdminConstants.spacingLg),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const SizedBox(height: AdminConstants.spacingMd),
          itemBuilder: (context, index) => _ReviewTile(
            review: reviews[index],
            repo: _repo,
            onDone: _load,
          ),
        );
      },
    );
  }
}

class _ReviewTile extends StatefulWidget {
  final AppReview review;
  final ReviewsRepository repo;
  final VoidCallback onDone;

  const _ReviewTile({required this.review, required this.repo, required this.onDone});

  @override
  State<_ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<_ReviewTile> {
  final _nameController = TextEditingController(text: 'مستخدم');
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    setState(() => _loading = true);
    await widget.repo.approve(widget.review.uid, authorName: _nameController.text.trim());
    widget.onDone();
  }

  Future<void> _reject() async {
    setState(() => _loading = true);
    await widget.repo.reject(widget.review.uid);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final review = widget.review;

    return AdminCard(
      title: '${review.stars} ⭐ — ${dateFormat.format(review.createdAt)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (review.comment != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AdminConstants.spacingMd),
              child: Text(review.comment!, style: AdminTextStyles.body),
            ),
          AdminTextInput(
            controller: _nameController,
            hint: 'اسم المستخدم للعرض',
          ),
          const SizedBox(height: AdminConstants.spacingMd),
          Row(
            children: [
              Expanded(
                child: AdminButton(
                  label: 'موافقة',
                  onPressed: _loading ? null : _approve,
                ),
              ),
              const SizedBox(width: AdminConstants.spacingSm),
              Expanded(
                child: AdminButton(
                  label: 'رفض',
                  kind: AdminButtonKind.danger,
                  onPressed: _loading ? null : _reject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}