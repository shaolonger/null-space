import 'package:flutter/material.dart';
import '../models/vault.dart';
import '../utils/date_formatter.dart';

/// Reusable vault card widget for displaying vaults in list view
class VaultCard extends StatelessWidget {
  final Vault vault;
  final bool isLocked;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onExport;
  final VoidCallback? onRename;
  final bool isSelected;
  final int? noteCount;

  const VaultCard({
    super.key,
    required this.vault,
    required this.isLocked,
    required this.onTap,
    required this.onDelete,
    required this.onExport,
    this.onRename,
    this.isSelected = false,
    this.noteCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: isSelected ? 4 : 1,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          borderRadius: BorderRadius.circular(12),
          hoverColor: colorScheme.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with lock icon and menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lock/Unlock icon
                    Icon(
                      isLocked ? Icons.lock : Icons.lock_open,
                      size: 20,
                      color: isLocked
                          ? colorScheme.error
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    // Vault name
                    Expanded(
                      child: Text(
                        vault.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Context menu button
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      tooltip: 'Vault actions',
                      padding: EdgeInsets.zero,
                      onSelected: (value) => _handleMenuAction(context, value),
                      itemBuilder: (context) => _buildMenuItems(colorScheme),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description preview
                if (vault.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      vault.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                // Metadata row (note count and last accessed date)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Note count badge
                    if (noteCount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.note,
                              size: 14,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              noteCount.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // Last accessed date
                    Text(
                      'Updated ${_formatDate(vault.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(ColorScheme colorScheme) {
    return [
      const PopupMenuItem(
        value: 'export',
        child: Row(
          children: [
            Icon(Icons.download, size: 18),
            SizedBox(width: 8),
            Text('Export'),
          ],
        ),
      ),
      if (onRename != null)
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Rename'),
            ],
          ),
        ),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
            const SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: colorScheme.error)),
          ],
        ),
      ),
    ];
  }

  void _showContextMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showMenu(
      context: context,
      position: RelativeRect.fill,
      items: _buildMenuItems(colorScheme),
    ).then((value) {
      if (value != null) {
        _handleMenuAction(context, value);
      }
    });
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'export':
        onExport();
        break;
      case 'rename':
        if (onRename != null) {
          onRename!();
        }
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  void _confirmDelete(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vault'),
        content: Text(
          'Are you sure you want to delete "${vault.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormatter.formatRelativeDate(date);
  }
}
