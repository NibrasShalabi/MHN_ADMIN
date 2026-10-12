import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/error/admin_error.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/widgets/admin_confirm_dialog.dart';
import '../../data/repository/reviews_repository.dart';
import '../../domain/entities/app_review.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late Future<List<AppReview>> _future;
  late Future<List<AppReview>> _published;
  final _repo = GetIt.instance<ReviewsRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _repo.getPendingReviews();
      _published = _repo.getPublishedReviews();
    });
  }
  Future<void> _delete(AppReview review) async {
    final ok = await showAdminConfirm(context, title: AdminStrings.delete, message: AdminStrings.reviewDeleteConfirm);
    if (!ok) return;
    try {
      await _repo.deletePublished(review.uid);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AdminStrings.deleted)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AdminError.message(e))));
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AdminStrings.reviewsPending, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        FutureBuilder<List<AppReview>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final reviews = snapshot.data!;
            if (reviews.isEmpty) return Text('لا توجد تقييمات معلقة', style: AdminTextStyles.caption);
            // The section shell already scrolls — a nested ListView has no height.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, review) in reviews.indexed) ...[
                  if (i > 0) const SizedBox(height: AdminConstants.spacingMd),
                  _ReviewTile(review: review, repo: _repo, onDone: _load),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: AdminConstants.spacingXl),
        Text(AdminStrings.reviewsPublished, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        FutureBuilder<List<AppReview>>(
          future: _published,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(AdminError.message(snapshot.error!), style: AdminTextStyles.caption);
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final reviews = snapshot.data!;
            if (reviews.isEmpty) return Text(AdminStrings.noData, style: AdminTextStyles.caption);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final r in reviews)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AdminConstants.spacingSm),
                    child: AdminCard(
                      title: '${'⭐' * r.stars}  ${r.authorName ?? ''}',
                      actions: [
                        IconButton(
                          tooltip: AdminStrings.delete,
                          icon: const Icon(Icons.delete_outline, color: AdminColors.danger, size: 20),
                          onPressed: () => _delete(r),
                        ),
                      ],
                      child: Text(
                        r.comment?.isNotEmpty == true ? r.comment! : '—',
                        style: AdminTextStyles.body,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
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