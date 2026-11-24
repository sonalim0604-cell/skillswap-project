import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'supabase_config.dart';

const ink = Color(0xFF252447);
const purple = Color(0xFF4F35F5);
const blue = Color(0xFF2868E8);
const lavender = Color(0xFFF2F0FF);
const page = Color(0xFFF7F7FC);
const muted = Color(0xFF777990);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const SkillSwapApp());
}

class SkillSwapApp extends StatefulWidget {
  const SkillSwapApp({super.key});

  @override
  State<SkillSwapApp> createState() => _SkillSwapAppState();
}

class _SkillSwapAppState extends State<SkillSwapApp> {
  final app = DemoState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillSwap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: page,
        colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: purple,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F7FB),
          hintStyle: const TextStyle(color: Color(0xFF9A9AAD), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Color(0xFFECECF4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: purple, width: 1.4),
          ),
        ),
      ),
      home: LoginPage(app: app),
    );
  }
}

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

class DemoRating {
  DemoRating({
    required this.sessionId,
    required this.partner,
    required this.skill,
    required this.stars,
    required this.review,
    required this.date,
  });
  final String sessionId;
  final String partner;
  final String skill;
  final int stars;
  final String review;
  final String date;
}

class DemoState extends ChangeNotifier {
  String name = 'Maya Kapoor';
  String college = 'Northview College';
  String? avatarUrl;
  String bio =
      'Curious learner who loves sharing ideas and building new skills.';
  final teachingSkills = <String>['Python', 'UI/UX Design'];
  final learningSkills = <String>['Public Speaking', 'Photography'];
  final skillIds = <String, int>{};
  final sessions = <DemoSession>[
    DemoSession(
      id: 's1',
      partner: 'Isha Patel',
      skill: 'Python basics',
      date: 'Nov 12, 2026',
      status: SessionStatus.completed,
      direction: ExchangeDirection.taught,
      time: '10:30 AM',
    ),
    DemoSession(
      id: 's2',
      partner: 'Ananya Sharma',
      skill: 'Graphic Design',
      date: 'Nov 8, 2026',
      status: SessionStatus.completed,
      direction: ExchangeDirection.learned,
      time: '1:00 PM',
    ),
    DemoSession(
      id: 's3',
      partner: 'Rahul Mehta',
      skill: 'Java fundamentals',
      date: 'Nov 4, 2026',
      status: SessionStatus.completed,
      direction: ExchangeDirection.taught,
      time: '3:30 PM',
    ),
    DemoSession(
      id: 's4',
      partner: 'Rohan Desai',
      skill: 'Photography',
      date: 'Nov 18, 2026',
      status: SessionStatus.upcoming,
      direction: ExchangeDirection.learned,
      time: '2:00 PM',
    ),
    DemoSession(
      id: 's5',
      partner: 'Priya Shah',
      skill: 'Web Development',
      date: 'Nov 20, 2026',
      status: SessionStatus.upcoming,
      direction: ExchangeDirection.taught,
      time: '11:00 AM',
    ),
    DemoSession(
      id: 's6',
      partner: 'Neha Verma',
      skill: 'Public Speaking',
      date: 'Oct 28, 2026',
      status: SessionStatus.cancelled,
      direction: ExchangeDirection.learned,
      time: '4:00 PM',
    ),
  ];
  final requests = <DemoRequest>[
    DemoRequest(name: 'Priya Shah', skill: 'Web Development', incoming: true),
    DemoRequest(name: 'Neha Verma', skill: 'Public Speaking', incoming: true),
    DemoRequest(name: 'Rohan Desai', skill: 'Photography', incoming: false),
  ];
  final ratings = <DemoRating>[
    DemoRating(
      sessionId: 'sample-1',
      partner: 'Ananya Sharma',
      skill: 'Graphic Design',
      stars: 5,
      review: 'A thoughtful and encouraging exchange. I learned so much!',
      date: 'Nov 8',
    ),
    DemoRating(
      sessionId: 'sample-2',
      partner: 'Rahul Mehta',
      skill: 'Java fundamentals',
      stars: 4,
      review: 'Clear explanations and a really helpful session.',
      date: 'Nov 4',
    ),
  ];
  final sentTo = <String>{};

  int get completedCount =>
      sessions.where((s) => s.status == SessionStatus.completed).length;
  double get completedHours =>
      sessions
          .where((session) => session.status == SessionStatus.completed)
          .fold<int>(0, (total, session) => total + session.durationMinutes) /
      60;
  int get taughtCount => sessions
      .where(
        (s) =>
            s.status == SessionStatus.completed &&
            s.direction == ExchangeDirection.taught,
      )
      .length;
  int get learnedCount => sessions
      .where(
        (s) =>
            s.status == SessionStatus.completed &&
            s.direction == ExchangeDirection.learned,
      )
      .length;
  double get averageRating => ratings.isEmpty
      ? 0
      : ratings.fold<int>(0, (sum, r) => sum + r.stars) / ratings.length;
  bool isRated(String id) => ratings.any((rating) => rating.sessionId == id);

  void updateProfile({
    required String newName,
    required String newCollege,
    required String newBio,
  }) {
    name = newName.trim();
    college = newCollege.trim();
    bio = newBio.trim();
    notifyListeners();
  }

  void updateAvatarUrl(String value) {
    avatarUrl = value;
    notifyListeners();
  }

  Future<void> loadSkills(BuildContext context) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final rows = await Supabase.instance.client
          .from('user_skills')
          .select('skill_id, skill_type, skills(skill_name)')
          .eq('user_id', userId);
      if (!context.mounted) return;
      final teach = <String>[];
      final learn = <String>[];
      final loadedSkillIds = <String, int>{};
      for (final row in List<Map<String, dynamic>>.from(rows)) {
        final skillRow = row['skills'] as Map<String, dynamic>?;
        final skillName = skillRow?['skill_name']?.toString().trim() ?? '';
        if (skillName.isEmpty) continue;
        final skillId = row['skill_id'];
        if (skillId is int) loadedSkillIds[skillName.toLowerCase()] = skillId;
        switch (row['skill_type']) {
          case 'teach':
            teach.add(skillName);
          case 'learn':
            learn.add(skillName);
        }
      }
      teachingSkills
        ..clear()
        ..addAll(teach);
      learningSkills
        ..clear()
        ..addAll(learn);
      skillIds
        ..clear()
        ..addAll(loadedSkillIds);
      notifyListeners();
    } catch (error) {
      if (context.mounted) {
        showMessage(context, 'Could not load your saved skills: $error');
      }
    }
  }

  Future<void> loadUserProfile(BuildContext context) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', userId)
          .maybeSingle();
      if (!context.mounted || profile == null) return;
      final fullName = profile['full_name']?.toString().trim() ?? '';
      name = fullName.isEmpty ? name : fullName;
      avatarUrl = profile['avatar_url']?.toString();
      notifyListeners();
    } catch (error) {
      if (context.mounted) {
        showMessage(context, 'Could not load your profile photo: $error');
      }
    }
  }

  void addSkill(String skill, bool teach) {
    final list = teach ? teachingSkills : learningSkills;
    if (skill.trim().isNotEmpty &&
        !list.any((item) => item.toLowerCase() == skill.trim().toLowerCase())) {
      list.add(skill.trim());
      notifyListeners();
    }
  }

  void removeSkill(String skill, bool teach) {
    (teach ? teachingSkills : learningSkills).remove(skill);
    notifyListeners();
  }

  void addRating(DemoRating rating) {
    if (isRated(rating.sessionId)) return;
    ratings.insert(0, rating);
    notifyListeners();
  }

  Future<void> loadSessions(BuildContext context) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final sessionRows = List<Map<String, dynamic>>.from(
        await Supabase.instance.client
            .from('sessions')
            .select(
              'id, swap_request_id, partner_id, skill, scheduled_at, '
              'duration_minutes, mode, place, note, status',
            ),
      );
      if (sessionRows.isEmpty) return;
      final requestIds = sessionRows
          .map((row) => row['swap_request_id'].toString())
          .toSet()
          .toList();
      final requestRows = List<Map<String, dynamic>>.from(
        await Supabase.instance.client
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
              await Supabase.instance.client
                  .from('profiles')
                  .select('id, full_name, username')
                  .inFilter('id', partnerIds),
            );
      final profileById = {
        for (final row in profiles) row['id'].toString(): row,
      };
      if (!context.mounted) return;
      for (final row in sessionRows) {
        final requestId = row['swap_request_id'].toString();
        final request = requestById[requestId];
        final partnerId = row['partner_id']?.toString();
        final profile = partnerId == null ? null : profileById[partnerId];
        final fullName = profile?['full_name']?.toString().trim() ?? '';
        final username = profile?['username']?.toString().trim() ?? '';
        final scheduledAt =
            DateTime.tryParse(row['scheduled_at']?.toString() ?? '') ??
            DateTime.now();
        final status = switch (row['status']) {
          'completed' => SessionStatus.completed,
          'cancelled' => SessionStatus.cancelled,
          _ => SessionStatus.upcoming,
        };
        var session = sessions.cast<DemoSession?>().firstWhere(
          (existing) => existing?.swapRequestId == requestId,
          orElse: () => null,
        );
        if (session == null) {
          session = DemoSession(
            id: row['id'].toString(),
            partner: fullName.isNotEmpty
                ? fullName
                : username.isNotEmpty
                ? username
                : 'SkillSwap student',
            skill: row['skill']?.toString() ?? 'Skill exchange',
            date: _formatSessionDate(scheduledAt.toLocal()),
            time: _formatTimeOfDay(
              TimeOfDay.fromDateTime(scheduledAt.toLocal()),
            ),
            place: row['place']?.toString() ?? '',
            mode: row['mode'] == 'video'
                ? SessionMode.video
                : SessionMode.inPerson,
            note: row['note']?.toString() ?? '',
            durationMinutes: row['duration_minutes'] as int? ?? 60,
            status: status,
            direction: request?['requester_id']?.toString() == userId
                ? ExchangeDirection.taught
                : ExchangeDirection.learned,
            swapRequestId: requestId,
            partnerId: partnerId,
          );
          sessions.add(session);
        }
        session
          ..date = _formatSessionDate(scheduledAt.toLocal())
          ..time = _formatTimeOfDay(
            TimeOfDay.fromDateTime(scheduledAt.toLocal()),
          )
          ..place = row['place']?.toString() ?? ''
          ..mode = row['mode'] == 'video'
              ? SessionMode.video
              : SessionMode.inPerson
          ..note = row['note']?.toString() ?? ''
          ..status = status
          ..databaseId = row['id'].toString();
      }
      notifyListeners();
    } catch (error) {
      if (context.mounted) {
        showMessage(context, 'Could not load scheduled sessions: $error');
      }
    }
  }

  Future<void> persistSession(BuildContext context, DemoSession session) async {
    final requestId = session.swapRequestId;
    final partnerId = session.partnerId;
    if (requestId == null || partnerId == null) return;
    final scheduledAt = _parseSessionDate(session.date);
    if (scheduledAt == null) return;
    final time = _parseTimeOfDay(session.time);
    final dateTime = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
      time.hour,
      time.minute,
    );
    try {
      final result = await Supabase.instance.client
          .from('sessions')
          .upsert({
            'swap_request_id': requestId,
            'partner_id': partnerId,
            'skill': session.skill,
            'scheduled_at': dateTime.toUtc().toIso8601String(),
            'duration_minutes': session.durationMinutes,
            'mode': session.mode == SessionMode.video ? 'video' : 'in_person',
            'place': session.mode == SessionMode.video ? null : session.place,
            'note': session.note,
            'status': _sessionStatusValue(session.status),
          }, onConflict: 'swap_request_id')
          .select('id')
          .single();
      if (!context.mounted) return;
      session.databaseId = result['id']?.toString();
    } catch (error) {
      if (context.mounted) {
        showMessage(context, 'Session saved on this device only: $error');
      }
    }
  }

  void updateSessionSchedule(
    DemoSession session, {
    required DateTime date,
    required TimeOfDay time,
    required SessionMode mode,
    required String place,
    required String note,
  }) {
    session.date = _formatSessionDate(date);
    session.time = _formatTimeOfDay(time);
    session.mode = mode;
    session.place = place;
    session.note = note;
    session.isScheduled = true;
    notifyListeners();
  }

  void updateSessionStatus(DemoSession session, SessionStatus status) {
    session.status = status;
    notifyListeners();
  }

  void updateRequestStatus(DemoRequest request, String status) {
    request.status = status;
    notifyListeners();
  }

  void addRequest(DemoRequest request) {
    sentTo.add(request.name);
    requests.insert(0, request);
    notifyListeners();
  }

  DemoSession addSessionForRequest(DemoRequest request) {
    final session = DemoSession(
      id:
          request.requestId ??
          'session-${DateTime.now().microsecondsSinceEpoch}',
      partner: request.name,
      skill: request.skill,
      date: _formatSessionDate(DateTime.now()),
      status: SessionStatus.upcoming,
      direction: request.incoming
          ? ExchangeDirection.taught
          : ExchangeDirection.learned,
      place: '',
      isScheduled: false,
      swapRequestId: request.requestId,
      partnerId: request.partnerId,
    );
    sessions.insert(0, session);
    notifyListeners();
    return session;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.app, this.initialEmail = ''});
  final DemoState app;
  final String initialEmail;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>();
  late final email = TextEditingController(text: widget.initialEmail);
  final password = TextEditingController();
  bool hidePassword = true;
  bool signingIn = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!form.currentState!.validate() || signingIn) return;
    setState(() => signingIn = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MainShell(app: widget.app)),
        (_) => false,
      );
    } on AuthException catch (error) {
      if (mounted) showMessage(context, 'Sign in failed: ${error.message}');
    } catch (error) {
      if (mounted) showMessage(context, 'Unable to sign in: $error');
    } finally {
      if (mounted) setState(() => signingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: 'Welcome back',
    subtitle: 'Your next skill exchange starts here.',
    children: [
      Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Good to see you again',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Log in to teach, learn and connect.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const SizedBox(height: 22),
            const FieldLabel('Email'),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email address',
              ),
              validator: (v) => v == null || !v.contains('@')
                  ? 'Enter a valid email address.'
                  : null,
            ),
            const SizedBox(height: 15),
            const FieldLabel('Password'),
            TextFormField(
              controller: password,
              obscureText: hidePassword,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                  ),
                ),
              ),
              validator: (v) => v == null || v.length < 6
                  ? 'Password must be at least 6 characters.'
                  : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showMessage(
                  context,
                  'Password reset is not available yet.',
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            SizedBox(
              height: 46,
              child: FilledButton(
                onPressed: signingIn ? null : login,
                style: FilledButton.styleFrom(backgroundColor: purple),
                child: signingIn
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignUpPage(app: widget.app),
                  ),
                ),
                child: const Text('New to SkillSwap?  Sign Up'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const InfoNote(
        icon: Icons.lightbulb_outline,
        title: 'A little knowledge goes a long way.',
        detail: 'Find your people. Share your skills. Grow together.',
      ),
    ],
  );
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.app});
  final DemoState app;
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool hide = true;
  bool creatingAccount = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!form.currentState!.validate() || creatingAccount) return;
    setState(() => creatingAccount = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.text.trim(),
        password: password.text,
        data: {'full_name': name.text.trim()},
      );

      if (response.user == null) {
        throw Exception('Account creation failed.');
      }

      if (!mounted) return;

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Account created!'),
          content: const Text(
            'Your SkillSwap account has been created successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Continue to login'),
            ),
          ],
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      if (error.code == 'user_already_exists') {
        showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Account already exists'),
            content: const Text(
              'This email is already registered. Sign in with your existing password instead.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Stay here'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginPage(
                        app: widget.app,
                        initialEmail: email.text.trim(),
                      ),
                    ),
                  );
                },
                child: const Text('Go to login'),
              ),
            ],
          ),
        );
      } else {
        showMessage(context, 'Could not create account: ${error.message}');
      }
    } catch (error) {
      if (mounted) showMessage(context, 'Could not create account: $error');
    } finally {
      if (mounted) setState(() => creatingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: 'Join SkillSwap',
    subtitle: 'Learn something new. Share what you know.',
    children: [
      Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create your account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 18),
            const FieldLabel('Full name'),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(
                hintText: 'Enter your full name',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter your name.'
                  : null,
            ),
            const SizedBox(height: 12),
            const FieldLabel('Email'),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email address',
              ),
              validator: (v) => v == null || !v.contains('@')
                  ? 'Enter a valid email address.'
                  : null,
            ),
            const SizedBox(height: 12),
            const FieldLabel('Password'),
            TextFormField(
              controller: password,
              obscureText: hide,
              decoration: InputDecoration(
                hintText: 'Create a password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => hide = !hide),
                  icon: const Icon(Icons.visibility_outlined, size: 19),
                ),
              ),
              validator: (v) => v == null || v.length < 8
                  ? 'Use at least 8 characters.'
                  : null,
            ),
            const SizedBox(height: 12),
            const FieldLabel('Confirm password'),
            TextFormField(
              controller: confirm,
              obscureText: hide,
              decoration: const InputDecoration(
                hintText: 'Re-enter your password',
              ),
              validator: (v) =>
                  v != password.text ? 'Passwords do not match.' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 46,
              child: FilledButton(
                onPressed: creatingAccount ? null : signUp,
                style: FilledButton.styleFrom(backgroundColor: purple),
                child: creatingAccount
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already part of SkillSwap?  Login'),
              ),
            ),
          ],
        ),
      ),
      const InfoNote(
        icon: Icons.mark_email_read_outlined,
        title: 'Your skills, your community.',
        detail: 'Create a profile and find a learning partner on campus.',
      ),
    ],
  );
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final String title;
  final String subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        AuthHeader(title: title, subtitle: subtitle),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            children: [
              CardSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(
      22,
      MediaQuery.paddingOf(context).top + 17,
      22,
      24,
    ),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF6248FF), Color(0xFF4026E9)]),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 25),
            const SizedBox(width: 8),
            const Text(
              'SkillSwap',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () =>
                  showMessage(context, 'Learn. Teach. Grow together.'),
              icon: const Icon(Icons.star_outline, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFFE0DCFF)),
        ),
      ],
    ),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.app});
  final DemoState app;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selected = 0;
  static const passportIndex = 4;
  late final pages = <Widget>[
    MatchesPage(app: widget.app, onOpenPassport: openPassport),
    RequestsPage(app: widget.app),
    SessionsPage(app: widget.app, onOpenPassport: openPassport),
    SkillsPage(app: widget.app, onOpenPassport: openPassport),
    PassportPage(app: widget.app, isTab: true),
    ProfilePage(app: widget.app, onOpenPassport: openPassport),
  ];
  static const navItems = [
    (Icons.people_alt_outlined, 'Matches'),
    (Icons.mail_outline, 'Requests'),
    (Icons.calendar_month_outlined, 'Sessions'),
    (Icons.auto_awesome_outlined, 'Skills'),
    (Icons.workspace_premium_outlined, 'Passport'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    unawaited(widget.app.loadSkills(context));
    unawaited(widget.app.loadUserProfile(context));
    unawaited(widget.app.loadSessions(context));
  }

  void openPassport() {
    setState(() => selected = passportIndex);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      top: false,
      child: IndexedStack(index: selected, children: pages),
    ),
    bottomNavigationBar: NavigationBar(
      height: 66,
      selectedIndex: selected,
      onDestinationSelected: (index) => setState(() => selected = index),
      backgroundColor: Colors.white,
      indicatorColor: lavender,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
      ),
      destinations: [
        for (final item in navItems)
          NavigationDestination(
            icon: Icon(item.$1),
            selectedIcon: Icon(item.$1, color: purple),
            label: item.$2,
          ),
      ],
    ),
  );
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
    this.app,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  final DemoState? app;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppHeader(title: title, subtitle: subtitle, trailing: trailing, app: app),
      Expanded(child: child),
    ],
  );
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.app,
  });
  final String title;
  final String subtitle;
  final Widget? trailing;
  final DemoState? app;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(
      19,
      MediaQuery.paddingOf(context).top + 10,
      15,
      17,
    ),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF6047FF), Color(0xFF462DF0)]),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(21)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, size: 21, color: Colors.white),
            const SizedBox(width: 7),
            const Text(
              'SkillSwap',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            if (app != null) ...[
              Avatar(name: app!.name, imageUrl: app!.avatarUrl, radius: 14),
              const SizedBox(width: 4),
            ],
            trailing ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Messages',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MessagesPage()),
                      ),
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => showMessage(
                        context,
                        'Your next great exchange is just around the corner.',
                      ),
                      icon: const Icon(
                        Icons.star_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
          ],
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 23,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFFE3DFFF)),
        ),
      ],
    ),
  );
}

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key, required this.app, this.onOpenPassport});
  final DemoState app;
  final VoidCallback? onOpenPassport;
  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  bool showTeach = true;
  final students = const [
    Student(
      'Isha Patel',
      'Python',
      'UI/UX Design',
      'Learn Python from the basics, or swap design tips.',
      5,
      Icons.code_rounded,
      Color(0xFF6754E8),
    ),
    Student(
      'Ananya Sharma',
      'Graphic Design',
      'Illustration',
      'Creative designer who loves helping beginners.',
      5,
      Icons.brush_outlined,
      Color(0xFFEF7294),
    ),
    Student(
      'Rahul Mehta',
      'Java',
      'Problem Solving',
      'Let’s make coding concepts easy and fun.',
      4,
      Icons.terminal_rounded,
      Color(0xFF3678D8),
    ),
    Student(
      'Priya Shah',
      'Web Development',
      'HTML & CSS',
      'Build your first responsive website with me.',
      5,
      Icons.web_rounded,
      Color(0xFF18A987),
    ),
    Student(
      'Rohan Desai',
      'Photography',
      'Photo Editing',
      'Learn to see the little details in every frame.',
      5,
      Icons.camera_alt_outlined,
      Color(0xFFE8A341),
    ),
    Student(
      'Neha Verma',
      'Public Speaking',
      'Presentation Skills',
      'Find your voice and speak with confidence.',
      4,
      Icons.mic_none_rounded,
      Color(0xFF8A61D5),
    ),
  ];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) => PageFrame(
      app: widget.app,
      title: 'Find Your Match',
      subtitle: 'Meet students who help you grow.',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Can teach me')),
              ButtonSegment(value: false, label: Text('Wants to learn')),
            ],
            selected: {showTeach},
            showSelectedIcon: false,
            onSelectionChanged: (value) =>
                setState(() => showTeach = value.first),
            style: ButtonStyle(
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? purple
                    : Colors.white,
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? Colors.white : ink,
              ),
              side: const WidgetStatePropertyAll(
                BorderSide(color: Color(0xFFE8E6F3)),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          InfoNote(
            icon: Icons.auto_awesome_outlined,
            title: showTeach
                ? 'Find your learning circle'
                : 'Share what you know',
            detail: showTeach
                ? 'Add learning skills to get matched with students who can teach you.'
                : 'Explore students who would love to learn your skills.',
          ),
          const SizedBox(height: 18),
          const SectionTitle('Student matches'),
          const SizedBox(height: 10),
          for (final student in students)
            MatchCard(
              student: student,
              showTeach: showTeach,
              sent: widget.app.sentTo.contains(student.name),
              onProfile: () => showStudentProfile(context, student),
              onRequest: () {
                widget.app.addRequest(
                  DemoRequest(
                    name: student.name,
                    skill: showTeach ? student.teaches : student.learns,
                    incoming: false,
                  ),
                );
                showMessage(
                  context,
                  'Exchange request sent to ${student.name}.',
                );
              },
            ),
        ],
      ),
    ),
  );
}

class Student {
  const Student(
    this.name,
    this.teaches,
    this.learns,
    this.bio,
    this.rating,
    this.icon,
    this.color,
  );
  final String name;
  final String teaches;
  final String learns;
  final String bio;
  final int rating;
  final IconData icon;
  final Color color;
}

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.student,
    required this.showTeach,
    required this.sent,
    required this.onProfile,
    required this.onRequest,
  });
  final Student student;
  final bool showTeach;
  final bool sent;
  final VoidCallback onProfile;
  final VoidCallback onRequest;
  @override
  Widget build(BuildContext context) => CardSurface(
    margin: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Avatar(
              name: student.name,
              color: student.color,
              icon: student.icon,
              radius: 25,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: Color(0xFFF1B638),
                      ),
                      Text(
                        ' ${student.rating}.0  ·  Student',
                        style: const TextStyle(fontSize: 11, color: muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Text('CAN TEACH', style: smallCaption),
        const SizedBox(height: 5),
        SkillPill(student.teaches, color: purple),
        const SizedBox(height: 9),
        Text('WANTS TO LEARN', style: smallCaption),
        const SizedBox(height: 5),
        SkillPill(student.learns, color: blue),
        const SizedBox(height: 13),
        Text(
          student.bio,
          style: const TextStyle(fontSize: 12, height: 1.4, color: muted),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onProfile,
                icon: const Icon(Icons.person_outline, size: 16),
                label: const Text(
                  'View Profile',
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: purple,
                  side: const BorderSide(color: Color(0xFFE3E0FF)),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: sent ? null : onRequest,
                icon: Icon(sent ? Icons.check : Icons.send_outlined, size: 15),
                label: Text(
                  sent ? 'Requested' : 'Send Request',
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: purple,
                  disabledBackgroundColor: const Color(0xFFE8E6F2),
                  disabledForegroundColor: muted,
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => openChat(context, partnerName: student.name),
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Message'),
          ),
        ),
      ],
    ),
  );
}

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key, required this.app});
  final DemoState app;
  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  bool received = true;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.app,
      builder: (context, _) {
        final requests = widget.app.requests
            .where((r) => r.incoming == received)
            .toList();
        return PageFrame(
          app: widget.app,
          title: 'Exchange Requests',
          subtitle: 'Start a conversation. Build a connection.',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Received')),
                  ButtonSegment(value: false, label: Text('Sent')),
                ],
                selected: {received},
                showSelectedIcon: false,
                onSelectionChanged: (v) => setState(() => received = v.first),
                style: ButtonStyle(
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? purple
                        : Colors.white,
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white
                        : ink,
                  ),
                  side: const WidgetStatePropertyAll(
                    BorderSide(color: Color(0xFFE8E6F3)),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InfoNote(
                icon: Icons.inbox_outlined,
                title: requests.isEmpty
                    ? 'Your exchanges start here'
                    : 'Your exchange requests',
                detail: requests.isEmpty
                    ? 'Received and sent requests will appear here when you find a student.'
                    : 'A student would like to exchange skills with you.',
              ),
              const SizedBox(height: 18),
              SectionTitle(received ? 'Received requests' : 'Sent requests'),
              const SizedBox(height: 10),
              if (requests.isEmpty)
                EmptyState(
                  icon: Icons.mark_email_read_outlined,
                  title: 'All caught up!',
                  detail:
                      'There are no ${received ? 'received' : 'sent'} requests right now.',
                ),
              for (final request in requests)
                CardSurface(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Avatar(name: request.name, radius: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: ink,
                                  ),
                                ),
                                Text(
                                  'Skill information: ${request.skill}',
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusPill(
                            request.status,
                            color: request.status == 'Accepted'
                                ? const Color(0xFF168B64)
                                : request.status == 'Rejected' ||
                                      request.status == 'Cancelled'
                                ? const Color(0xFF9B5363)
                                : blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: lavender,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${request.name.split(' ').first} would like to exchange skills with you.',
                          style: const TextStyle(fontSize: 12, color: ink),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              openChat(context, partnerName: request.name),
                          icon: const Icon(Icons.chat_bubble_outline, size: 16),
                          label: const Text('Message'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (request.status == 'Pending')
                        Row(
                          children: [
                            if (received) ...[
                              Expanded(
                                child: FilledButton(
                                  onPressed: () async {
                                    widget.app.updateRequestStatus(
                                      request,
                                      'Accepted',
                                    );
                                    final session = widget.app
                                        .addSessionForRequest(request);
                                    await showSessionScheduler(
                                      context,
                                      widget.app,
                                      session,
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: purple,
                                  ),
                                  child: const Text('Accept'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => widget.app
                                      .updateRequestStatus(request, 'Rejected'),
                                  child: const Text('Reject'),
                                ),
                              ),
                            ] else
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      widget.app.updateRequestStatus(
                                        request,
                                        'Cancelled',
                                      ),
                                  child: const Text('Cancel Request'),
                                ),
                              ),
                          ],
                        )
                      else
                        Text(
                          'Request ${request.status.toLowerCase()}.',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key, required this.app, this.onOpenPassport});
  final DemoState app;
  final VoidCallback? onOpenPassport;
  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  int tab = 0;
  final labels = const ['Upcoming', 'Completed', 'Cancelled'];
  SessionStatus statusFor(int index) => [
    SessionStatus.upcoming,
    SessionStatus.completed,
    SessionStatus.cancelled,
  ][index];
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.app,
      builder: (context, _) {
        final sessions = widget.app.sessions
            .where((s) => s.status == statusFor(tab))
            .toList();
        return PageFrame(
          app: widget.app,
          title: 'My Sessions',
          subtitle: 'Make time to learn, teach and connect.',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              SegmentedButton<int>(
                segments: [
                  for (var i = 0; i < labels.length; i++)
                    ButtonSegment(value: i, label: Text(labels[i])),
                ],
                selected: {tab},
                showSelectedIcon: false,
                onSelectionChanged: (v) => setState(() => tab = v.first),
                style: ButtonStyle(
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? purple
                        : Colors.white,
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white
                        : ink,
                  ),
                  side: const WidgetStatePropertyAll(
                    BorderSide(color: Color(0xFFE8E6F3)),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InfoNote(
                icon: Icons.event_available_outlined,
                title: tab == 0
                    ? 'Make your next exchange happen'
                    : 'Every exchange is part of your journey',
                detail: tab == 0
                    ? 'Your sessions will appear here when you have an exchange scheduled.'
                    : 'Find a session in your history, leave feedback and celebrate your progress.',
              ),
              const SizedBox(height: 18),
              SectionTitle('${labels[tab]} sessions'),
              const SizedBox(height: 10),
              if (sessions.isEmpty)
                EmptyState(
                  icon: Icons.event_note_outlined,
                  title: 'No ${labels[tab].toLowerCase()} sessions yet',
                  detail: 'Your skill exchange journey will show up here.',
                ),
              for (final session in sessions)
                SessionCard(
                  session: session,
                  rated: widget.app.isRated(session.id),
                  onComplete: () {
                    widget.app.updateSessionStatus(
                      session,
                      SessionStatus.completed,
                    );
                    unawaited(widget.app.persistSession(context, session));
                  },
                  onCancel: () {
                    widget.app.updateSessionStatus(
                      session,
                      SessionStatus.cancelled,
                    );
                    unawaited(widget.app.persistSession(context, session));
                  },
                  onSchedule: () =>
                      showSessionScheduler(context, widget.app, session),
                  onCalendar: () => addSessionToCalendar(context, session),
                  onRate: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RatingPage(
                        app: widget.app,
                        session: session,
                        onOpenPassport: widget.onOpenPassport,
                      ),
                    ),
                  ),
                ),
              if (tab == 1)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: OutlinedButton.icon(
                    onPressed: widget.onOpenPassport,
                    icon: const Icon(Icons.workspace_premium_outlined),
                    label: const Text('View My Skill Passport'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.rated,
    required this.onComplete,
    required this.onCancel,
    required this.onRate,
    required this.onSchedule,
    required this.onCalendar,
  });
  final DemoSession session;
  final bool rated;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback onRate;
  final VoidCallback onSchedule;
  final VoidCallback onCalendar;
  @override
  Widget build(BuildContext context) {
    final status = switch (session.status) {
      SessionStatus.upcoming => 'Upcoming',
      SessionStatus.completed => 'Completed',
      SessionStatus.cancelled => 'Cancelled',
    };
    final color = switch (session.status) {
      SessionStatus.upcoming => blue,
      SessionStatus.completed => const Color(0xFF168B64),
      SessionStatus.cancelled => const Color(0xFF9B5363),
    };
    return CardSurface(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(name: session.partner, radius: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.partner,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    Text(
                      session.skill,
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusPill(status, color: color),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 15,
            runSpacing: 7,
            children: [
              LabelIcon(
                icon: Icons.calendar_today_outlined,
                text: session.date,
              ),
              LabelIcon(icon: Icons.access_time, text: session.time),
            ],
          ),
          const SizedBox(height: 7),
          LabelIcon(
            icon: session.mode == SessionMode.video
                ? Icons.videocam_outlined
                : Icons.location_on_outlined,
            text: session.mode == SessionMode.video
                ? 'Video call'
                : session.place,
          ),
          if (session.note.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              'Cover: ${session.note}',
              style: const TextStyle(fontSize: 11, color: muted),
            ),
          ],
          const SizedBox(height: 13),
          if (session.status == SessionStatus.upcoming)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: onComplete,
                        style: FilledButton.styleFrom(backgroundColor: purple),
                        child: const Text(
                          'Mark Completed',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        child: const Text(
                          'Cancel Session',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onSchedule,
                      icon: const Icon(Icons.edit_calendar_outlined, size: 17),
                      label: Text(
                        session.isScheduled ? 'Reschedule' : 'Schedule session',
                      ),
                    ),
                    if (session.isScheduled)
                      TextButton.icon(
                        onPressed: onCalendar,
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                        ),
                        label: const Text('Add to calendar'),
                      ),
                    if (session.mode == SessionMode.video)
                      OutlinedButton.icon(
                        onPressed: () => joinVideoCall(context, session),
                        icon: const Icon(Icons.videocam_outlined, size: 17),
                        label: const Text('Join video call'),
                      ),
                    if (session.mode == SessionMode.video)
                      TextButton.icon(
                        onPressed: () => copyMeetingLink(context, session),
                        icon: const Icon(Icons.copy_outlined, size: 16),
                        label: const Text('Copy meeting link'),
                      ),
                  ],
                ),
              ],
            )
          else if (session.status == SessionStatus.completed)
            SizedBox(
              width: double.infinity,
              child: rated
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle_outline, size: 17),
                      label: const Text('Rating submitted'),
                    )
                  : FilledButton.tonalIcon(
                      onPressed: onRate,
                      icon: const Icon(Icons.star_outline, size: 18),
                      label: const Text('Rate your experience'),
                    ),
            )
          else
            const Text(
              'This session was cancelled.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => openChat(context, partnerName: session.partner),
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Message'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionDraft {
  const _SessionDraft({
    required this.date,
    required this.time,
    required this.mode,
    required this.place,
    required this.note,
  });
  final DateTime date;
  final TimeOfDay time;
  final SessionMode mode;
  final String place;
  final String note;
}

Future<void> showSessionScheduler(
  BuildContext context,
  DemoState app,
  DemoSession session,
) async {
  final draft = await showModalBottomSheet<_SessionDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ScheduleSessionSheet(session: session),
  );
  if (!context.mounted || draft == null) return;
  app.updateSessionSchedule(
    session,
    date: draft.date,
    time: draft.time,
    mode: draft.mode,
    place: draft.place,
    note: draft.note,
  );
  await app.persistSession(context, session);
}

class ScheduleSessionSheet extends StatefulWidget {
  const ScheduleSessionSheet({super.key, required this.session});
  final DemoSession session;

  @override
  State<ScheduleSessionSheet> createState() => _ScheduleSessionSheetState();
}

class _ScheduleSessionSheetState extends State<ScheduleSessionSheet> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late SessionMode selectedMode;
  late final TextEditingController placeController;
  late final TextEditingController noteController;
  late bool otherPlaceSelected;
  String? validationError;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final suggestedStart = today.add(const Duration(minutes: 30));
    final previousDate = widget.session.isScheduled
        ? _parseSessionDate(widget.session.date) ?? today
        : suggestedStart;
    selectedDate = _dateOnly(previousDate).isBefore(_dateOnly(today))
        ? _dateOnly(today)
        : _dateOnly(previousDate);
    selectedTime = widget.session.isScheduled
        ? _parseTimeOfDay(widget.session.time)
        : TimeOfDay.fromDateTime(suggestedStart);
    selectedMode = widget.session.mode;
    placeController = TextEditingController(text: widget.session.place);
    noteController = TextEditingController(text: widget.session.note);
    otherPlaceSelected =
        placeController.text.isNotEmpty &&
        !const [
          'Library',
          'Canteen',
          'Study lounge',
          'Computer lab',
        ].contains(placeController.text);
  }

  @override
  void dispose() {
    placeController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> chooseDate() async {
    final today = _dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: today,
      lastDate: DateTime(today.year + 10),
    );
    if (!mounted || picked == null) return;
    setState(() {
      selectedDate = _dateOnly(picked);
      validationError = null;
    });
  }

  Future<void> chooseTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (!mounted || picked == null) return;
    setState(() {
      selectedTime = picked;
      validationError = null;
    });
  }

  void save() {
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (selectedDateTime.isBefore(DateTime.now())) {
      setState(
        () => validationError =
            'The selected time has already passed. Choose a future time.',
      );
      return;
    }
    final place = selectedMode == SessionMode.video
        ? ''
        : placeController.text.trim();
    if (selectedMode == SessionMode.inPerson && place.isEmpty) {
      setState(() => validationError = 'Choose or enter a meeting place.');
      return;
    }
    Navigator.pop(
      context,
      _SessionDraft(
        date: selectedDate,
        time: selectedTime,
        mode: selectedMode,
        place: place,
        note: noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: page,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          15,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 14,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D6E4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                widget.session.isScheduled
                    ? 'Reschedule session'
                    : 'Schedule session',
                style: const TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Plan an exchange with ${widget.session.partner}.',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: chooseDate,
                      icon: const Icon(Icons.calendar_today_outlined, size: 17),
                      label: Text(_formatSessionDate(selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: chooseTime,
                      icon: const Icon(Icons.access_time, size: 17),
                      label: Text(_formatTimeOfDay(selectedTime)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const FieldLabel('Meeting type'),
              SegmentedButton<SessionMode>(
                segments: const [
                  ButtonSegment(
                    value: SessionMode.inPerson,
                    label: Text('In person'),
                    icon: Icon(Icons.location_on_outlined),
                  ),
                  ButtonSegment(
                    value: SessionMode.video,
                    label: Text('Video call'),
                    icon: Icon(Icons.videocam_outlined),
                  ),
                ],
                selected: {selectedMode},
                showSelectedIcon: false,
                onSelectionChanged: (value) => setState(() {
                  selectedMode = value.first;
                  validationError = null;
                }),
              ),
              if (selectedMode == SessionMode.inPerson) ...[
                const SizedBox(height: 12),
                const FieldLabel('Meeting place'),
                Wrap(
                  spacing: 6,
                  runSpacing: 0,
                  children: [
                    for (final place in const [
                      'Library',
                      'Canteen',
                      'Study lounge',
                      'Computer lab',
                      'Other',
                    ])
                      ChoiceChip(
                        label: Text(place),
                        selected: place == 'Other'
                            ? otherPlaceSelected
                            : placeController.text == place,
                        onSelected: (_) => setState(() {
                          otherPlaceSelected = place == 'Other';
                          placeController.text = otherPlaceSelected
                              ? ''
                              : place;
                          validationError = null;
                        }),
                      ),
                  ],
                ),
                TextField(
                  controller: placeController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    hintText: 'Choose a place or enter another location',
                    counterText: '',
                  ),
                  onChanged: (value) => setState(() {
                    otherPlaceSelected = !const [
                      'Library',
                      'Canteen',
                      'Study lounge',
                      'Computer lab',
                    ].contains(value);
                    validationError = null;
                  }),
                ),
              ] else ...[
                const SizedBox(height: 12),
                const InfoNote(
                  icon: Icons.videocam_outlined,
                  title: 'Jitsi video meeting',
                  detail: 'Your meeting link will be available on the session card.',
                ),
              ],
              const SizedBox(height: 12),
              const FieldLabel('What should we cover? (optional)'),
              TextField(
                controller: noteController,
                maxLength: 200,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Add a short session note',
                  counterText: '',
                ),
              ),
              if (validationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 8),
                  child: Text(
                    validationError!,
                    style: const TextStyle(
                      color: Color(0xFFB3261E),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              PrimaryButton(label: 'Save session', onPressed: save),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> addSessionToCalendar(
  BuildContext context,
  DemoSession session,
) async {
  final date = _parseSessionDate(session.date);
  if (date == null) {
    showMessage(context, 'This session has an invalid date.');
    return;
  }
  final time = _parseTimeOfDay(session.time);
  final start = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  final end = start.add(Duration(minutes: session.durationMinutes));
  final uri = Uri.https('calendar.google.com', '/calendar/render', {
    'action': 'TEMPLATE',
    'text': 'SkillSwap: ${session.skill} with ${session.partner}',
    'dates': '${_calendarDate(start)}/${_calendarDate(end)}',
    'details': session.note,
    'location': session.mode == SessionMode.video
        ? session.meetingLink
        : session.place,
  });
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      showMessage(context, 'Could not open Google Calendar.');
    }
  } catch (error) {
    if (context.mounted) {
      showMessage(context, 'Could not open Google Calendar: $error');
    }
  }
}

String _calendarDate(DateTime value) {
  final utc = value.toUtc();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${utc.year}${twoDigits(utc.month)}${twoDigits(utc.day)}T'
      '${twoDigits(utc.hour)}${twoDigits(utc.minute)}${twoDigits(utc.second)}Z';
}

Future<void> joinVideoCall(BuildContext context, DemoSession session) async {
  try {
    final opened = await launchUrl(
      Uri.parse(session.meetingLink),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      showMessage(context, 'Could not open the video meeting link.');
    }
  } catch (error) {
    if (context.mounted) {
      showMessage(context, 'Could not open the video meeting link: $error');
    }
  }
}

Future<void> copyMeetingLink(BuildContext context, DemoSession session) async {
  try {
    await Clipboard.setData(ClipboardData(text: session.meetingLink));
    if (context.mounted) showMessage(context, 'Meeting link copied.');
  } catch (error) {
    if (context.mounted) {
      showMessage(context, 'Could not copy the meeting link: $error');
    }
  }
}

void openChat(
  BuildContext context, {
  required String partnerName,
  String? partnerId,
  String? swapRequestId,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatPage(
        partnerName: partnerName,
        partnerId: partnerId,
        swapRequestId: swapRequestId,
      ),
    ),
  );
}

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.partnerName,
    this.partnerId,
    this.swapRequestId,
  });
  final String partnerName;
  final String? partnerId;
  final String? swapRequestId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final messages = <Map<String, dynamic>>[];
  StreamSubscription<List<Map<String, dynamic>>>? messageSubscription;
  String? myId;
  bool loading = true;
  bool sending = false;

  bool get hasConversation =>
      widget.partnerId != null && widget.swapRequestId != null;

  @override
  void initState() {
    super.initState();
    unawaited(loadMessages());
  }

  @override
  void dispose() {
    unawaited(messageSubscription?.cancel() ?? Future<void>.value());
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadMessages() async {
    if (!hasConversation) {
      setState(() => loading = false);
      return;
    }

    try {
      final client = Supabase.instance.client;
      if (client.auth.currentUser == null) {
        throw StateError('Please sign in again to view messages.');
      }
      final userId = client.auth.currentUser!.id;
      final requestId = widget.swapRequestId!;
      final history = await client
          .from('messages')
          .select()
          .eq('swap_request_id', requestId)
          .order('created_at');
      if (!mounted) return;
      setState(() {
        myId = userId;
        messages
          ..clear()
          ..addAll(List<Map<String, dynamic>>.from(history));
        loading = false;
      });
      scrollToLatest();

      messageSubscription = client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('swap_request_id', requestId)
          .order('created_at')
          .listen(
            (rows) {
              if (!mounted) return;
              final byId = <String, Map<String, dynamic>>{
                for (final row in messages) row['id'].toString(): row,
              };
              for (final row in rows) {
                byId[row['id'].toString()] = row;
              }
              final updated = byId.values.toList()
                ..sort((a, b) => _messageDate(a).compareTo(_messageDate(b)));
              setState(() {
                messages
                  ..clear()
                  ..addAll(updated);
              });
              scrollToLatest();
            },
            onError: (Object error) {
              if (mounted) {
                showMessage(context, 'Realtime messages failed: $error');
              }
            },
          );
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage(context, 'Unable to load messages: $error');
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || sending || !hasConversation) return;
    setState(() => sending = true);
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentUser == null) {
        throw StateError('Please sign in again to send messages.');
      }
      final userId = client.auth.currentUser!.id;
      await client.from('messages').insert({
        'swap_request_id': widget.swapRequestId,
        'sender_id': userId,
        'message_text': text,
      });
      if (!mounted) return;
      messageController.clear();
      FocusScope.of(context).unfocus();
    } catch (error) {
      if (mounted) showMessage(context, 'Unable to send message: $error');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  void scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Row(
        children: [
          Avatar(name: widget.partnerName, radius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(widget.partnerName, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: !hasConversation
              ? const Center(
                  child: EmptyState(
                    icon: Icons.lock_outline,
                    title: 'Real conversation details required',
                    detail: 'This demo partner has no verified profile UUID or swap request ID. Open a real conversation from Messages to send messages.',
                  ),
                )
              : loading
              ? const Center(child: CircularProgressIndicator())
              : messages.isEmpty
              ? const Center(
                  child: EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No messages yet',
                    detail: 'Start the conversation with a friendly hello.',
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMine = message['sender_id'] == myId;
                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * .76,
                        ),
                        margin: const EdgeInsets.only(bottom: 9),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isMine ? purple : lavender,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                message['message_text']?.toString() ?? '',
                                style: TextStyle(
                                  color: isMine ? Colors.white : ink,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _messageTime(message['created_at']),
                              style: TextStyle(
                                color: isMine
                                    ? Colors.white70
                                    : const Color(0xFF777990),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (hasConversation)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Write a message…',
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: messageController.text.trim().isEmpty || sending
                        ? null
                        : sendMessage,
                    icon: sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_outlined),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

DateTime _messageDate(Map<String, dynamic> message) =>
    DateTime.tryParse(message['created_at']?.toString() ?? '') ??
    DateTime.fromMillisecondsSinceEpoch(0);

String _messageTime(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '';
  final hour = date.toLocal().hour;
  final minute = date.toLocal().minute.toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';
  return '${hour % 12 == 0 ? 12 : hour % 12}:$minute $suffix';
}

class _ConversationSummary {
  const _ConversationSummary({
    required this.requestId,
    required this.partnerId,
    required this.partnerName,
    required this.latestText,
    required this.latestAt,
  });
  final String requestId;
  final String partnerId;
  final String partnerName;
  final String latestText;
  final String? latestAt;
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  bool loading = true;
  List<_ConversationSummary> conversations = [];

  @override
  void initState() {
    super.initState();
    unawaited(loadConversations());
  }

  Future<void> loadConversations() async {
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentUser == null) {
        throw StateError('Please sign in again to view conversations.');
      }
      final myId = client.auth.currentUser!.id;
      final messageRows = List<Map<String, dynamic>>.from(
        await client
            .from('messages')
            .select('swap_request_id, sender_id, message_text, created_at')
            .order('created_at'),
      );
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final row in messageRows) {
        final requestId = row['swap_request_id']?.toString();
        if (requestId == null) continue;
        grouped.putIfAbsent(requestId, () => []).add(row);
      }

      final requestIds = grouped.keys.toList();
      if (requestIds.isEmpty) {
        if (mounted) setState(() => loading = false);
        return;
      }
      final requestRows = List<Map<String, dynamic>>.from(
        await client
            .from('swap_requests')
            .select('id, requester_id, recipient_id')
            .inFilter('id', requestIds),
      );
      final requestById = {
        for (final row in requestRows) row['id'].toString(): row,
      };
      final partnerIds = <String>{};
      for (final row in requestRows) {
        final requesterId = row['requester_id'].toString();
        final recipientId = row['recipient_id'].toString();
        if (requesterId == myId) partnerIds.add(recipientId);
        if (recipientId == myId) partnerIds.add(requesterId);
      }
      final profiles = partnerIds.isEmpty
          ? <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(
              await client
                  .from('profiles')
                  .select('id, full_name, username')
                  .inFilter('id', partnerIds.toList()),
            );
      final profileById = {
        for (final profile in profiles) profile['id'].toString(): profile,
      };
      final loaded = <_ConversationSummary>[];
      for (final entry in grouped.entries) {
        final request = requestById[entry.key];
        if (request == null) continue;
        final requesterId = request['requester_id'].toString();
        final recipientId = request['recipient_id'].toString();
        final partnerId = requesterId == myId
            ? recipientId
            : recipientId == myId
            ? requesterId
            : null;
        if (partnerId == null) continue;
        final profile = profileById[partnerId];
        final fullName = profile?['full_name']?.toString().trim() ?? '';
        final username = profile?['username']?.toString().trim() ?? '';
        final partnerName = fullName.isNotEmpty
            ? fullName
            : username.isNotEmpty
            ? username
            : 'SkillSwap student';
        final latest = entry.value.last;
        loaded.add(
          _ConversationSummary(
            requestId: entry.key,
            partnerId: partnerId,
            partnerName: partnerName,
            latestText: latest['message_text']?.toString() ?? '',
            latestAt: latest['created_at']?.toString(),
          ),
        );
      }
      loaded.sort(
        (a, b) =>
            _conversationDate(b.latestAt)
                .compareTo(_conversationDate(a.latestAt)),
      );
      if (!mounted) return;
      setState(() {
        conversations = loaded;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage(context, 'Unable to load conversations: $error');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Messages'),
      actions: [
        IconButton(
          tooltip: 'Refresh messages',
          onPressed: () {
            setState(() => loading = true);
            unawaited(loadConversations());
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : conversations.isEmpty
        ? const Center(
            child: EmptyState(
              icon: Icons.forum_outlined,
              title: 'No conversations yet',
              detail: 'Messages linked to your real skill-swap requests will appear here.',
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: conversations.length,
            separatorBuilder: (_, _) => const SizedBox(height: 9),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return CardSurface(
                padding: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => openChat(
                    context,
                    partnerName: conversation.partnerName,
                    partnerId: conversation.partnerId,
                    swapRequestId: conversation.requestId,
                  ),
                  leading: Avatar(name: conversation.partnerName, radius: 22),
                  title: Text(
                    conversation.partnerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  subtitle: Text(
                    conversation.latestText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _messageTime(conversation.latestAt),
                    style: const TextStyle(fontSize: 10, color: muted),
                  ),
                ),
              );
            },
          ),
  );
}

DateTime _conversationDate(String? value) =>
    DateTime.tryParse(value ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _formatSessionDate(DateTime value) =>
    '${_monthNames[value.month - 1]} ${value.day}, ${value.year}';

DateTime? _parseSessionDate(String value) {
  final isoDate = DateTime.tryParse(value);
  if (isoDate != null) return isoDate;
  final match = RegExp(r'^([A-Za-z]{3})\s+(\d{1,2}),\s*(\d{4})$')
      .firstMatch(value.trim());
  if (match == null) return null;
  final month = _monthNames.indexWhere(
    (name) => name.toLowerCase() == match.group(1)!.toLowerCase(),
  );
  if (month < 0) return null;
  return DateTime(
    int.parse(match.group(3)!),
    month + 1,
    int.parse(match.group(2)!),
  );
}

String _formatTimeOfDay(TimeOfDay value) {
  final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
  return '$hour:${value.minute.toString().padLeft(2, '0')} '
      '${value.period == DayPeriod.am ? 'AM' : 'PM'}';
}

TimeOfDay _parseTimeOfDay(String value) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    caseSensitive: false,
  ).firstMatch(value.trim());
  if (match == null) return const TimeOfDay(hour: 14, minute: 0);
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final isPm = match.group(3)!.toUpperCase() == 'PM';
  if (isPm && hour < 12) hour += 12;
  if (!isPm && hour == 12) hour = 0;
  return TimeOfDay(hour: hour, minute: minute);
}

String _sessionStatusValue(SessionStatus status) => switch (status) {
  SessionStatus.upcoming => 'upcoming',
  SessionStatus.completed => 'completed',
  SessionStatus.cancelled => 'cancelled',
};

class _TextControllerOwner extends StatefulWidget {
  const _TextControllerOwner({required this.controller, required this.child});

  final TextEditingController controller;
  final Widget child;

  @override
  State<_TextControllerOwner> createState() => _TextControllerOwnerState();
}

class _TextControllerOwnerState extends State<_TextControllerOwner> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key, required this.app, this.onOpenPassport});
  final DemoState app;
  final VoidCallback? onOpenPassport;
  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  void addSkill(bool teach) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? error;
        bool saving = false;
        return _TextControllerOwner(
          controller: controller,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> save() async {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  setDialogState(() => error = 'Enter a skill first.');
                  return;
                }
                if (value.length > 40) {
                  setDialogState(
                    () => error = 'Skills must be 40 characters or fewer.',
                  );
                  return;
                }
                final skills = teach
                    ? widget.app.teachingSkills
                    : widget.app.learningSkills;
                if (skills.any(
                  (item) => item.toLowerCase() == value.toLowerCase(),
                )) {
                  setDialogState(
                    () => error = 'That skill is already on your list.',
                  );
                  return;
                }
                setDialogState(() {
                  saving = true;
                  error = null;
                });
                try {
                  final client = Supabase.instance.client;
                  final userId = client.auth.currentUser?.id;
                  if (userId == null) {
                    throw StateError(
                      'Sign in to sync skills with your account.',
                    );
                  }
                  final skillKey = value.toLowerCase();
                  var skillId = widget.app.skillIds[skillKey];
                  if (skillId == null) {
                    var row = await client
                        .from('skills')
                        .select('id')
                        .ilike('skill_name', value)
                        .maybeSingle();
                    if (!mounted || !dialogContext.mounted) return;
                    if (row == null) {
                      row = await client
                          .from('skills')
                          .insert({'skill_name': value})
                          .select('id')
                          .single();
                      if (!mounted || !dialogContext.mounted) return;
                    }
                    skillId = row['id'] as int;
                  }
                  final existing = await client
                      .from('user_skills')
                      .select('id')
                      .eq('user_id', userId)
                      .eq('skill_id', skillId)
                      .eq('skill_type', teach ? 'teach' : 'learn')
                      .maybeSingle();
                  if (!mounted || !dialogContext.mounted) return;
                  if (existing == null) {
                    await client.from('user_skills').insert({
                      'user_id': userId,
                      'skill_id': skillId,
                      'skill_type': teach ? 'teach' : 'learn',
                    });
                    if (!mounted || !dialogContext.mounted) return;
                  }
                  widget.app.skillIds[skillKey] = skillId;
                  widget.app.addSkill(value, teach);
                  Navigator.pop(dialogContext);
                } catch (error) {
                  if (!mounted || !dialogContext.mounted) return;
                  widget.app.addSkill(value, teach);
                  showMessage(
                    this.context,
                    'Skill added on this device, but could not sync: $error',
                  );
                  Navigator.pop(dialogContext);
                }
              }

              return AlertDialog(
                title: Text(
                  teach ? 'Add a teaching skill' : 'Add a learning goal',
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLength: 40,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: teach
                            ? 'e.g. Creative writing'
                            : 'e.g. Data science',
                        counterText: '',
                      ),
                      onChanged: (_) {
                        if (error != null) setDialogState(() => error = null);
                      },
                      onSubmitted: (_) => save(),
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          error!,
                          style: const TextStyle(
                            color: Color(0xFFB3261E),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: saving ? null : save,
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add skill'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> removeSkill(String skill, bool teach) async {
    widget.app.removeSkill(skill, teach);
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw StateError('Sign in to sync skill changes with your account.');
      }
      var skillId = widget.app.skillIds[skill.toLowerCase()];
      if (skillId == null) {
        final row = await client
            .from('skills')
            .select('id')
            .ilike('skill_name', skill)
            .maybeSingle();
        if (!mounted) return;
        skillId = row?['id'] as int?;
      }
      if (skillId == null) return;
      await client
          .from('user_skills')
          .delete()
          .eq('user_id', userId)
          .eq('skill_id', skillId)
          .eq('skill_type', teach ? 'teach' : 'learn');
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          'Skill removed on this device, but not synced: $error',
        );
      }
    }
  }

  Widget skillSection(
    String title,
    String subtitle,
    bool teach,
    IconData icon,
  ) {
    final skills = teach
        ? widget.app.teachingSkills
        : widget.app.learningSkills;
    return CardSurface(
      margin: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: teach ? purple : blue),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (skills.isEmpty)
            const EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'Nothing here yet',
              detail: 'Add a skill to get started.',
            ),
          if (skills.isNotEmpty)
            Wrap(
              spacing: 7,
              runSpacing: 8,
              children: [
                for (final skill in skills)
                  InputChip(
                    label: Text(skill),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => unawaited(removeSkill(skill, teach)),
                    backgroundColor: lavender,
                    labelStyle: const TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    side: BorderSide.none,
                  ),
              ],
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => addSkill(teach),
              icon: const Icon(Icons.add, size: 18),
              label: Text(teach ? 'Add Teaching Skill' : 'Add Learning Skill'),
              style: FilledButton.styleFrom(
                backgroundColor: teach ? purple : blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) => PageFrame(
      app: widget.app,
      title: 'My Skills',
      subtitle: 'Share your strengths. Explore your curiosity.',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          InfoNote(
            icon: Icons.auto_awesome_outlined,
            title: 'Your skills open doors',
            detail: 'Add a skill you can teach and something you are excited to learn.',
          ),
          const SizedBox(height: 16),
          skillSection(
            'Skills I Can Teach',
            'Teach what comes naturally to you.',
            true,
            Icons.menu_book_outlined,
          ),
          skillSection(
            'Skills I Want to Learn',
            'Make room for your next discovery.',
            false,
            Icons.lightbulb_outline,
          ),
          CardSurface(
            child: Row(
              children: [
                const Icon(Icons.insights_outlined, color: purple, size: 25),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'You have completed ${widget.app.completedCount} skill exchanges so far.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ink,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onOpenPassport,
                  child: const Text('Passport'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.app, this.onOpenPassport});
  final DemoState app;
  final VoidCallback? onOpenPassport;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final name = TextEditingController(text: widget.app.name);
  late final college = TextEditingController(text: widget.app.college);
  late final bio = TextEditingController(text: widget.app.bio);
  bool signingOut = false;
  bool uploadingAvatar = false;
  @override
  void dispose() {
    name.dispose();
    college.dispose();
    bio.dispose();
    super.dispose();
  }

  void reset() {
    name.text = widget.app.name;
    college.text = widget.app.college;
    bio.text = widget.app.bio;
    FocusScope.of(context).unfocus();
  }

  Future<void> logout() async {
    if (signingOut) return;
    setState(() => signingOut = true);
    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginPage(app: widget.app)),
        (_) => false,
      );
    } catch (error) {
      if (mounted) showMessage(context, 'Unable to log out: $error');
    } finally {
      if (mounted) setState(() => signingOut = false);
    }
  }

  Future<void> chooseAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: purple),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: purple),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (!mounted || source == null) return;

    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (!mounted || image == null) return;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        showMessage(context, 'Sign in again before uploading a profile photo.');
        return;
      }
      setState(() => uploadingAvatar = true);
      final bytes = await image.readAsBytes();
      if (!mounted) return;
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
      if (!mounted) return;
      final publicUrl = client.storage.from('avatars').getPublicUrl(objectPath);
      await client
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);
      if (!mounted) return;
      widget.app.updateAvatarUrl(publicUrl);
      showMessage(context, 'Profile photo updated.');
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Could not upload profile photo: $error');
      }
    } finally {
      if (mounted) setState(() => uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) => PageFrame(
      app: widget.app,
      title: 'My Profile',
      subtitle: 'A little about you. A world of possibilities.',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          CardSurface(
            child: Column(
              children: [
                Avatar(
                  name: widget.app.name,
                  imageUrl: widget.app.avatarUrl,
                  radius: 30,
                  color: Color(0xFF6754E8),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Make your profile yours',
                  style: TextStyle(fontWeight: FontWeight.w800, color: ink),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add a photo and introduce yourself to the SkillSwap community.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: uploadingAvatar ? null : chooseAvatar,
                  icon: uploadingAvatar
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_a_photo_outlined, size: 16),
                  label: Text(
                    uploadingAvatar ? 'Uploading…' : 'Add profile photo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CardSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Personal details',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Only you can edit this profile.',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 14),
                const FieldLabel('Full name'),
                TextField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Add your full name',
                  ),
                ),
                const SizedBox(height: 12),
                const FieldLabel('College or university'),
                TextField(
                  controller: college,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Add your college or university',
                  ),
                ),
                const SizedBox(height: 12),
                const FieldLabel('Bio'),
                TextField(
                  controller: bio,
                  maxLength: 200,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'What do you enjoy learning or teaching?',
                  ),
                ),
                SizedBox(
                  height: 42,
                  child: FilledButton(
                    onPressed: () {
                      if (name.text.trim().isEmpty ||
                          college.text.trim().isEmpty) {
                        showMessage(context, 'Name and college are required.');
                        return;
                      }
                      widget.app.updateProfile(
                        newName: name.text,
                        newCollege: college.text,
                        newBio: bio.text,
                      );
                      FocusScope.of(context).unfocus();
                      showMessage(context, 'Your profile has been saved.');
                    },
                    style: FilledButton.styleFrom(backgroundColor: purple),
                    child: const Text('Save Profile'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: reset,
                    child: const Text('Cancel changes'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CardSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_outlined, color: purple),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Your Skill Passport',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onOpenPassport,
                      child: const Text('Open'),
                    ),
                  ],
                ),
                const Text(
                  'Your teaching, learning and student achievements in one place.',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    MiniStat(
                      value: '${widget.app.completedCount}',
                      label: 'Completed',
                    ),
                    MiniStat(
                      value: widget.app.averageRating.toStringAsFixed(1),
                      label: 'Avg. rating',
                    ),
                    MiniStat(
                      value: '${widget.app.ratings.length}',
                      label: 'Ratings',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: signingOut ? null : logout,
              icon: const Icon(Icons.logout),
              label: Text(signingOut ? 'Logging out…' : 'Log out'),
            ),
          ),
        ],
      ),
    ),
  );
}

class RatingPage extends StatefulWidget {
  const RatingPage({
    super.key,
    required this.app,
    required this.session,
    this.onOpenPassport,
  });
  final DemoState app;
  final DemoSession session;
  final VoidCallback? onOpenPassport;
  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final review = TextEditingController();
  int selected = 0;
  bool submitting = false;
  bool submitted = false;
  static const ratingLabels = [
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
  ];

  void openPassport() {
    final callback = widget.onOpenPassport;
    if (callback == null) return;
    Navigator.pop(context);
    callback();
  }

  @override
  void dispose() {
    review.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (selected == 0 || submitting || submitted) return;
    setState(() => submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    widget.app.addRating(
      DemoRating(
        sessionId: widget.session.id,
        partner: widget.session.partner,
        skill: widget.session.skill,
        stars: selected,
        review: review.text.trim(),
        date: 'Today',
      ),
    );
    setState(() {
      submitting = false;
      submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) => Scaffold(
      body: PageFrame(
        app: widget.app,
        title: 'Rate Your Experience',
        subtitle: 'Your feedback helps other students build trust and improve their learning experience.',
        trailing: IconButton(
          onPressed: openPassport,
          icon: const Icon(
            Icons.workspace_premium_outlined,
            color: Colors.white,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
          children: [
            SectionTitle(submitted ? 'Thank you for sharing!' : 'Your session'),
            const SizedBox(height: 9),
            CardSurface(
              child: Row(
                children: [
                  Avatar(name: widget.session.partner, radius: 25),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.session.partner,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.session.skill,
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 11,
                          children: [
                            LabelIcon(
                              icon: Icons.calendar_today_outlined,
                              text: widget.session.date,
                            ),
                            LabelIcon(
                              icon: Icons.access_time,
                              text: widget.session.time,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const StatusPill('Completed', color: Color(0xFF168B64)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CardSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How was your experience?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Required · Choose one rating',
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      5,
                      (i) => Semantics(
                        button: true,
                        label: 'Rate ${i + 1} ${ratingLabels[i]}',
                        child: InkWell(
                          onTap: submitted
                              ? null
                              : () => setState(() => selected = i + 1),
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              i < selected
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 39,
                              color: i < selected
                                  ? const Color(0xFFFFB72B)
                                  : const Color(0xFFB7B7C7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selected > 0)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: lavender,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$selected  ·  ${ratingLabels[selected - 1]}',
                          style: const TextStyle(
                            color: purple,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  if (selected == 0)
                    const Center(
                      child: Text(
                        'Select a rating',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CardSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Write a Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Optional · Help another student know what to expect.',
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                  const SizedBox(height: 11),
                  TextField(
                    controller: review,
                    enabled: !submitted,
                    maxLength: 500,
                    maxLines: 5,
                    minLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Share your experience with this student...',
                      counterText: '',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${review.text.length}/500 characters',
                      style: const TextStyle(fontSize: 10, color: muted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (submitted)
              CardSurface(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF20A477),
                      size: 34,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Rating submitted successfully',
                      style: TextStyle(fontWeight: FontWeight.w800, color: ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your $selected-star review is now part of your Skill Passport.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    TextButton.icon(
                      onPressed: openPassport,
                      icon: const Icon(Icons.workspace_premium_outlined),
                      label: const Text('View Skill Passport'),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: selected == 0 || submitting ? null : submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: purple,
                        disabledBackgroundColor: const Color(0xFFE4E3EC),
                        disabledForegroundColor: muted,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: submitting
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit Rating',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selected == 0
                        ? 'Select a star rating to continue'
                        : 'Your written review is optional.',
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            const InfoNote(
              icon: Icons.shield_outlined,
              title: 'Honest feedback builds a better community.',
              detail: 'Your review helps SkillSwap students make great connections.',
            ),
          ],
        ),
      ),
    ),
  );
}

class PassportPage extends StatelessWidget {
  const PassportPage({super.key, required this.app, this.isTab = false});
  final DemoState app;
  final bool isTab;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) {
      final completed =
          app.sessions
              .where((s) => s.status == SessionStatus.completed)
              .toList()
            ..sort(
              (a, b) => (_parseSessionDate(b.date) ?? DateTime(0)).compareTo(
                _parseSessionDate(a.date) ?? DateTime(0),
              ),
            );
      return Scaffold(
        body: PageFrame(
          app: app,
          title: 'My Skill Passport',
          subtitle:
              'Your skills, achievements and learning journey in one place.',
          trailing: isTab
              ? IconButton(
                  tooltip: 'Share passport',
                  onPressed: () => sharePassport(context, app),
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                )
              : IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 25),
            children: [
              CardSurface(
                child: Column(
                  children: [
                    Avatar(
                      name: app.name,
                      imageUrl: app.avatarUrl,
                      radius: 37,
                      color: purple,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      app.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 15,
                          color: purple,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            app.college,
                            style: const TextStyle(fontSize: 12, color: muted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFE9A91E),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${app.averageRating.toStringAsFixed(1)} overall rating · ${app.ratings.length} reviews',
                          style: const TextStyle(
                            color: muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    const StatusPill('SKILLSWAP STUDENT', color: purple),
                    const SizedBox(height: 13),
                    Text(
                      app.bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => sharePassport(context, app),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share passport'),
                ),
              ),
              const SizedBox(height: 14),
              CardSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('Your exchange impact'),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: PassportStat(
                            value: '${app.taughtCount}',
                            label: 'Sessions Taught',
                            icon: Icons.menu_book_outlined,
                            color: purple,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: PassportStat(
                            value: '${app.learnedCount}',
                            label: 'Sessions Learned',
                            icon: Icons.school_outlined,
                            color: blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: PassportStat(
                            value: app.completedHours.toStringAsFixed(
                              app.completedHours % 1 == 0 ? 0 : 1,
                            ),
                            label: 'Hours Learned & Shared',
                            icon: Icons.schedule_outlined,
                            color: const Color(0xFF8A61D5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: PassportStat(
                            value: '${app.completedCount}',
                            label: 'Completed Sessions',
                            icon: Icons.check_circle_outline,
                            color: const Color(0xFF15966F),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: PassportStat(
                            value: app.averageRating.toStringAsFixed(1),
                            label: 'Average Rating',
                            icon: Icons.star_rounded,
                            color: const Color(0xFFE9A91E),
                            stars: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.rate_review_outlined,
                          color: purple,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${app.ratings.length} student ratings',
                          style: const TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${app.ratings.length} total',
                          style: const TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: app.averageRating == 0
                            ? 0
                            : app.averageRating / 5,
                        minHeight: 7,
                        backgroundColor: lavender,
                        color: const Color(0xFFFFB72B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      app.ratings.isEmpty
                          ? 'No ratings yet. Complete a session and invite a student to leave feedback.'
                          : '${app.averageRating.toStringAsFixed(1)} out of 5.0 based on ${app.ratings.length} ${app.ratings.length == 1 ? 'rating' : 'ratings'}',
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              skillPassportSection(
                'Skills I Can Teach',
                app.teachingSkills,
                Icons.volunteer_activism_outlined,
                purple,
              ),
              const SizedBox(height: 10),
              skillPassportSection(
                'Skills I Want to Learn',
                app.learningSkills,
                Icons.lightbulb_outline,
                blue,
              ),
              const SizedBox(height: 14),
              CardSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('Recent activity'),
                    const SizedBox(height: 4),
                    const Text(
                      'Your latest completed skill exchanges.',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    if (completed.isEmpty)
                      const EmptyState(
                        icon: Icons.history,
                        title: 'Your journey starts here',
                        detail:
                            'Complete an exchange to add your first activity.',
                      ),
                    for (final session in completed.take(5))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color:
                                    session.direction ==
                                        ExchangeDirection.taught
                                    ? lavender
                                    : const Color(0xFFECF3FF),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                session.direction == ExchangeDirection.taught
                                    ? Icons.menu_book_outlined
                                    : Icons.school_outlined,
                                color:
                                    session.direction ==
                                        ExchangeDirection.taught
                                    ? purple
                                    : blue,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${session.direction == ExchangeDirection.taught ? 'Taught' : 'Learned'} ${session.skill}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: ink,
                                    ),
                                  ),
                                  Text(
                                    'with ${session.partner}  ·  ${session.date}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (app.isRated(session.id))
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFFFB72B),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              CardSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('Milestones'),
                    const SizedBox(height: 11),
                    Milestone(
                      title: 'First Lesson',
                      detail: 'Complete your first learning session.',
                      unlocked: app.completedCount >= 1,
                      progress: app.completedCount >= 1
                          ? '1 / 1'
                          : '${app.completedCount} / 1',
                      icon: Icons.menu_book_outlined,
                    ),
                    const SizedBox(height: 9),
                    Milestone(
                      title: 'Knowledge Sharer',
                      detail: 'Complete your first teaching session.',
                      unlocked: app.taughtCount >= 1,
                      progress: app.taughtCount >= 1
                          ? '1 / 1'
                          : '${app.taughtCount} / 1',
                      icon: Icons.volunteer_activism_outlined,
                    ),
                    const SizedBox(height: 9),
                    Milestone(
                      title: 'Exchange Champion',
                      detail: 'Complete five skill exchanges.',
                      unlocked: app.completedCount >= 5,
                      progress: '${app.completedCount.clamp(0, 5)} / 5',
                      icon: Icons.workspace_premium_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (app.ratings.isNotEmpty)
                CardSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Reviews received'),
                      const SizedBox(height: 9),
                      for (final rating in app.ratings.take(3))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Avatar(name: rating.partner, radius: 18),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            rating.partner,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: ink,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          rating.date,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < rating.stars
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          size: 13,
                                          color: const Color(0xFFFFB72B),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      rating.review,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        height: 1.35,
                                        color: muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              else
                const EmptyState(
                  icon: Icons.rate_review_outlined,
                  title: 'No ratings yet',
                  detail: 'Ratings from completed sessions will appear here.',
                ),
            ],
          ),
        ),
      );
    },
  );

  Widget skillPassportSection(
    String title,
    List<String> skills,
    IconData icon,
    Color color,
  ) => CardSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, color: ink),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (skills.isEmpty)
          const Text(
            'No skills added yet. Visit My Skills to add some.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        if (skills.isNotEmpty)
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final skill in skills) SkillPill(skill, color: color),
            ],
          ),
      ],
    ),
  );
}

class PassportStat extends StatelessWidget {
  const PassportStat({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.stars = false,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool stars;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F7FD),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFF0EFF8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (stars)
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < double.tryParse(value)!.round()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 12,
                color: const Color(0xFFFFB72B),
              ),
            ),
          ),
      ],
    ),
  );
}

class Milestone extends StatelessWidget {
  const Milestone({
    super.key,
    required this.title,
    required this.detail,
    required this.unlocked,
    required this.progress,
    required this.icon,
  });
  final String title;
  final String detail;
  final bool unlocked;
  final String progress;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: unlocked ? const Color(0xFFF1FBF7) : const Color(0xFFF8F8FC),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: unlocked ? const Color(0xFFD8F1E7) : const Color(0xFFEFEFF5),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: unlocked ? const Color(0xFFDDF5EB) : lavender,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 18,
            color: unlocked ? const Color(0xFF168B64) : purple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: ink,
                ),
              ),
              Text(detail, style: const TextStyle(fontSize: 10, color: muted)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              unlocked ? Icons.check_circle : Icons.lock_outline,
              color: unlocked ? const Color(0xFF168B64) : muted,
              size: 17,
            ),
            Text(
              unlocked ? 'Earned' : progress,
              style: TextStyle(
                fontSize: 9,
                color: unlocked ? const Color(0xFF168B64) : muted,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class MiniStat extends StatelessWidget {
  const MiniStat({super.key, required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: purple,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 10),
        ),
      ],
    ),
  );
}

class CardSurface extends StatelessWidget {
  const CardSurface({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(14),
  });
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0B282550),
          blurRadius: 15,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
    this.color = const Color(0xFF6754E8),
    this.icon,
  });
  final String name;
  final String? imageUrl;
  final double radius;
  final Color color;
  final IconData? icon;

  Widget fallback() => icon == null
      ? Text(
          initials(name),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: radius * .53,
          ),
        )
      : Icon(icon, color: color, size: radius * .95);

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: .12),
      child: url == null || url.isEmpty
          ? fallback()
          : ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(child: fallback()),
                  Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 46,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: purple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    ),
  );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
  );
}

class InfoNote extends StatelessWidget {
  const InfoNote({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    this.color = const Color(0xFFEFF3FF),
  });
  final IconData icon;
  final String title;
  final String detail;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: purple, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: ink,
    ),
  );
}

class SkillPill extends StatelessWidget {
  const SkillPill(this.text, {super.key, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.text, {super.key, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color),
    ),
  );
}

class LabelIcon extends StatelessWidget {
  const LabelIcon({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: muted),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 10, color: muted)),
    ],
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    child: Column(
      children: [
        Icon(icon, size: 31, color: const Color(0xFFB2A9F6)),
        const SizedBox(height: 7),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: ink,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: muted),
        ),
      ],
    ),
  );
}

const smallCaption = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w800,
  letterSpacing: .5,
  color: muted,
);

String initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

Future<void> sharePassport(BuildContext context, DemoState app) async {
  final summary =
      '${app.name} - SkillSwap student at ${app.college}. '
      '${app.teachingSkills.length} skills to teach, '
      '${app.learningSkills.length} skills to learn, '
      '${app.completedCount} completed exchanges, '
      '${app.averageRating.toStringAsFixed(1)}/5 average rating.';
  try {
    await Share.share(summary, subject: '${app.name}’s SkillSwap Passport');
  } catch (error) {
    if (context.mounted) {
      showMessage(context, 'Could not share passport: $error');
    }
  }
}

void showStudentProfile(BuildContext context, Student student) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        color: page,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD5D3E1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            Avatar(
              name: student.name,
              radius: 38,
              color: student.color,
              icon: student.icon,
            ),
            const SizedBox(height: 10),
            Text(
              student.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF1B638),
                  size: 17,
                ),
                Text(
                  ' ${student.rating}.0  ·  SkillSwap student',
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              student.bio,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: muted),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CAN TEACH', style: smallCaption),
                      const SizedBox(height: 7),
                      SkillPill(student.teaches, color: purple),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('WANTS TO LEARN', style: smallCaption),
                      const SizedBox(height: 7),
                      SkillPill(student.learns, color: blue),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showMessage(
                    context,
                    'Send an exchange request from Find Your Match.',
                  );
                },
                icon: const Icon(Icons.send_outlined, size: 17),
                label: const Text('Connect with student'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
