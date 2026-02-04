import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:vibe_notes/features/voice_record/presentation/widgets/recording_sheet.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';
import 'package:vibe_notes/features/notes/presentation/pages/note_detail_page.dart';
import 'package:vibe_notes/core/utils/date_helper.dart';

// Sort options provider
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesControllerProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              )
            : const Text('Vibe Notes'),
        actions: [
          // Search toggle
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
          // Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'sort_newest') {
                ref.read(sortOptionProvider.notifier).state = SortOption.newest;
              } else if (value == 'sort_oldest') {
                ref.read(sortOptionProvider.notifier).state = SortOption.oldest;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text('Sort by', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
              PopupMenuItem(
                value: 'sort_newest',
                child: Row(
                  children: [
                    Icon(
                      sortOption == SortOption.newest ? Icons.check : null,
                      color: Colors.deepPurpleAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    const Text('Newest first', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_oldest',
                child: Row(
                  children: [
                    Icon(
                      sortOption == SortOption.oldest ? Icons.check : null,
                      color: Colors.deepPurpleAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    const Text('Oldest first', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white54, size: 18),
                    const SizedBox(width: 12),
                    const Text('About', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          // Apply search filter
          var filteredNotes = notes.where((note) {
            if (searchQuery.isEmpty) return true;
            return note.content.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
          
          // Apply sort
          if (sortOption == SortOption.oldest) {
            filteredNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          } else {
            filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }

          if (filteredNotes.isEmpty && searchQuery.isNotEmpty) {
            return _buildNoResultsState();
          }
          
          if (filteredNotes.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              final note = filteredNotes[index];
              return _buildNoteCard(context, note, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent)),
        error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white54))),
      ),
      floatingActionButton: _buildPremiumFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'No notes found',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(color: Colors.white24, fontSize: 14),
          ),
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
              gradient: LinearGradient(
                colors: [Colors.deepPurple.withOpacity(0.3), Colors.purple.withOpacity(0.1)],
              ),
            ),
            child: const Icon(Icons.mic_none_rounded, size: 48, color: Colors.white24),
          ),
          const SizedBox(height: 24),
          const Text(
            'No vibes yet',
            style: TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to record your first note',
            style: TextStyle(color: Colors.white24, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFAB(BuildContext context) {
    return GestureDetector(
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9C27B0), Color(0xFF673AB7), Color(0xFF3F51B5)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.5),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: -5,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(Icons.mic_rounded, size: 32, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note, WidgetRef ref) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        ref.read(notesControllerProvider.notifier).deleteNote(note.id);
      },
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoteDetailPage(note: note)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (note.audioPath != null)
                    Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.graphic_eq_rounded, color: Colors.deepPurpleAccent, size: 22),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.content,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateHelper.getRelativeTime(note.createdAt),
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
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
