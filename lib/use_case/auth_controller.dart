import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repository/auth_repository.dart';

class AuthController extends StateNotifier<User?> {
  final Ref _read;
  StreamSubscription<User?>? _authStateChangesSubscription;
  AuthController(this._read) : super(null) {
    _authStateChangesSubscription?.cancel();
    _authStateChangesSubscription = _read
        .read(authRepositoryProvider)
        .authStateChanges
        .listen((user) => state = user);
  }

  @override
  void dispose() {
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }

  void appStarted() async {
    final user = _read.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      await _read.read(authRepositoryProvider).signInAnonymously();
    }
  }

  void signOut() async {
    await _read.read(authRepositoryProvider).signOut();
  }
}
