import 'package:firebase_core/firebase_core.dart';

/// Initializes Firebase when project-specific options are available.
/// TODO: Add generated `firebase_options.dart` and call this from `main.dart`.
Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
}
