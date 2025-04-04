import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../../models/idea_model.dart';

Widget ideaCardContent(Idea idea, BuildContext context, String bookTitle) {
  final truncatedBookTitle = _truncateBookTitle(bookTitle, S.of(context).general, maxLength: 28);

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 4,
    color: Color.lerp(idea.status.color, Colors.white, 0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: idea.status.color,
        width: 2,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  idea.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: idea.status.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  idea.status.title(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            idea.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                S.of(context).relatedTo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Flexible(
                child: Text(
                  truncatedBookTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

String _truncateBookTitle(String title, String generalLabel, {required int maxLength}) {
  if (title == generalLabel || title.length <= maxLength) return title;
  return '${title.substring(0, maxLength)}...';
}