enum SessionStatus { upcoming, completed, cancelled }

enum ExchangeDirection { taught, learned }

enum SessionMode { inPerson, video }

class DemoSession {
  DemoSession({
    required this.id,
    required this.partner,
    required this.skill,
    required this.date,
    required this.status,
    required this.direction,
    this.time = '2:00 PM',
    this.place = 'Library study lounge',
    this.mode = SessionMode.inPerson,
    this.note = '',
    this.durationMinutes = 60,
    this.isScheduled = true,
    this.swapRequestId,
    this.partnerId,
    this.databaseId,
  });

  final String id;
  final String partner;
  final String skill;
  String date;
  String time;
  String place;
  SessionMode mode;
  String note;
  int durationMinutes;
  bool isScheduled;
  final String? swapRequestId;
  final String? partnerId;
  String? databaseId;
  SessionStatus status;
  final ExchangeDirection direction;

  String get meetingLink => 'https://meet.jit.si/SkillSwap-${databaseId ?? id}';
}
