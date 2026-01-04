---
description: How to run Flutter tests and check coverage
---

# Flutter Testing Workflow

## Quick Commands

```bash
# Navigate to flutter_app directory
cd flutter_app

# Install dependencies if needed
flutter pub get

# Run all tests
// turbo
flutter test

# Run tests with coverage report
// turbo
flutter test --coverage

# Run specific test file
flutter test test/core/services/settings_service_test.dart

# Run tests matching a pattern
flutter test --name="SettingsService"
```

## Viewing Coverage

```bash
# Generate HTML coverage report (requires lcov)
# Install lcov: brew install lcov
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

## Creating New Tests

1. Create test file in `test/` directory mirroring `lib/` structure
2. Import `package:flutter_test/flutter_test.dart`
3. Use mock services for external dependencies (Supabase, etc.)
4. Follow TDD: write test first, then implementation

### Example Test Structure
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyService', () {
    late MyService service;

    setUp(() {
      service = MyService();
    });

    test('does something', () {
      expect(service.doSomething(), equals(expected));
    });
  });
}
```

## CI/CD

Tests run automatically on:
- Push to `main` or `develop`
- Pull requests

See `.github/workflows/flutter.yml`
