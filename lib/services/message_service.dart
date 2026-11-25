import 'package:supabase_flutter/supabase_flutter.dart';

class MessageService {
  Future<List<Map<String, dynamic>>> fetchHistory(String requestId) async {
    final rows = await Supabase.instance.client
        .from('messages')
        .select()
        .eq('swap_request_id', requestId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  Stream<List<Map<String, dynamic>>> watchMessages(String requestId) {
    return Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('swap_request_id', requestId)
        .order('created_at');
  }

  Future<void> sendMessage({
    required String requestId,
    required String userId,
    required String text,
  }) async {
    await Supabase.instance.client.from('messages').insert({
      'swap_request_id': requestId,
      'sender_id': userId,
      'message_text': text,
    });
  }

  Future<List<Map<String, dynamic>>> fetchConversationMessages() async {
    final rows = await Supabase.instance.client
        .from('messages')
        .select('swap_request_id, sender_id, message_text, created_at')
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> fetchRequests(
    List<String> requestIds,
  ) async {
    final rows = await Supabase.instance.client
        .from('swap_requests')
        .select('id, requester_id, recipient_id')
        .inFilter('id', requestIds);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> fetchProfiles(
    List<String> profileIds,
  ) async {
    if (profileIds.isEmpty) return [];
    final rows = await Supabase.instance.client
        .from('profiles')
        .select('id, full_name, username')
        .inFilter('id', profileIds);
    return List<Map<String, dynamic>>.from(rows);
  }
}
