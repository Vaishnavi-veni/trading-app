import 'package:flutter/material.dart';

class EmptyWatchlist extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyWatchlist({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF151B23),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.visibility_outlined,
                size: 36,
                color: Color(0xFF596573),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No watchlists yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a watchlist to start tracking your favorite stocks.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7D8794),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4ADE80),
                foregroundColor: const Color(0xFF0B0F14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
              ),
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Create watchlist',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
