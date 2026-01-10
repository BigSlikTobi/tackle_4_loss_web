# Player Wordle

An NFL player guessing game micro app for the T4L OS.

## Why
NFL fans enjoy testing their knowledge in a gamified format. Player Wordle provides an engaging Wordle-style experience focused on identifying NFL players through attribute-based clues.

## How
1. Start a game with a randomly selected mystery player
2. Search and select any NFL player as your guess
3. View color-coded feedback comparing your guess to the mystery player:
   - 🟢 Green = Exact match
   - 🟡 Yellow = Close (position side match, within 2 for numbers)
   - ⬜ Grey = No match
4. Use the clues to narrow down and guess again
5. Win by guessing correctly within 8 tries

## Architecture

```
player_wordle/
├── player_wordle_app.dart       # MicroApp entry point
├── models/
│   ├── player_model.dart        # Player attributes
│   ├── guess_result.dart        # Comparison results
│   └── game_state.dart          # Game session state
├── services/
│   └── player_wordle_service.dart  # Supabase edge function calls
├── controllers/
│   └── player_wordle_controller.dart  # Game logic & state
├── views/
│   ├── player_wordle_screen.dart  # Main game screen
│   └── widgets/
│       ├── attribute_tile.dart     # Color-coded feedback tile
│       ├── player_search_bar.dart  # Autocomplete search
│       ├── guess_grid.dart         # Grid of previous guesses
│       ├── silhouette_reveal.dart  # Progressive player reveal
│       ├── hint_button.dart        # Alma mater lifeline
│       ├── game_stats_card.dart    # Statistics display
│       └── player_reveal_card.dart # Post-game reveal
└── store_assets/
    ├── player_wordle_icon.png
    ├── player_wordle_store.png
    └── description.md
```

## Backend (Supabase Edge Functions)
- `get-random-player` - Selects a random mystery player
- `search-players` - Autocomplete player search
- `compare-player-guess` - Compares guess attributes to mystery player
- `get-player-details` - Returns full player profile for reveal

## Technical Decisions
- **State Management**: ChangeNotifier with Provider
- **Statistics**: SharedPreferences for local persistence
- **Animations**: Tile flip animations for guess reveals
- **Design**: Uses T4LScaffold and design_tokens.dart
