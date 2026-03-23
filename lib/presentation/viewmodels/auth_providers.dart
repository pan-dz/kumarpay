import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple auth state for demo purposes.
final isLoggedInProvider = StateProvider<bool>((ref) => false);
