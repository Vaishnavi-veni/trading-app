import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/watchlist.dart';

class WatchlistLocalDataSource {
  static const _storageKey = 'watchlists';

  Future<List<Watchlist>> loadWatchlists() async {
    final preferences = await SharedPreferences.getInstance();

    final rawValue = preferences.getString(_storageKey);

    if (rawValue == null || rawValue.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawValue);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((item) => Watchlist.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      // Corrupted local data should not crash the app.
      return [];
    }
  }

  Future<void> saveWatchlists(List<Watchlist> watchlists) async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      watchlists.map((watchlist) => watchlist.toJson()).toList(),
    );

    await preferences.setString(_storageKey, encoded);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }
}
