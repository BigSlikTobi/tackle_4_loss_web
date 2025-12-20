# Project Manifesto

## 1. Vision & Philosophy
**"Mobile First, Emotionally Designed."**

We are building a premium experience that captivates users. The codebase is not just a prototype; it is a scalable, professional product.

- **Mobile First**: All features are conceived, designed, and developed with the mobile experience as the primary driver. The web experience is a first-class citizen but follows the mobile-first mental model.
- **Emotional Design**: Functionality is not enough. Every interaction must feel "alive." We design for delight. We strictly follow the defined design patterns and strive for a "wow" factor in every feature.
- **Simultaneous Delivery**: We function as a single team building two heads of the same beast. Features are implemented simultaneously for:
  - **Flutter** (iOS & Android)
  - **React** (Web)

## 2. Architecture Principles
We adhere to a strict **MVC (Model-View-Controller)** architecture to ensure scalability and maintainability.

### The Rules of MVC
1.  **Clear Separation of Concerns**:
    - **Model**: Data logic, state, and business rules. Pure and testable.
    - **View**: UI rendering only. Dumb components that reflect state.
    - **Controller**: The glue. Handles user input and orchestrates flow between Model and View.
2.  **No Fat Controllers**: Controllers must be lean. They delegate, they do not hoard logic. Complex business logic belongs in Services or Models, not Controllers.
3.  **Self-Contained & Reusable**:
    - Each MVC slice should be as self-contained as possible.
    - Minimal external dependencies.
    - Designed for reusability across the feature set.

## 3. Technology Stack
- **Mobile**: Flutter (Dart)
- **Web**: React (TypeScript / Vite)
- **Backend/Services**: Supabase (Edge Functions, Database)

## 4. Quality Standards
- **No "Prototyping" Code**: We write production-ready, clean code from day one.
- **Strict Typing**: No `any` (TS) or `dynamic` (Dart) where strict types can exist.
- **Design Tokens**: All styling must use the central `design-tokens` (TS) and `design_tokens.dart`. Hardcoded values are forbidden.
