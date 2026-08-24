import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trading_app/features/trading/screens/order_ticket_screen.dart';
import 'package:trading_app/features/watchlist/widgets/empty_watchlist.dart';
import 'package:trading_app/features/watchlist/widgets/error_state.dart';
import 'package:trading_app/features/watchlist/widgets/theme_dialog.dart';
import 'package:trading_app/features/watchlist/widgets/watchlist_header.dart';
import 'package:trading_app/features/watchlist/widgets/watchlist_stocks.dart';

import '../../market/data/datasources/stock_data.dart';
import '../../market/widgets/stock_price_tile.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
import '../data/models/watchlist.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  String? _selectedWatchlistId;

  static const backgroundColor = Color(0xFF0B0F14);
  static const cardColor = Color(0xFF151B23);
  static const borderColor = Color(0xFF202832);
  static const secondaryTextColor = Color(0xFF7D8794);
  static const accentColor = Color(0xFF4ADE80);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Watchlist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Create watchlist',
            onPressed: () => _showCreateWatchlistDialog(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
          SizedBox(width: 8.w),
        ],
      ),

      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state.status == WatchlistStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: accentColor),
            );
          }

          if (state.status == WatchlistStatus.failure) {
            return ErrorState(
              message: state.errorMessage ?? 'Something went wrong.',
            );
          }

          if (state.watchlists.isEmpty) {
            return EmptyWatchlist(
              onCreate: () {
                _showCreateWatchlistDialog(context);
              },
            );
          }

          final selectedWatchlist = _getSelectedWatchlist(state.watchlists);

          return Column(
            children: [
              WatchlistHeader(
                watchlists: state.watchlists,
                selectedWatchlist: selectedWatchlist,
                onChanged: (watchlist) {
                  setState(() {
                    _selectedWatchlistId = watchlist.id;
                  });
                },
                onRename: () {
                  _showRenameWatchlistDialog(context, selectedWatchlist);
                },
                onDelete: () {
                  _showDeleteWatchlistDialog(context, selectedWatchlist);
                },
              ),

              Expanded(child: WatchlistStocks(watchlist: selectedWatchlist)),
            ],
          );
        },
      ),

      floatingActionButton: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state.watchlists.isEmpty) {
            return const SizedBox.shrink();
          }

          final selectedWatchlist = _getSelectedWatchlist(state.watchlists);

          return FloatingActionButton.extended(
            backgroundColor: accentColor,
            foregroundColor: const Color(0xFF0B0F14),
            elevation: 4,
            onPressed: () {
              _showAddStockSheet(context, selectedWatchlist);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add stock',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          );
        },
      ),
    );
  }

  Watchlist _getSelectedWatchlist(List<Watchlist> watchlists) {
    if (_selectedWatchlistId != null) {
      for (final watchlist in watchlists) {
        if (watchlist.id == _selectedWatchlistId) {
          return watchlist;
        }
      }
    }

    return watchlists.first;
  }

  Future<void> _showCreateWatchlistDialog(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController();

        return ThemedDialog(
          title: 'Create watchlist',

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: const Color(0xFF0B0F14),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, controller.text);
              },
              child: const Text(
                'Create',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
          child: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.white),
            cursorColor: accentColor,
            decoration: _inputDecoration(label: 'Name', hint: 'e.g. My Stocks'),
            onSubmitted: (value) {
              Navigator.pop(dialogContext, value);
            },
          ),
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    if (name == null || name.trim().isEmpty) {
      return;
    }

    context.read<WatchlistBloc>().add(CreateWatchlist(name.trim()));
  }

  Future<void> _showRenameWatchlistDialog(
    BuildContext context,
    Watchlist watchlist,
  ) async {
    final controller = TextEditingController(text: watchlist.name);

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return ThemedDialog(
          title: 'Rename watchlist',

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: const Color(0xFF0B0F14),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, controller.text);
              },
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
          child: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            cursorColor: accentColor,
            decoration: _inputDecoration(label: 'Name'),
          ),
        );
      },
    );

    controller.dispose();

    if (!context.mounted) {
      return;
    }

    if (name == null || name.trim().isEmpty) {
      return;
    }

    context.read<WatchlistBloc>().add(
      RenameWatchlist(id: watchlist.id, name: name.trim()),
    );
  }

  Future<void> _showDeleteWatchlistDialog(
    BuildContext context,
    Watchlist watchlist,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return ThemedDialog(
          title: 'Delete watchlist?',

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF87171),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
          child: Text(
            'Delete "${watchlist.name}"? This action cannot be undone.',
            style: const TextStyle(color: secondaryTextColor, height: 1.4),
          ),
        );
      },
    );

    if (!context.mounted || shouldDelete != true) {
      return;
    }

    context.read<WatchlistBloc>().add(DeleteWatchlist(watchlist.id));

    if (_selectedWatchlistId == watchlist.id) {
      setState(() {
        _selectedWatchlistId = null;
      });
    }
  }

  Future<void> _showAddStockSheet(
    BuildContext context,
    Watchlist watchlist,
  ) async {
    final availableStocks = StockData.stocks.where(
      (stock) => !watchlist.stockSymbols.contains(stock.symbol),
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add stock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a stock to add to ${watchlist.name}',
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                if (availableStocks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'All available stocks are already added.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: availableStocks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final stock = availableStocks.elementAt(index);

                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B222C),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: ListTile(
                            onTap: () {
                              context.read<WatchlistBloc>().add(
                                AddStockToWatchlist(
                                  watchlistId: watchlist.id,
                                  symbol: stock.symbol,
                                ),
                              );

                              Navigator.pop(sheetContext);
                            },
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF252E39),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                stock.symbol.substring(
                                  0,
                                  stock.symbol.length > 2
                                      ? 2
                                      : stock.symbol.length,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            title: Text(
                              stock.symbol,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              stock.name,
                              style: const TextStyle(
                                color: secondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: accentColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

InputDecoration _inputDecoration({required String label, String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(color: Color(0xFF7D8794)),
    hintStyle: const TextStyle(color: Color(0xFF596573)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF202832)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4ADE80)),
    ),
  );
}
