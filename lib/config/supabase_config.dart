import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase connection settings for SkillSwap.
// The anon key is designed to be public in client apps.
// Your data stays safe only if Row Level Security (RLS) is on for every table.
// Never put the service_role key in this app.

Future<void> initializeSupabase() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

const supabaseUrl = 'https://dovobzhojwlcmsjadkqk.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvdm9iemhvandsY21zamFka3FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ2NTcwMjMsImV4cCI6MjExMDIzMzAyM30.rJYTM8mrmGxcj_cMcHCDzMBIsdIzif2T6mWPO4nBrrQ';
