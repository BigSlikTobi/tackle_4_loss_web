import 'package:flutter/material.dart';
import 'app_category.dart';

/// The contract that all feature apps must implement.
/// This allows the Core OS to behave like an App Store/Launcher.
abstract class MicroApp {
  /// Unique identifier for the app (e.g., 'deep_dive', 'news').
  String get id;

  /// Display name of the app.
  String get name;

  /// Short description of the app (1-2 sentences for App Hub display).
  String get description;

  /// Category for organizing apps in the App Hub.
  AppCategory get category;

  /// Whether this app should appear on the home page by default.
  /// If false, app is only accessible via App Hub.
  bool get showOnHomePage => false;

  /// The official icon for the app (displayed in App Store & OS Shell).
  IconData get icon;

  /// Mandatory: Path to an image asset to use as the icon.
  // ignore: unintended_html_in_doc_comment
  /// Convention: 'lib/micro_apps/<id>/store_assets/<id>_icon.png'
  String get iconAssetPath;

  /// The primary theme color for the app icon and branding.
  Color get themeColor;

  /// Path to the 16:9 App Store image asset (e.g., 'lib/micro_apps/x/store_assets/image.png').
  String get storeImageAsset;

  /// Path to the Markdown description asset (e.g., 'lib/micro_apps/x/store_assets/description.md').
  String get descriptionAsset;

  /// The entry point widget for this app.
  WidgetBuilder get page;

  /// Whether this app has a home screen widget.
  bool get hasWidget => false;

  /// The size of the widget in grid cells (e.g. 1x1, 1x2, 2x2).
  /// Defaults to 1x1 (Standard Icon).
  Size get widgetSize => const Size(1, 1);

  /// The widget builder for the home screen widget.
  /// Returns a SizedBox by default.
  WidgetBuilder get widgetBuilder =>
      (context) => const SizedBox();

  /// Builds the app's main page, optionally accepting arguments.
  /// Defaults to calling [page].
  Widget buildPage(BuildContext context, {Object? arguments}) {
    return page(context);
  }
}

