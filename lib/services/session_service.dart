import 'package:supabase_flutter/supabase_flutter.dart';

class SessionData {
  const SessionData({
    required this.sessionRows,
    required this.requestById,
    required this.profileById,
  });

  final List<Map<String, dynamic>> sessionRows;
  final Map<String, Map<String, dynamic>> requestById;
  final Map<String, Map<String, dynamic>> profileById;
}

class SessionService {
  Future<SessionData> fetchSessions() async {
    final client = Supabase.instance.client;
    final sessionRows = List<Map<String, dynamic>>.from(
      await client
          .from('sessions')
          .select(
            'id, swap_request_id, partner_id, skill, scheduled_at, '
            'duration_minutes, mode, place, note, status',
          ),
    );
    if (sessionRows.isEmpty) {
      return const SessionData(
        sessionRows: [],
        requestById: {},
        profileById: {},
      );
    }

    final requestIds = sessionRows
        .map((row) => row['swap_request_id'].toString())
        .toSet()
        .toList();
    final requestRows = List<Map<String, dynamic>>.from(
      await client
          .from('swap_requests')
          .select('id, requester_id, recipient_id')
          .inFilter('id', requestIds),
    );
    final requestById = {
      for (final row in requestRows) row['id'].toString(): row,
    };
    final partnerIds = sessionRows
        .map((row) => row['partner_id'].toString())
        .toSet()
        .toList();
    final profiles = partnerIds.isEmpty
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(
            await client
                .from('profiles')
                .select('id, full_name, username')
                .inFilter('id', partnerIds),
          );
    final profileById = {for (final row in profiles) row['id'].toString(): row};
    return SessionData(
      sessionRows: sessionRows,
      requestById: requestById,
      profileById: profileById,
    );
  }

  Future<String?> saveSession({
    required String requestId,
    required String partnerId,
    required String skill,
    required String scheduledAt,
    required int durationMinutes,
    required String mode,
    required String? place,
    required String note,
    required String status,
  }) async {
    final result = await Supabase.instance.client
        .from('sessions')
        .upsert({
          'swap_request_id': requestId,
          'partner_id': partnerId,
          'skill': skill,
          'scheduled_at': scheduledAt,
          'duration_minutes': durationMinutes,
          'mode': mode,
          'place': place,
          'note': note,
          'status': status,
        }, onConflict: 'swap_request_id')
        .select('id')
        .single();
    return result['id']?.toString();
  }
}
