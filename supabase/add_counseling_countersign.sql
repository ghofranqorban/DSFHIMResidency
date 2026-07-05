-- Counseling countersign fields + RPC (idempotent)
-- Run once in Supabase SQL editor

ALTER TABLE counseling
  ADD COLUMN IF NOT EXISTS issued_by uuid REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS recipient_profile_id uuid REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS acknowledged_by uuid REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS acknowledged_at timestamptz;

-- Security-definer function so recipients can only update the ack fields
CREATE OR REPLACE FUNCTION acknowledge_counseling(counseling_id bigint)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  UPDATE counseling
  SET acknowledged_by = auth.uid(), acknowledged_at = now()
  WHERE id = counseling_id AND recipient_profile_id = auth.uid();
END;
$$;

GRANT EXECUTE ON FUNCTION acknowledge_counseling(bigint) TO authenticated;
