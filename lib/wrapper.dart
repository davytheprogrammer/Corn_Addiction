// wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:corn_addiction/app.dart';
import 'package:corn_addiction/screens/authentication/authenticate.dart';
import 'package:corn_addiction/providers/auth_provider.dart';

class Wrapper extends ConsumerWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: authState.when(
        data: (user) => user == null ? const Authenticate() : const App(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Authentication Error')),
      ),
    );
  }
}
