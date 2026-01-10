# Player Wordle - NFL Guessing Game

## Summary
An addictive NFL player guessing game where users identify a mystery player within 8 guesses using color-coded attribute feedback.

## The Why (User Need)
NFL fans love testing their knowledge and competing with friends. Player Wordle taps into the viral success of Wordle-style games while focusing on NFL player knowledge. It provides:
- Entertainment value for football fans
- Knowledge testing in a gamified format
- Casual gameplay that can be enjoyed anytime
- Statistics tracking for competitive players

## The How (Functionality)
### Core Game Loop
1. User starts a new game with a random mystery player
2. User searches for and selects an NFL player guess
3. System compares the guess to the mystery player across 7 attributes
4. Color-coded feedback shows how close each attribute is
5. User uses clues to narrow down and guess again
6. Game ends when user guesses correctly (win) or runs out of guesses (lose)

### Feedback System
| Status | Color | Meaning |
|--------|-------|---------|
| Match | Green | Exact match |
| Partial | Yellow | Close (same position side, within 2 numbers) |
| Miss | Grey | No match |

### Features
- **Unlimited Play**: No daily limits, play anytime
- **Progressive Silhouette**: Mystery player image revealed over guesses
- **Hint System**: Reveal college/alma mater if stuck
- **Statistics**: Track games, wins, streaks locally

## Architecture
```
lib/micro_apps/player_wordle/
├── models/
│   ├── player_model.dart      # Player data structure
│   ├── guess_result.dart      # Comparison results
│   └── game_state.dart        # Game session state
├── services/
│   └── player_wordle_service.dart  # Supabase API calls
├── controllers/
│   └── player_wordle_controller.dart  # State + logic
└── views/
    ├── player_wordle_screen.dart  # Main screen
    └── widgets/  # UI components
```

## Technical Details
- **Backend**: 4 Supabase Edge Functions
  - `get-random-player`: Selects mystery player
  - `search-players`: Autocomplete search
  - `compare-player-guess`: Compares attributes
  - `get-player-details`: Full player reveal
- **Frontend**: Flutter with Provider state management
- **Storage**: SharedPreferences for local statistics
- **Design**: Uses T4LScaffold and design_tokens.dart

## Checklist
- [x] MVC architecture followed
- [x] T4LScaffold used
- [x] Design tokens used
- [x] Backend edge functions created
- [ ] Tests written
- [x] README.md created
- [x] publication.md created
- [ ] Store assets generated
- [ ] Registered in AppRegistry
- [ ] Feature flag added
