import 'package:supabase_flutter/supabase_flutter.dart';

class SkillService {
  Future<List<Map<String, dynamic>>> fetchUserSkills(String userId) async {
    final rows = await Supabase.instance.client
        .from('user_skills')
        .select('skill_id, skill_type, skills(skill_name)')
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<int> addSkill({
    required String userId,
    required String skillName,
    required String skillType,
    int? knownSkillId,
  }) async {
    final client = Supabase.instance.client;
    var skillId = knownSkillId;
    if (skillId == null) {
      var row = await client
          .from('skills')
          .select('id')
          .ilike('skill_name', skillName)
          .maybeSingle();
      row ??= await client
          .from('skills')
          .insert({'skill_name': skillName})
          .select('id')
          .single();
      skillId = row['id'] as int;
    }

    final existing = await client
        .from('user_skills')
        .select('id')
        .eq('user_id', userId)
        .eq('skill_id', skillId)
        .eq('skill_type', skillType)
        .maybeSingle();
    if (existing == null) {
      await client.from('user_skills').insert({
        'user_id': userId,
        'skill_id': skillId,
        'skill_type': skillType,
      });
    }
    return skillId;
  }

  Future<void> removeSkill({
    required String userId,
    required String skillName,
    required String skillType,
    int? knownSkillId,
  }) async {
    final client = Supabase.instance.client;
    var skillId = knownSkillId;
    if (skillId == null) {
      final row = await client
          .from('skills')
          .select('id')
          .ilike('skill_name', skillName)
          .maybeSingle();
      skillId = row?['id'] as int?;
    }
    if (skillId == null) return;
    await client
        .from('user_skills')
        .delete()
        .eq('user_id', userId)
        .eq('skill_id', skillId)
        .eq('skill_type', skillType);
  }
}
