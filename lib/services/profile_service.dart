import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    return await Supabase.instance.client
        .from('profiles')
        .select('full_name, avatar_url')
        .eq('id', userId)
        .maybeSingle();
  }

  Future<void> updateAvatarUrl(String userId, String avatarUrl) async {
    await Supabase.instance.client
        .from('profiles')
        .update({'avatar_url': avatarUrl})
        .eq('id', userId);
  }
}
