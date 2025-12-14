import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';

final gamesProvider = FutureProvider<List<Game>>((ref) async {
  final String jsonString = await rootBundle.loadString('assets/games-data.json');
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  final List<dynamic> gamesJson = jsonData['games'] as List<dynamic>;

  final games = gamesJson.map((gameJson) {
    final game = Game.fromJson(gameJson as Map<String, dynamic>);
    // Assign random tags to some games for visual variety
    String? tag;
    final index = gamesJson.indexOf(gameJson);
    if (index % 7 == 0) {
      tag = 'NEW';
    } else if (index % 5 == 0) {
      tag = 'HOT';
    } else if (index % 11 == 0) {
      tag = 'EXCLUSIVE';
    }
    return Game(
      id: game.id,
      name: game.name,
      iframe: game.iframe,
      image: game.image,
      animatedLogo: game.animatedLogo,
      tag: tag,
      screenshots: game.screenshots,
    );
  }).toList();

  return games;
});

// Premium games (first 10)
final animatedGamesProvider = FutureProvider<List<Game>>((ref) async {
  final games = await ref.watch(gamesProvider.future);
  return games.take(10).toList();
});

// More games (rest of them)
final staticGamesProvider = FutureProvider<List<Game>>((ref) async {
  final games = await ref.watch(gamesProvider.future);
  return games.skip(10).toList();
});

final featuredGamesProvider = FutureProvider<List<Game>>((ref) async {
  final games = await ref.watch(gamesProvider.future);
  // Return first 6 games as featured
  return games.take(6).toList();
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredGamesProvider = Provider<AsyncValue<List<Game>>>((ref) {
  final gamesAsync = ref.watch(gamesProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return gamesAsync.whenData((games) {
    if (selectedCategory == 'All') {
      return games;
    }
    // In a real app, you'd filter by actual category
    // For now, we'll just return all games
    return games;
  });
});
