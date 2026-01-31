import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/note_service.dart';
import '../services/file_storage.dart';
import '../bridge/rust_bridge.dart';
import '../widgets/tag_input_widget.dart';

/// Note Editor Screen for creating and editing notes
/// 
/// This screen provides a full-featured editor with:
/// - Title and content fields with validation
/// - Tag management with autocomplete
/// - Markdown preview toggle
/// - Save/Cancel/Delete actions
/// - Unsaved changes detection
class NoteEditorScreen extends StatefulWidget {
  /// The note to edit (null for new notes)
  final Note? note;
  
  /// Path to the vault containing the note
  final String vaultPath;
  
  /// Vault password for encryption
  final String vaultPassword;
  
  /// Vault salt for key derivation
  final String vaultSalt;

  const NoteEditorScreen({
    super.key,
    this.note,
    required this.vaultPath,
    required this.vaultPassword,
    required this.vaultSalt,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  final List<String> _tags = [];
  bool _isPreviewMode = false;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  bool _isInitializing = true;
  bool _initializationFailed = false;
  
  NoteService? _noteService;

  @override
  void initState() {
    super.initState();
    _initializeService();
    
    // Load existing note data if editing
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _tags.addAll(widget.note!.tags);
    }
    
    // Listen for changes to track unsaved changes
    _titleController.addListener(_onFieldChanged);
    _contentController.addListener(_onFieldChanged);
  }

  /// Initialize the note service asynchronously
  Future<void> _initializeService() async {
    try {
      final bridge = RustBridge();
      bridge.init();
      final storage = await FileStorage.create();
      _noteService = NoteService(
        bridge: bridge,
        storage: storage,
      );
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _initializationFailed = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize note editor. Please try reopening: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _contentController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  /// Handle tags changed from TagInputWidget
  void _handleTagsChanged(List<String> newTags) {
    setState(() {
      _tags.clear();
      _tags.addAll(newTags);
      _hasUnsavedChanges = true;
    });
  }

  /// Toggle between edit and preview mode
  void _togglePreview() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }

  /// Save the note
  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_noteService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note editor is not initialized. Please reopen the editor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final noteProvider = context.read<NoteProvider>();
      
      if (widget.note == null) {
        // Create new note
        final newNote = await _noteService!.createNote(
          title: _titleController.text,
          content: _contentController.text,
          tags: _tags,
          vaultPath: widget.vaultPath,
          vaultPassword: widget.vaultPassword,
          vaultSalt: widget.vaultSalt,
        );
        if (mounted) {
          noteProvider.addNote(newNote);
        }
      } else {
        // Update existing note - create a copy with updated fields
        final updatedNote = Note(
          id: widget.note!.id,
          title: _titleController.text,
          content: _contentController.text,
          tags: List.from(_tags),
          createdAt: widget.note!.createdAt,
          updatedAt: widget.note!.updatedAt,
          version: widget.note!.version,
        );
        
        final savedNote = await _noteService!.updateNote(
          note: updatedNote,
          vaultPath: widget.vaultPath,
          vaultPassword: widget.vaultPassword,
          vaultSalt: widget.vaultSalt,
        );
        if (mounted) {
          noteProvider.updateNote(savedNote);
        }
      }

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Delete the note
  Future<void> _deleteNote() async {
    if (widget.note == null) return;

    if (_noteService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note editor is not initialized. Please reopen the editor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.deleteNoteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final noteProvider = context.read<NoteProvider>();
      
      await _noteService!.deleteNote(
        noteId: widget.note!.id,
        vaultPath: widget.vaultPath,
      );

      if (mounted) {
        noteProvider.deleteNote(widget.note!.id);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Handle cancel button press with unsaved changes check
  Future<void> _handleCancel() async {
    if (!_hasUnsavedChanges) {
      Navigator.of(context).pop();
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChanges),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );

    if (shouldPop == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Show error state if initialization failed
    if (_initializationFailed) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Note Editor'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize note editor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please try reopening the editor'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // Show unsaved changes dialog
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.unsavedChanges),
            content: Text(l10n.unsavedChangesMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.discard),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? l10n.newNote : l10n.editNote),
          actions: [
            // Preview toggle button
            IconButton(
              icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
              tooltip: _isPreviewMode ? l10n.editMode : l10n.previewMode,
              onPressed: _isSaving || _isInitializing ? null : _togglePreview,
            ),
            // Delete button (only for existing notes)
            if (widget.note != null)
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: l10n.delete,
                onPressed: _isSaving || _isInitializing ? null : _deleteNote,
              ),
          ],
        ),
        body: _isInitializing || _isSaving
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title field
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: l10n.title,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.titleRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Content field or preview
                            if (_isPreviewMode)
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                constraints: const BoxConstraints(minHeight: 200),
                                child: _contentController.text.isEmpty
                                    ? const Text(
                                        'No content to preview',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                    : Markdown(
                                        data: _contentController.text,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                      ),
                              )
                            else
                              TextFormField(
                                controller: _contentController,
                                decoration: InputDecoration(
                                  labelText: l10n.content,
                                  hintText: l10n.writeNoteHint,
                                  border: const OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 15,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.contentRequired;
                                  }
                                  return null;
                                },
                              ),
                            const SizedBox(height: 16),
                            
                            // Tags section
                            Text(
                              l10n.tags,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Tag input widget with autocomplete
                            Consumer<NoteProvider>(
                              builder: (context, noteProvider, _) {
                                return TagInputWidget(
                                  availableTags: noteProvider.allTags,
                                  selectedTags: _tags,
                                  onTagsChanged: _handleTagsChanged,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom action buttons
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving || _isInitializing
                                  ? null
                                  : _handleCancel,
                              child: Text(l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isSaving || _isInitializing ? null : _saveNote,
                              child: Text(l10n.save),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
