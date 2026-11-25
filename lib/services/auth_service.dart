import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      throw AuthServiceException(error.code, error.message);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return response.user != null;
    } on AuthException catch (error) {
      throw AuthServiceException(error.code, error.message);
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.code, this.message);

  final String? code;
  final String message;
}
