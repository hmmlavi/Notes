import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const brandPurple = Color(0xFF7569D9);
const textInk = Color(0xFF292638);
const noteSurface = Color(0xFFF7F5FF);

void main() => runApp(const NotesApp());

class Note {
  Note({
    required this.id,
    this.title = '',
    this.body = '',
    this.tags = '',
    this.pinned = false,
    this.archived = false,
    this.trashed = false,
    required this.updated,
  });

  final String id;
  String title;
  String body;
  String tags;
  bool pinned;
  bool archived;
  bool trashed;
  DateTime updated;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'tags': tags,
        'pinned': pinned,
        'archived': archived,
        'trashed': trashed,
        'updated': updated.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
      pinned: json['pinned'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      trashed: json['trashed'] as bool? ?? false,
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class NotesApp extends StatefulWidget {
  const NotesApp({super.key});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  final List<Note> notes = [];
  bool dark = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final stored = prefs.getString('notes');
      if (stored != null) {
        final decoded = jsonDecode(stored) as List<dynamic>;
        notes.addAll(decoded.map((item) =>
            Note.fromJson(Map<String, dynamic>.from(item as Map))));
      }
      dark = prefs.getBool('dark') ?? false;
    } catch (_) {
      // Ignore corrupted preview data and allow the app to open.
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'notes',
      jsonEncode(notes.map((note) => note.toJson()).toList()),
    );
    await prefs.setBool('dark', dark);
  }

  void changeTheme(bool value) {
    setState(() => dark = value);
    saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes By Lavi',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandPurple,
          brightness: dark ? Brightness.dark : Brightness.light,
        ),
        scaffoldBackgroundColor: dark ? Colors.black : Colors.white,
      ),
      home: loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : NotesHome(
              notes: notes,
              dark: dark,
              onThemeChanged: changeTheme,
              saveNotes: saveNotes,
            ),
    );
  }
}

class NotesHome extends StatefulWidget {
  const NotesHome({
    super.key,
    required this.notes,
    required this.dark,
    required this.onThemeChanged,
    required this.saveNotes,
  });

  final List<Note> notes;
  final bool dark;
  final ValueChanged<bool> onThemeChanged;
  final Future<void> Function() saveNotes;

  @override
  State<NotesHome> createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  String section = 'Notes';
  String query = '';
  final TextEditingController searchController = TextEditingController();

  Color get foreground => widget.dark ? Colors.white : textInk;
  Color get surface => widget.dark ? const Color(0xFF191821) : noteSurface;
  Color get cardText => widget.dark ? Colors.white : textInk;

  List<Note> get visibleNotes {
    final result = widget.notes.where((note) {
      final inSection = switch (section) {
        'Pinned' => note.pinned && !note.archived && !note.trashed,
        'Archive' => note.archived && !note.trashed,
        'Trash' => note.trashed,
        _ => !note.archived && !note.trashed,
      };
      final text = '${note.title} ${note.body} ${note.tags}'.toLowerCase();
      return inSection && text.contains(query.toLowerCase());
    }).toList();

    result.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updated.compareTo(a.updated);
    });
    return result;
  }

  Future<void> persistAndRefresh() async {
    if (mounted) setState(() {});
    await widget.saveNotes();
  }

  Future<void> openEditor([Note? existing]) async {
    final note = existing ??
        Note(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          updated: DateTime.now(),
        );
    if (existing == null) widget.notes.add(note);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteEditor(note: note, dark: widget.dark),
    );

    if (result == true) {
      note.updated = DateTime.now();
      await persistAndRefresh();
    } else if (existing == null) {
      widget.notes.remove(note);
      if (mounted) setState(() {});
    }
  }

  Future<void> toggleArchive(Note note) async {
    if (section == 'Trash') {
      note.trashed = false;
    } else if (section == 'Archive') {
      note.archived = false;
    } else {
      note.archived = true;
    }
    await persistAndRefresh();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 760;

    return Scaffold(
      floatingActionButton: section == 'Trash'
          ? null
          : FloatingActionButton.extended(
              onPressed: () => openEditor(),
              backgroundColor: brandPurple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New note'),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              NavigationRail(
                selectedIndex: ['Notes', 'Pinned', 'Archive', 'Trash'].indexOf(section),
                onDestinationSelected: (index) => setState(() {
                  section = ['Notes', 'Pinned', 'Archive', 'Trash'][index];
                }),
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.notes), label: Text('Notes')),
                  NavigationRailDestination(icon: Icon(Icons.push_pin_outlined), label: Text('Pinned')),
                  NavigationRailDestination(icon: Icon(Icons.archive_outlined), label: Text('Archive')),
                  NavigationRailDestination(icon: Icon(Icons.delete_outline), label: Text('Trash')),
                ],
              ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(wide ? 28 : 20, 18, wide ? 28 : 20, 14),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFECE9FF),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x227569D9), blurRadius: 12, offset: Offset(0, 5)),
                                ],
                              ),
                              child: const Icon(Icons.edit_note_rounded, color: brandPurple, size: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Notes', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, letterSpacing: -1, color: foreground)),
                                  Text('A little space for big ideas.', style: TextStyle(color: foreground.withValues(alpha: 0.65), fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Appearance',
                              onPressed: () => showDialog<void>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Make it yours'),
                                  content: SwitchListTile(
                                    title: const Text('AMOLED dark mode'),
                                    subtitle: const Text('True black background'),
                                    value: widget.dark,
                                    onChanged: (value) {
                                      widget.onThemeChanged(value);
                                      Navigator.pop(dialogContext);
                                    },
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done')),
                                  ],
                                ),
                              ),
                              icon: Icon(Icons.tune, color: foreground),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.dark
                                  ? const [Color(0xFF191622), Color(0xFF28213A)]
                                  : const [Color(0xFFF1EEFF), Color(0xFFFFF0E4)],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [BoxShadow(color: brandPurple.withValues(alpha: 0.12), blurRadius: 22, offset: const Offset(0, 8))],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('YOUR MIND, UNCLUTTERED', style: TextStyle(color: brandPurple, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
                                    const SizedBox(height: 8),
                                    Text('Catch the thought\nbefore it gets away.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2, color: foreground)),
                                    const SizedBox(height: 10),
                                    Text('${widget.notes.where((note) => !note.trashed && !note.archived).length} notes in your space', style: TextStyle(color: foreground.withValues(alpha: 0.7), fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(color: const Color(0xFFFFE6C9), borderRadius: BorderRadius.circular(20)),
                                child: const Icon(Icons.lightbulb_outline, color: Color(0xFFB56B37), size: 32),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(wide ? 28 : 20, 16, wide ? 28 : 20, 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(17),
                            boxShadow: [BoxShadow(color: brandPurple.withValues(alpha: 0.10), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(icon: Icon(Icons.search), hintText: 'Search notes, words, tags…', border: InputBorder.none),
                            onChanged: (value) => setState(() => query = value),
                          ),
                        ),
                      ),
                      if (!wide)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: ['Notes', 'Pinned', 'Archive', 'Trash'].map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(item),
                                  selected: section == item,
                                  onSelected: (_) => setState(() => section = item),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(wide ? 28 : 20, 8, wide ? 28 : 20, 10),
                        child: Row(
                          children: [
                            Text(
                              switch (section) {
                                'Pinned' => 'Kept close',
                                'Archive' => 'Out of sight',
                                'Trash' => 'Recently deleted',
                                _ => 'Your notes',
                              },
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: foreground),
                            ),
                            const Spacer(),
                            Text('${visibleNotes.length} items', style: TextStyle(color: foreground.withValues(alpha: 0.65), fontSize: 12)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: visibleNotes.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: const BoxDecoration(color: Color(0xFFECE9FF), shape: BoxShape.circle),
                                        child: const Icon(Icons.edit_note, color: brandPurple, size: 38),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(query.isNotEmpty ? 'Nothing found just yet' : 'Make room for an idea', style: TextStyle(color: foreground, fontWeight: FontWeight.w800, fontSize: 18)),
                                      Text('Your next note can start with one line.', textAlign: TextAlign.center, style: TextStyle(color: foreground.withValues(alpha: 0.65))),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                padding: EdgeInsets.fromLTRB(wide ? 28 : 20, 4, wide ? 28 : 20, 100),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: wide ? (width > 1050 ? 3 : 2) : 1,
                                  mainAxisExtent: 156,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                                itemCount: visibleNotes.length,
                                itemBuilder: (context, index) {
                                  final note = visibleNotes[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: surface,
                                      borderRadius: BorderRadius.circular(21),
                                      boxShadow: [BoxShadow(color: brandPurple.withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, 6))],
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(21),
                                      onTap: section == 'Trash' ? null : () => openEditor(note),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                if (note.pinned) const Icon(Icons.push_pin, color: brandPurple, size: 15),
                                                Expanded(
                                                  child: Text(note.title.isEmpty ? 'Untitled note' : note.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cardText)),
                                                ),
                                                if (section == 'Trash')
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    tooltip: 'Restore',
                                                    onPressed: () => toggleArchive(note),
                                                    icon: const Icon(Icons.restore, size: 18, color: brandPurple),
                                                  )
                                                else
                                                  PopupMenuButton<String>(
                                                    tooltip: 'Note actions',
                                                    icon: Icon(
                                                      section == 'Archive' ? Icons.unarchive_outlined : Icons.more_horiz,
                                                      size: 20,
                                                      color: brandPurple,
                                                    ),
                                                    onSelected: (action) async {
                                                      if (action == 'archive') {
                                                        await toggleArchive(note);
                                                      } else if (action == 'trash') {
                                                        note.trashed = true;
                                                        note.archived = false;
                                                        await persistAndRefresh();
                                                      } else if (action == 'restore') {
                                                        note.archived = false;
                                                        await persistAndRefresh();
                                                      }
                                                    },
                                                    itemBuilder: (context) => [
                                                      if (section == 'Archive')
                                                        const PopupMenuItem(
                                                          value: 'restore',
                                                          child: ListTile(
                                                            leading: Icon(Icons.unarchive_outlined),
                                                            title: Text('Restore from archive'),
                                                            contentPadding: EdgeInsets.zero,
                                                          ),
                                                        )
                                                      else
                                                        const PopupMenuItem(
                                                          value: 'archive',
                                                          child: ListTile(
                                                            leading: Icon(Icons.archive_outlined),
                                                            title: Text('Archive note'),
                                                            contentPadding: EdgeInsets.zero,
                                                          ),
                                                        ),
                                                      const PopupMenuItem(
                                                        value: 'trash',
                                                        child: ListTile(
                                                          leading: Icon(Icons.delete_outline),
                                                          title: Text('Move to Trash'),
                                                          contentPadding: EdgeInsets.zero,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if (section != 'Trash')
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    tooltip: note.pinned ? 'Unpin' : 'Pin',
                                                    onPressed: () async {
                                                      note.pinned = !note.pinned;
                                                      await persistAndRefresh();
                                                    },
                                                    icon: Icon(note.pinned ? Icons.push_pin : Icons.push_pin_outlined, size: 18, color: brandPurple),
                                                  )
                                                else
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    tooltip: 'Delete permanently',
                                                    onPressed: () async {
                                                      widget.notes.remove(note);
                                                      await persistAndRefresh();
                                                    },
                                                    icon: const Icon(Icons.delete_forever_outlined, size: 18, color: Colors.redAccent),
                                                  ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Text(note.body.isEmpty ? 'No additional text' : note.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, height: 1.4, color: widget.dark ? const Color(0xFFCBC8D6) : const Color(0xFF656371))),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(child: Text(note.tags.isEmpty ? 'Just now' : note.tags, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: brandPurple))),
                                                Text('${note.updated.month}/${note.updated.day}', style: TextStyle(fontSize: 10, color: widget.dark ? const Color(0xFFB7B4C3) : const Color(0xFF858392))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, required this.note, required this.dark});

  final Note note;
  final bool dark;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final TextEditingController titleController = TextEditingController(text: widget.note.title);
  late final TextEditingController bodyController = TextEditingController(text: widget.note.body);
  late final TextEditingController tagsController = TextEditingController(text: widget.note.tags);

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(top: 36, bottom: bottomInset),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.88,
        decoration: BoxDecoration(
          color: widget.dark ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      widget.note.title = titleController.text.trim();
                      widget.note.body = bodyController.text;
                      widget.note.tags = tagsController.text.trim();
                      Navigator.pop(context, true);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Done'),
                  ),
                ],
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Give this note a title', border: InputBorder.none),
                style: TextStyle(color: widget.dark ? Colors.white : textInk, fontSize: 27, fontWeight: FontWeight.w800),
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: bodyController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(hintText: 'A thought, a plan, a little reminder…\n\nStart wherever you are.', border: InputBorder.none),
                  style: TextStyle(color: widget.dark ? Colors.white : textInk, fontSize: 16, height: 1.6),
                ),
              ),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.sell_outlined), hintText: 'Tags (comma separated)', border: InputBorder.none),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
