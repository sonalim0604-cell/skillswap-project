import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  Future<String> uploadProfilePicture({
    required String userId,
    required Uint8List bytes,
  }) async {
    final client = Supabase.instance.client;
    final objectPath = '$userId/avatar.jpg';
    await client.storage
        .from('avatars')
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    return client.storage.from('avatars').getPublicUrl(objectPath);
  }
}
