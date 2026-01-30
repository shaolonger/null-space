import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/vault_provider.dart';
import 'providers/note_provider.dart';
import 'models/note.dart';

void main() {
  runApp(const NullSpaceApp());
}

class NullSpaceApp extends StatelessWidget {
  const NullSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VaultProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = NoteProvider();
            // Add sample notes for development/testing
            _addSampleNotes(provider);
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Null Space',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }

  void _addSampleNotes(NoteProvider provider) {
    final now = DateTime.now();
    
    provider.addNote(Note(
      id: 'sample-1',
      title: 'Welcome to Null Space',
      content: 'This is a secure, local-first note-taking app with end-to-end encryption. Your notes are stored locally and never leave your device unless you explicitly export them.',
      tags: ['welcome', 'info'],
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      version: 1,
    ));

    provider.addNote(Note(
      id: 'sample-2',
      title: 'Meeting Notes - Q1 Planning',
      content: '''# Q1 Planning Meeting

**Date:** January 15, 2024
**Attendees:** Team leads

## Key Points
- Set quarterly goals
- Review budget allocation
- Plan team expansion
- Discuss new feature roadmap

## Action Items
1. Finalize hiring plan by end of month
2. Review and approve budget by Feb 1
3. Schedule follow-up meeting for mid-quarter check-in''',
      tags: ['work', 'meetings', 'planning', 'q1-2024'],
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(hours: 24)),
      version: 1,
    ));

    provider.addNote(Note(
      id: 'sample-3',
      title: 'Recipe: Chocolate Chip Cookies',
      content: '''## Ingredients
- 2 1/4 cups flour
- 1 tsp baking soda
- 1 cup butter, softened
- 3/4 cup sugar
- 2 eggs
- 2 cups chocolate chips

## Instructions
1. Preheat oven to 375°F
2. Mix dry ingredients
3. Cream butter and sugar
4. Add eggs and mix well
5. Combine wet and dry ingredients
6. Fold in chocolate chips
7. Bake for 9-11 minutes''',
      tags: ['recipes', 'desserts', 'baking'],
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now.subtract(const Duration(days: 7)),
      version: 1,
    ));

    provider.addNote(Note(
      id: 'sample-4',
      title: 'Book Ideas',
      content: '''Books I want to read:
- The Pragmatic Programmer
- Clean Code
- Design Patterns
- Refactoring

Books I've finished:
- The Phoenix Project ✓
- The DevOps Handbook ✓''',
      tags: ['reading', 'books', 'learning'],
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now.subtract(const Duration(hours: 5)),
      version: 1,
    ));

    provider.addNote(Note(
      id: 'sample-5',
      title: 'Quick Reminder',
      content: 'Don\'t forget to backup the database before deploying to production!',
      tags: ['reminders', 'urgent', 'devops'],
      createdAt: now.subtract(const Duration(hours: 6)),
      updatedAt: now.subtract(const Duration(minutes: 30)),
      version: 1,
    ));

    provider.addNote(Note(
      id: 'sample-6',
      title: '',
      content: 'This is a note without a title to test the "Untitled Note" display.',
      tags: ['test'],
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(hours: 12)),
      version: 1,
    ));
  }
}
