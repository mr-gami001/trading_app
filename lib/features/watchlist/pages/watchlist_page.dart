import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/theme_bloc.dart';
import '../../../app/theme/theme_event.dart';
import '../../../app/theme/theme_state.dart';
import '../../market/widgets/stock_row_tile.dart';
import '../../profile/pages/profile_page.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_filter_bloc.dart';
import '../bloc/watchlist_filter_event.dart';
import '../bloc/watchlist_filter_state.dart';
import '../bloc/watchlist_state.dart';
import '../widgets/add_stock_modal.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WatchlistFilterBloc>(
      create: (context) => WatchlistFilterBloc(),
      child: const _WatchlistPageContent(),
    );
  }
}

class _WatchlistPageContent extends StatefulWidget {
  const _WatchlistPageContent();

  @override
  State<_WatchlistPageContent> createState() => _WatchlistPageContentState();
}

class _WatchlistPageContentState extends State<_WatchlistPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateWatchlistDialog(BuildContext context) {
    final controller = TextEditingController();
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final activeColor = AppTheme.getGainColor(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Watchlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Watchlist Name (e.g. Banking Stocks)',
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: activeColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: AppTheme.getTextMuted(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: activeColor),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<WatchlistBloc>().add(CreateWatchlistEvent(name));
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, String watchlistId, String currentName) {
    final controller = TextEditingController(text: currentName);
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final activeColor = AppTheme.getGainColor(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename Watchlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Watchlist Name',
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: activeColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: AppTheme.getTextMuted(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: activeColor),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<WatchlistBloc>().add(RenameWatchlistEvent(watchlistId, name));
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final activeColor = AppTheme.getGainColor(context);
    final mutedText = AppTheme.getTextMuted(context);

    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        final activeWl = state.activeWatchlist;
        final bloc = context.read<WatchlistBloc>();

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: cardSurface,
            elevation: 0,
            leading: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: activeColor,
                  child: const Text('DG', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.bookmark, color: activeColor),
                const SizedBox(width: 8),
                const Text(
                  'Watchlist',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return IconButton(
                    icon: Icon(
                      themeState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF536DFE),
                    ),
                    tooltip: 'Toggle Theme',
                    onPressed: () {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.playlist_add),
                tooltip: 'New Watchlist',
                onPressed: () => _showCreateWatchlistDialog(context),
              ),
            ],
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Watchlist Pill Selector Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: cardSurface,
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(state.watchlists.length, (index) {
                                  final wl = state.watchlists[index];
                                  final isSelected = index == state.activeWatchlistIndex;

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      label: Text(wl.name),
                                      selected: isSelected,
                                      selectedColor: activeColor,
                                      backgroundColor: bg,
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : mutedText,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      onSelected: (_) => bloc.add(SelectWatchlistEvent(index)),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          if (activeWl != null) ...[
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: mutedText),
                              color: cardSurface,
                              onSelected: (value) {
                                if (value == 'rename') {
                                  _showRenameDialog(context, activeWl.id, activeWl.name);
                                } else if (value == 'delete') {
                                  bloc.add(DeleteWatchlistEvent(activeWl.id));
                                }
                              },
                              itemBuilder: (context) => [
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
                                      Icon(Icons.delete_outline, color: AppTheme.getLossColor(context), size: 18),
                                      const SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: AppTheme.getLossColor(context))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Search Filter
                    if (activeWl != null && activeWl.symbols.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: cardSurface,
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: BlocBuilder<WatchlistFilterBloc, WatchlistFilterState>(
                            builder: (context, filterState) {
                              return TextField(
                                controller: _searchController,
                                style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Search watchlist symbols',
                                  hintStyle: TextStyle(color: mutedText, fontSize: 12),
                                  prefixIcon: Icon(Icons.search, color: mutedText, size: 18),
                                  suffixIcon: filterState.searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, color: mutedText, size: 16),
                                          onPressed: () {
                                            _searchController.clear();
                                            context.read<WatchlistFilterBloc>().add(const UpdateWatchlistSearchQueryEvent(''));
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onChanged: (val) {
                                  context.read<WatchlistFilterBloc>().add(UpdateWatchlistSearchQueryEvent(val.trim().toLowerCase()));
                                },
                              );
                            },
                          ),
                        ),
                      ),

                    // Stock List or Empty State
                    Expanded(
                      child: activeWl == null || activeWl.symbols.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.playlist_add, size: 64, color: mutedText),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'This watchlist is empty',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add stocks to track live prices in real time',
                                    style: TextStyle(color: mutedText, fontSize: 13),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: activeColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    label: const Text('Add Stocks', style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      if (activeWl != null) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (ctx) => AddStockModal(watchlistId: activeWl.id),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            )
                          : BlocBuilder<WatchlistFilterBloc, WatchlistFilterState>(
                              builder: (context, filterState) {
                                final filteredList = activeWl.symbols.where((s) => filterState.searchQuery.isEmpty || s.toLowerCase().contains(filterState.searchQuery)).toList();

                                return ReorderableListView.builder(
                                  itemCount: filteredList.length,
                                  // ignore: deprecated_member_use
                                  onReorder: (oldIndex, newIndex) {
                                    bloc.add(ReorderWatchlistEvent(activeWl.id, oldIndex, newIndex));
                                  },
                                  itemBuilder: (context, index) {
                                    final symbol = filteredList[index];

                                    return Dismissible(
                                      key: ValueKey('wl_${activeWl.id}_$symbol'),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: 20),
                                        color: AppTheme.getLossColor(context),
                                        child: const Icon(Icons.delete, color: Colors.white),
                                      ),
                                      onDismissed: (_) {
                                        bloc.add(RemoveStockFromWatchlistEvent(activeWl.id, symbol));
                                      },
                                      child: StockRowTile(
                                        key: ValueKey('stock_tile_$symbol'),
                                        symbol: symbol,
                                        isReorderable: true,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: activeWl != null
              ? FloatingActionButton(
                  backgroundColor: activeColor,
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => AddStockModal(watchlistId: activeWl.id),
                    );
                  },
                )
              : null,
        );
      },
    );
  }
}
