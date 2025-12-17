import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../repository/games_repository.dart';

// Repository provider
final gamesRepositoryProvider = Provider<GamesRepository>((ref) {
  return GamesRepository();
});

// Main games provider - fetches all games from Supabase
final gamesProvider = FutureProvider<List<Game>>((ref) async {
  final repository = ref.read(gamesRepositoryProvider);
  final games = await repository.fetchGames();

  // Assign tags to some games for visual variety
  return games.asMap().entries.map((entry) {
    final index = entry.key;
    final game = entry.value;

    // Only assign tag if game doesn't already have one
    if (game.tag != null && game.tag!.isNotEmpty) {
      return game;
    }

    String? tag;
    if (index % 7 == 0) {
      tag = 'NEW';
    } else if (index % 5 == 0) {
      tag = 'HOT';
    } else if (index % 11 == 0) {
      tag = 'EXCLUSIVE';
    }

    return tag != null ? game.copyWith(tag: tag) : game;
  }).toList();
});

// Premium games - randomly select 5 games from all games
final animatedGamesProvider = FutureProvider<List<Game>>((ref) async {
  final games = await ref.watch(gamesProvider.future);
  
  // Randomly select 5 games from all available games
  if (games.length <= 5) {
    return games;
  }
  
  final random = Random();
  final selectedGames = <Game>[];
  final availableIndices = List<int>.generate(games.length, (i) => i);
  
  for (int i = 0; i < 5; i++) {
    final randomIndex = random.nextInt(availableIndices.length);
    final gameIndex = availableIndices.removeAt(randomIndex);
    selectedGames.add(games[gameIndex]);
  }
  
  return selectedGames;
});

// Static/More games - the rest
final staticGamesProvider = FutureProvider<List<Game>>((ref) async {
  final games = await ref.watch(gamesProvider.future);
  final premiumGames = await ref.watch(animatedGamesProvider.future);

  // Return games not in premium list
  final premiumIds = premiumGames.map((g) => g.id).toSet();
  return games.where((game) => !premiumIds.contains(game.id)).toList();
});

// Featured games for hero section
final featuredGamesProvider = FutureProvider<List<Game>>((ref) async {
  final games = await ref.watch(gamesProvider.future);
  return games.take(6).toList();
});

// Selected category for filtering
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Filtered games based on selected category
final filteredGamesProvider = Provider<AsyncValue<List<Game>>>((ref) {
  final gamesAsync = ref.watch(gamesProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return gamesAsync.whenData((games) {
    if (selectedCategory == 'All') {
      return games;
    }
    // Filter by tag
    return games.where((game) => game.tag == selectedCategory).toList();
  });
});

// Search provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedGamesProvider = Provider<AsyncValue<List<Game>>>((ref) {
  final gamesAsync = ref.watch(gamesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return gamesAsync.whenData((games) {
    if (query.isEmpty) {
      return games;
    }
    return games
        .where((game) => game.name.toLowerCase().contains(query))
        .toList();
  });
});
