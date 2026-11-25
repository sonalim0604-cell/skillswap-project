class DemoRequest {
  DemoRequest({
    required this.name,
    required this.skill,
    required this.incoming,
    this.status = 'Pending',
    this.requestId,
    this.partnerId,
  });

  final String name;
  final String skill;
  final bool incoming;
  final String? requestId;
  final String? partnerId;
  String status;
}
