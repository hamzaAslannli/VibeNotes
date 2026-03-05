import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:vibe_notes/features/voice_record/presentation/widgets/recording_sheet.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';
import 'package:vibe_notes/features/notes/presentation/pages/note_detail_page.dart';
import 'package:vibe_notes/features/settings/presentation/pages/settings_page.dart';
import 'package:vibe_notes/core/utils/date_helper.dart';

enum SortOption { newest, oldest }
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.newest);
final searchQueryProvider = StateProvider<String>((ref) => '');

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notesControllerProvider).loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesListProvider);
    final isLoading = ref.watch(notesLoadingProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Search notes...', hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none),
                onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
              )
            : const Text('Vibe Notes'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search, color: Colors.white70),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'sort_newest') ref.read(sortOptionProvider.notifier).state = SortOption.newest;
              else if (value == 'sort_oldest') ref.read(sortOptionProvider.notifier).state = SortOption.oldest;
              else if (value == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(enabled: false, child: Text('Sort by', style: TextStyle(color: Colors.white38, fontSize: 12))),
              PopupMenuItem(
                value: 'sort_newest',
                child: Row(children: [
                  if (sortOption == SortOption.newest) const Icon(Icons.check, color: Colors.deepPurpleAccent, size: 18) else const SizedBox(width: 18),
                  const SizedBox(width: 12),
                  const Text('Newest first', style: TextStyle(color: Colors.white)),
                ]),
              ),
              PopupMenuItem(
                value: 'sort_oldest',
                child: Row(children: [
                  if (sortOption == SortOption.oldest) const Icon(Icons.check, color: Colors.deepPurpleAccent, size: 18) else const SizedBox(width: 18),
                  const SizedBox(width: 12),
                  const Text('Oldest first', style: TextStyle(color: Colors.white)),
                ]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: Row(children: [
                  Icon(Icons.settings, color: Colors.white54, size: 18),
                  SizedBox(width: 12),
                  Text('Settings', style: TextStyle(color: Colors.white)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats header
          _buildStatsHeader(notes),
          // Category filter chips
          _buildCategoryFilter(categoryFilter),
          // Notes list
          Expanded(child: _buildBody(notes, isLoading, sortOption, searchQuery, categoryFilter)),
        ],
      ),
      floatingActionButton: _buildFABRow(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatsHeader(List<Note> notes) {
    final noteCount = notes.length;
    final aiCount = notes.where((n) => n.isSummarized || n.expandedIdea != null).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.withOpacity(0.15), Colors.purple.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.deepPurpleAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  noteCount == 0 ? 'Start capturing ideas!' : '$noteCount idea${noteCount > 1 ? 's' : ''} captured',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (aiCount > 0)
                  Text(
                    '$aiCount AI-enhanced',
                    style: TextStyle(color: Colors.cyanAccent.withOpacity(0.6), fontSize: 12),
                  ),
              ],
            ),
          ),
          Text('\u{1F9E0}', style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(NoteCategory? selected) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // All filter
          GestureDetector(
            onTap: () => ref.read(categoryFilterProvider.notifier).state = null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: selected == null ? Colors.deepPurpleAccent : Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('All', style: TextStyle(color: selected == null ? Colors.white : Colors.white60, fontWeight: FontWeight.w500)),
            ),
          ),
          ...NoteCategory.values.map((category) {
            final isSelected = category == selected;
            return GestureDetector(
              onTap: () => ref.read(categoryFilterProvider.notifier).state = category,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Color(category.colorValue).withOpacity(0.3) : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? Border.all(color: Color(category.colorValue), width: 1.5) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.emoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(category.displayName, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBody(List<Note> notes, bool isLoading, SortOption sortOption, String searchQuery, NoteCategory? categoryFilter) {
    if (isLoading && notes.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
    }

    var filteredNotes = notes.where((note) {
      if (searchQuery.isNotEmpty && !note.content.toLowerCase().contains(searchQuery.toLowerCase())) return false;
      if (categoryFilter != null && note.category != categoryFilter) return false;
      return true;
    }).toList();
    
    if (sortOption == SortOption.oldest) {
      filteredNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    if (filteredNotes.isEmpty && (searchQuery.isNotEmpty || categoryFilter != null)) {
      return _buildNoResultsState();
    }
    
    if (filteredNotes.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) => _buildNoteCard(context, filteredNotes[index], ref),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text('No notes found', style: TextStyle(color: Colors.white54, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.deepPurple.withOpacity(0.3), Colors.purple.withOpacity(0.1)]),
            ),
            child: const Icon(Icons.mic_none_rounded, size: 48, color: Colors.white24),
          ),
          const SizedBox(height: 24),
          const Text('No vibes yet', style: TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text('Tap the button to record', style: TextStyle(color: Colors.white24, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFABRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Quick text note button
        GestureDetector(
          onTap: () => _showQuickTextNoteDialog(context),
          child: Container(
            width: 52,
            height: 52,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2A),
              border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.edit_note_rounded, size: 24, color: Colors.white70),
          ),
        ),
        // Main mic button
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => const RecordingSheet(),
            );
          },
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9C27B0), Color(0xFF673AB7), Color(0xFF3F51B5)]),
              boxShadow: [
                BoxShadow(color: Colors.deepPurpleAccent.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8)),
                BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 40, spreadRadius: -5, offset: const Offset(0, 12)),
              ],
            ),
            child: const Icon(Icons.mic_rounded, size: 32, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _showQuickTextNoteDialog(BuildContext context) async {
    final controller = TextEditingController();
    NoteCategory selectedCategory = NoteCategory.other;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Quick Note \u270F\uFE0F', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type your idea...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NoteCategory.values.map((category) {
                  final isSelected = category == selectedCategory;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedCategory = category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(category.colorValue).withOpacity(0.3) : Colors.white10,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: Color(category.colorValue), width: 1.5) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category.emoji, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(category.displayName, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, {'title': controller.text.trim(), 'category': selectedCategory});
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await ref.read(notesControllerProvider).addNote(
        result['title'] as String,
        category: result['category'] as NoteCategory,
      );
    }
  }

  Widget _buildNoteCard(BuildContext context, Note note, WidgetRef ref) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => ref.read(notesControllerProvider).deleteNote(note.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => NoteDetailPage(note: note)));
              ref.read(notesControllerProvider).loadNotes();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category indicator
                  Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: Color(note.category.colorValue).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: note.audioPath != null 
                        ? Icon(Icons.graphic_eq_rounded, color: Color(note.category.colorValue), size: 22)
                        : Text(note.category.emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(note.content, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            if (note.isSummarized) Padding(padding: const EdgeInsets.only(left: 6), child: Icon(Icons.auto_awesome, color: Colors.cyanAccent.withOpacity(0.6), size: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(note.category.colorValue).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(note.category.displayName, style: TextStyle(color: Color(note.category.colorValue), fontSize: 10, fontWeight: FontWeight.w500)),
                            ),
                            const SizedBox(width: 8),
                            Text(DateHelper.getRelativeTime(note.createdAt), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
