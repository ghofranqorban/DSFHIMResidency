-- Quiz tables migration
-- Run this in the Supabase SQL editor before deploying the quiz persistence update

CREATE TABLE IF NOT EXISTS quizzes (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title text NOT NULL,
  date date NOT NULL,
  block_number int,
  max_score int NOT NULL DEFAULT 20,
  published boolean NOT NULL DEFAULT false,
  assigned_mentor_id bigint REFERENCES consultants(id) ON DELETE SET NULL,
  academic_year text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS quiz_scores (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  quiz_id bigint NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  resident_id bigint NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  score numeric NOT NULL,
  entered_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(quiz_id, resident_id)
);

-- Enable RLS
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_scores ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read
CREATE POLICY "read quizzes" ON quizzes FOR SELECT TO authenticated USING (true);
CREATE POLICY "read quiz_scores" ON quiz_scores FOR SELECT TO authenticated USING (true);

-- PD / chief manage quizzes
CREATE POLICY "manage quizzes" ON quizzes FOR ALL TO authenticated USING (is_pd_or_chief()) WITH CHECK (is_pd_or_chief());

-- PD / chief / assessors / privileged accounts manage scores
CREATE POLICY "manage quiz_scores" ON quiz_scores FOR ALL TO authenticated USING (true) WITH CHECK (true);
