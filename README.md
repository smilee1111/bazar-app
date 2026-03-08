# Bazar App

Bazar is a Flutter mobile marketplace/discovery app that helps users find and
explore local shops, view public shop details and reviews, and manage personal
shop interactions like favourites and saved shops.

The app also includes seller-facing flows for shop management, customer-facing
notifications, and location-aware discovery such as nearest shops by category.

## Core Features

- Browse public shop feed with search and filter options
- Find nearest shops by selected category using device location
- View shop details, reviews, and related content
- Save shops and mark favourites
- Manage notifications and unread status
- Seller shop management and edit flows
- Pull-to-refresh and paginated feed loading

## Tech Stack

- Flutter (Dart)
- Riverpod for state management
- REST API integration for shop/feed data
- Android and iOS project targets

## Project Structure

- `lib/app/`: app-level setup (theme, shared config)
- `lib/core/`: shared services, utilities, and API base logic
- `lib/features/`: feature modules (dashboard, shop, notification, favourite,
  saved shops, seller flows, etc.)
- `test/`: feature-level tests

## Getting Started

1. Install Flutter SDK and verify setup:
	- `flutter doctor`
2. Get dependencies:
	- `flutter pub get`
3. Run the app:
	- `flutter run`

## Notes

- Generated directories like `build/` and `.dart_tool/` are cache/build
  artifacts and are recreated automatically.
- Refer to the docs in the repository root for detailed implementation notes,
  architecture references, and setup guides.
