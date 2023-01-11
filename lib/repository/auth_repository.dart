import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chatapp/extensions/custom_exception.dart';
import 'package:flutter_chatapp/repository/general_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges; //ユーザ情報を取得する
  Future<void> signInAnonymously(); //ログに残す
  User? getCurrentUser(); //現在サインインしているユーザ
  Future<void> signOut(); //サインアウト
}

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref));

class AuthRepository implements BaseAuthRepository {
  final Ref _read; //データの取得＆更新よう　元がReaderなどで若干変わるかも?

  const AuthRepository(this._read);

  @override
  Stream<User?> get authStateChanges =>
      _read.read(firebaseAuthProvider).authStateChanges();

  @override
  Future<void> signInAnonymously() async {
    try {
      await _read.read(firebaseAuthProvider).signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  User? getCurrentUser() {
    try {
      return _read.read(firebaseAuthProvider).currentUser;
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _read.read(firebaseAuthProvider).signOut();
      await signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}
