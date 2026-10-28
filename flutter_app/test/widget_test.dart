import 'package:flutter_test/flutter_test.dart';
import 'package:notes_by_lavi/main.dart';

void main() {
  group('Note persistence model', () {
    test('serializes and restores note content and flags', () {
      final note = Note(
        id: 'note-1',
        title: 'Weekend idea',
        body: 'Write it down',
        tags: 'personal, ideas',
        pinned: true,
        archived: true,
        trashed: false,
        updated: DateTime.utc(2026, 10, 28),
      );

      final restored = Note.fromJson(note.toJson());

      expect(restored.id, 'note-1');
      expect(restored.title, 'Weekend idea');
      expect(restored.body, 'Write it down');
      expect(restored.tags, 'personal, ideas');
      expect(restored.pinned, isTrue);
      expect(restored.archived, isTrue);
      expect(restored.trashed, isFalse);
      expect(restored.updated, DateTime.utc(2026, 10, 28));
    });

    test('fills missing optional fields with safe defaults', () {
      final note = Note.fromJson({'id': 'old-note'});

      expect(note.id, 'old-note');
      expect(note.title, isEmpty);
      expect(note.body, isEmpty);
      expect(note.tags, isEmpty);
      expect(note.pinned, isFalse);
      expect(note.archived, isFalse);
      expect(note.trashed, isFalse);
    });
  });
}
