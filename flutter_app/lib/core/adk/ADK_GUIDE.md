# Tackle 4 Loss ADK (App Development Kit)

## The Micro-App Lifecycle

To maintain the high quality of the T4L OS, every new Micro-App must go through the following **8-Step Lifecycle**. 
Strict adherence to this process is mandatory.

### 1. Define the "Why" (Need)
Before writing code, clearly define *why* this app is needed.
- What user problem does it solve?
- Why does it belong in T4L OS?

### 2. Define the "How" (Functionality)
Describe the user experience and feature set.
- User Stories?
- Key Interactions?
- *Note: This is functional only. Technical implementation details come next.*

### 3. Develop (MVC Structure)
Implement the app using the strict **MVC** pattern and **ADK Components**.
- **Directory**: `lib/micro_apps/<id>/` (models/, views/, controllers/)
- **Model**: Pure Data & Logic.
- **View**: UI using `T4LScaffold` & `design_tokens.dart`.
- **Controller**: State Management (`ChangeNotifier`).

### 4. Write Tests
Test Driven Development (TDD) is encouraged. At minimum, critical paths must be tested.
- Unit tests for Models/Controllers.
- Widget tests for Views.

### 5. Pass All Tests
Ensure `flutter test` passes 100%.

### 6. Documentation (`README.md`)
Create a `README.md` within your app's directory (`lib/micro_apps/<id>/README.md`).
- Explain **Why** (from Step 1).
- Explain **How** (from Step 2).
- Document technical decisions.

### 7. Request Publication (The Pull Request)
Once the app is ready and tested:
1.  Create a **GitHub Pull Request (PR)**.
2.  Title: `[PUBLISH] <App Name> (<App ID>)`.
3.  Description: Paste the contents of your `publication.md`.
4.  Certify that all ADK Standards are met.

### 8. Review & Publish
The Core Team reviews the PR using the strict criteria:
-   **Structure**: Is MVC followed?
-   **Visuals**: Are Design Tokens used?
-   **Quality**: Do tests pass?
-   **Integration**: Is it registered in `AppRegistry`?

**Approval**: Once approved and merged, the app is considered "Published" to the OS.

---

## ADK Checklist

Copy this checklist into your `task.md` or creation ticket.

- [ ] **1. Definition**
    - [ ] Defined the User Need (Why)
    - [ ] Defined the Functionality (How)
- [ ] **2. Development**
    - [ ] Created Directory Structure (`models`, `views`, `controllers`)
    - [ ] Implemented MVC Pattern
    - [ ] Used `T4LScaffold` & `DesignTokens`
- [ ] **3. Quality Assurance**
    - [ ] Wrote Tests
    - [ ] Passed All Tests
- [ ] **4. Documentation**
    - [ ] Created `README.md`
    - [ ] Created `publication.md`
- [ ] **5. Publication**
    - [ ] Created GitHub PR with `publication.md` content
    - [ ] Code Review Passed (MVC & Tokens Verified)
    - [ ] Merged & Registered in `AppRegistry`

---

## Technical Standards

### The Contract (Integration)
Every app must implement `MicroApp`:
```dart
abstract class MicroApp {
  String get id;             // Unique ID
  String get name;           // Display Name
  IconData get icon;         // Standard Icon (Fallback)
  String get iconAssetPath;  // Mandatory: Path to 'lib/micro_apps/<id>/store_assets/<id>_icon.png'
  Color get themeColor;      // Brand color
  
  // Store Assets (Mandatory)
  String get storeImageAsset;   // Path to 'lib/micro_apps/<id>/store_assets/image.png'
  String get descriptionAsset;  // Path to 'lib/micro_apps/<id>/store_assets/description.md'

  WidgetBuilder get page;    // The Entry Point Widget
}
```

### Store Assets (Mandatory)
Every app must have a `store_assets` folder containing:
1.  **Icon**: `<app_id>_icon.png` (Square branding icon).
    *   Path: `lib/micro_apps/<id>/store_assets/<id>_icon.png`
2.  **Image**: A 16:9 high-quality branding image.
3.  **Description**: A `description.md` file explaining the app.
4.  **Registration**: Must be added to `pubspec.yaml` assets.

### The Scaffolding (Container)
Wrap your entry point in [T4LScaffold](flutter_app/lib/core/os_shell/widgets/t4l_scaffold.dart).
```dart
return T4LScaffold(
  body: YourMvcView(),
);
```

### The Look (Design Tokens)
**Forbidden**: Hardcoded colors.
**Mandatory**: Use `AppColors` and `TextStyles` from `design_tokens.dart`.
