import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlists'),
        actions: [
          IconButton(
            onPressed: () => _showCreateWatchlistDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state.status == WatchlistStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == WatchlistStatus.failure) {
            return Center(
              child: Text(state.errorMessage ?? 'Something went wrong.'),
            );
          }

          if (state.watchlists.isEmpty) {
            return _EmptyWatchlist(
              onCreate: () {
                _showCreateWatchlistDialog(context);
              },
            );
          }

          final selectedWatchlist = _getSelectedWatchlist(state.watchlists);

          return Column(
            children: [
              _WatchlistSelector(
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
              Expanded(child: _WatchlistStocks(watchlist: selectedWatchlist)),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state.watchlists.isEmpty) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () {
              final selectedWatchlist = _getSelectedWatchlist(state.watchlists);

              _showAddStockSheet(context, selectedWatchlist);
            },
            child: const Icon(Icons.add),
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

        return AlertDialog(
          title: const Text('Create watchlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. My Stocks',
            ),
            onSubmitted: (value) {
              Navigator.pop(dialogContext, value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text);
              },
              child: const Text('Create'),
            ),
          ],
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename watchlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text('Save'),
            ),
          ],
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete watchlist?'),
          content: Text('Delete "${watchlist.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
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
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Add stock',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...availableStocks.map((stock) {
                return ListTile(
                  title: Text(stock.symbol),
                  subtitle: Text(stock.name),
                  onTap: () {
                    this.context.read<WatchlistBloc>().add(
                      AddStockToWatchlist(
                        watchlistId: watchlist.id,
                        symbol: stock.symbol,
                      ),
                    );

                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _WatchlistSelector extends StatelessWidget {
  final List<Watchlist> watchlists;
  final Watchlist selectedWatchlist;
  final ValueChanged<Watchlist> onChanged;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _WatchlistSelector({
    required this.watchlists,
    required this.selectedWatchlist,
    required this.onChanged,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<Watchlist>(
              initialValue: selectedWatchlist,
              decoration: const InputDecoration(
                labelText: 'Watchlist',
                border: OutlineInputBorder(),
              ),
              items: watchlists.map((watchlist) {
                return DropdownMenuItem(
                  value: watchlist,
                  child: Text(watchlist.name),
                );
              }).toList(),
              onChanged: (watchlist) {
                if (watchlist != null) {
                  onChanged(watchlist);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'rename') {
                onRename();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _WatchlistStocks extends StatelessWidget {
  final Watchlist watchlist;

  const _WatchlistStocks({required this.watchlist});

  @override
  Widget build(BuildContext context) {
    if (watchlist.stockSymbols.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_outlined, size: 48),
            SizedBox(height: 12),
            Text(
              'This watchlist is empty',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text('Add stocks to start tracking them.'),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: watchlist.stockSymbols.length,
      onReorder: (oldIndex, newIndex) {
        context.read<WatchlistBloc>().add(
          ReorderWatchlistStocks(
            watchlistId: watchlist.id,
            oldIndex: oldIndex,
            newIndex: newIndex,
          ),
        );
      },
      itemBuilder: (context, index) {
        final symbol = watchlist.stockSymbols[index];

        final stock = StockData.stocks.firstWhere(
          (stock) => stock.symbol == symbol,
        );

        return Dismissible(
          key: ValueKey(symbol),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            context.read<WatchlistBloc>().add(
              RemoveStockFromWatchlist(
                watchlistId: watchlist.id,
                symbol: symbol,
              ),
            );

            return false;
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: StockPriceTile(
            key: ValueKey('${watchlist.id}-$symbol'),
            stock: stock,
          ),
        );
      },
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyWatchlist({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No watchlists yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a watchlist to start tracking stocks.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create watchlist'),
            ),
          ],
        ),
      ),
    );
  }
}
