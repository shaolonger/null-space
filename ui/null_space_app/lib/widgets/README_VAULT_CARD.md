# VaultCard Widget

A reusable widget for displaying vault information in the Null Space app.

## Usage

```dart
import 'package:null_space_app/widgets/vault_card.dart';
import 'package:null_space_app/models/vault.dart';

// Example: Display a vault card
VaultCard(
  vault: myVault,
  isLocked: true,
  onTap: () {
    // Handle vault tap - typically opens unlock dialog
    print('Vault tapped: ${myVault.name}');
  },
  onDelete: () {
    // Handle vault deletion
    print('Delete vault: ${myVault.name}');
  },
  onExport: () {
    // Handle vault export
    print('Export vault: ${myVault.name}');
  },
  onRename: () {
    // Optional: Handle vault rename
    print('Rename vault: ${myVault.name}');
  },
  isSelected: false,
  noteCount: 42, // Optional: Show badge with note count
)
```

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `vault` | `Vault` | Yes | The vault model to display |
| `isLocked` | `bool` | Yes | Whether the vault is currently locked |
| `onTap` | `VoidCallback` | Yes | Called when the card is tapped |
| `onDelete` | `VoidCallback` | Yes | Called when delete action is selected |
| `onExport` | `VoidCallback` | Yes | Called when export action is selected |
| `onRename` | `VoidCallback?` | No | Called when rename action is selected. If null, rename option is hidden |
| `isSelected` | `bool` | No | Whether the card is currently selected (default: false) |
| `noteCount` | `int?` | No | Number of notes in vault. If provided, displays a badge |

## Features

### Visual Elements
- **Lock Status Icon**: Shows locked (red) or unlocked (primary color) state
- **Vault Name**: Bold text, max 2 lines with ellipsis overflow
- **Description**: Light text, max 2 lines with ellipsis overflow
- **Note Count Badge**: Optional badge showing number of notes
- **Last Updated**: Relative time format ("2h ago", "yesterday", etc.)

### Interactions
- **Tap**: Executes the `onTap` callback
- **Long Press**: Shows context menu
- **Three-dot Menu**: Shows Export, Rename (if callback provided), and Delete options
- **Hover**: Subtle color change with pointer cursor

### Context Menu Actions
1. **Export**: Executes the `onExport` callback
2. **Rename**: Executes the `onRename` callback (only shown if callback provided)
3. **Delete**: Shows confirmation dialog, then executes `onDelete` callback

## Theme Support

The widget fully supports Material Design 3 themes and automatically adapts to:
- Light and dark modes
- Custom color schemes
- Text scaling preferences

Colors are derived from the theme's `ColorScheme`:
- Lock icon (locked): `colorScheme.error`
- Lock icon (unlocked): `colorScheme.primary`
- Delete text/icon: `colorScheme.error`
- Note count badge: `colorScheme.primaryContainer` / `onPrimaryContainer`

## Example: List of Vaults

```dart
ListView.builder(
  itemCount: vaults.length,
  itemBuilder: (context, index) {
    final vault = vaults[index];
    return VaultCard(
      vault: vault,
      isLocked: !unlockedVaultIds.contains(vault.id),
      onTap: () => _handleVaultTap(vault),
      onDelete: () => _handleVaultDelete(vault),
      onExport: () => _handleVaultExport(vault),
      onRename: () => _handleVaultRename(vault),
      noteCount: noteCountMap[vault.id],
      isSelected: selectedVaultId == vault.id,
    );
  },
)
```

## Related Widgets

- `NoteCard` - Similar widget for displaying notes
- `VaultCreationDialog` - Dialog for creating new vaults
- `VaultUnlockDialog` - Dialog for unlocking vaults

## Date Formatting

The widget uses the shared `DateFormatter.formatRelativeDate()` utility for consistent date display across the app:
- "just now" - Less than 1 minute ago
- "5m ago" - Minutes ago
- "2h ago" - Hours ago
- "yesterday" - 1 day ago
- "3d ago" - Days ago (up to 7 days)
- "Jan 15, 2024" - More than 7 days ago
