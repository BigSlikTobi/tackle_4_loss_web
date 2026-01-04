# Game Reports Micro-App

AI-powered NFL post-game recaps with local FunctionGemma inference and optional cloud enhancement.

## Architecture

```
game_reports/
├── game_reports_app.dart         # MicroApp registration
├── controllers/
│   └── game_report_controller.dart  # Orchestrates report generation
├── models/
│   ├── report_request.dart       # Request parameters
│   └── report_response.dart      # Generated report structure
├── services/
│   ├── cloud_report_limiter.dart # Rate limiting (5/day)
│   └── function_executor.dart    # Local template-based generation
├── views/
│   ├── game_report_screen.dart   # Main screen
│   └── widgets/
│       ├── game_selector.dart    # Pick a completed game
│       ├── style_selector.dart   # Choose report style
│       └── report_card.dart      # Display generated report
└── store_assets/
    └── description.md
```

## Features

- **Local First**: Template-based reports work offline
- **Cloud Optional**: Enhanced reports with Gemini (rate limited)
- **Cost Control**: Maximum 5 cloud-enhanced reports per user per day
- **Three Styles**: Casual, Detailed, Stats-focused

## Future Enhancements

- [ ] Integrate FunctionGemma for natural language queries
- [ ] Add pre-game previews
- [ ] Team-focused narratives based on user's favorite team
- [ ] Share reports as images
