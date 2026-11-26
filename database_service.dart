// Platform-specific local persistence: SQLite on Android/iOS/desktop, browser
// local storage on Flutter Web (GitHub Pages).
export 'database_service_native.dart'
    if (dart.library.html) 'database_service_web.dart';
