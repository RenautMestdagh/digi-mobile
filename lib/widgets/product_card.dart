import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/products.dart';
import '../l10n/app_localizations.dart';
import 'feedback.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onRetry});

  final Product product;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final error = product.error;

    return Card.filled(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: const Icon(Icons.sim_card_outlined),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text(product.number, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (error != null)
              Problem(icon: Icons.error_outline, message: describe(context, error), onRetry: onRetry)
            else ...[
              for (final usage in product.usage)
                if (usage.share case final share?) _DataUsage(usage: usage, share: share),
              for (final usage in product.usage)
                if (usage.share == null) _Usage(usage: usage),
              if (product.notes.isNotEmpty) ...[
                const Divider(height: 24),
                for (final note in product.notes)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(note, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DataUsage extends StatelessWidget {
  const _DataUsage({required this.usage, required this.share});

  final Usage usage;
  final double share;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant);
    final percent = NumberFormat.percentPattern(Localizations.localeOf(context).toString()).format(share);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(usage.type, style: muted),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            children: [
              Text(usage.used, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(usage.limit, style: muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: share.clamp(0, 1),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
            color: share >= 0.9 ? colors.error : null,
            semanticsLabel: usage.type,
          ),
          const SizedBox(height: 8),
          Text(S.of(context).used(percent), style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Usage extends StatelessWidget {
  const _Usage({required this.usage});

  final Usage usage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(usage.type, style: theme.textTheme.bodyLarge),
                Text(
                  usage.limit,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(usage.used, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
