import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://lskmanmnbcgdvoemftme.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxza21hbm1uYmNnZHZvZW1mdG1lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MzAwNjUsImV4cCI6MjA4NjMwNjA2NX0.KlitVTxYPHngnoz8hHKH9bM7r0AUQRZE0_dhl1oxRAk';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
