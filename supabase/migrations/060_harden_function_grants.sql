-- ============================================================
-- 060_harden_function_grants.sql — tighten EXECUTE on functions
--
-- Supabase's default privileges grant EXECUTE on every new function in
-- `public` to `anon` and `authenticated` explicitly, so the
-- `REVOKE ALL ... FROM PUBLIC` in earlier migrations does not stop
-- those roles from calling SECURITY DEFINER functions through
-- `/rest/v1/rpc/*`. This migration revokes the explicit grants.
--
--   - Internal helpers (service-role only): broadcast counters, the
--     AI auto-reply slot claim, webhook failure tracking and the
--     duplicate-merge maintenance functions. The app calls these only
--     through the service-role client. (Same as 044; repeated here so
--     this migration stands on its own.)
--   - Trigger functions: nobody needs to call them directly; Postgres
--     doesn't check EXECUTE on the trigger function when a trigger fires.
--   - Signed-in RPCs (member management, invitations, presence): keep
--     `authenticated`, drop `anon`.
--   - Left as is: `peek_invitation` (intentionally public, see 019) and
--     `is_account_member` (used by RLS policies; returns false for anon).
--
-- Also pins `search_path` on the four plain trigger/helper functions
-- flagged by the linter.
--
-- Idempotent — safe to run multiple times.
-- ============================================================

-- Internal helpers: service role only
REVOKE ALL ON FUNCTION public._bcast_bump(uuid, text, integer) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.recompute_broadcast_counts(uuid) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.claim_ai_reply_slot(uuid, integer) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.record_webhook_failure(uuid, integer) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.merge_duplicate_contacts() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.merge_duplicate_conversations() FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public._bcast_bump(uuid, text, integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.recompute_broadcast_counts(uuid) TO service_role;
GRANT EXECUTE ON FUNCTION public.claim_ai_reply_slot(uuid, integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.record_webhook_failure(uuid, integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.merge_duplicate_contacts() TO service_role;
GRANT EXECUTE ON FUNCTION public.merge_duplicate_conversations() TO service_role;

-- Trigger functions: not callable over the API
REVOKE ALL ON FUNCTION public.broadcast_recipient_aggregate_trigger() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.notify_conversation_assigned() FROM PUBLIC, anon, authenticated;

-- Signed-in RPCs: authenticated only
REVOKE ALL ON FUNCTION public.set_member_role(uuid, account_role_enum) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.remove_account_member(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.transfer_account_ownership(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.redeem_invitation(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.touch_presence(text) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.set_member_role(uuid, account_role_enum) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.remove_account_member(uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.transfer_account_ownership(uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.redeem_invitation(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.touch_presence(text) TO authenticated, service_role;

-- Pin search_path on flagged helpers
ALTER FUNCTION public.update_updated_at_column() SET search_path = public;
ALTER FUNCTION public._bcast_cols_for_status(text) SET search_path = public;
ALTER FUNCTION public.update_ai_configs_updated_at() SET search_path = public;
ALTER FUNCTION public.update_ai_knowledge_documents_updated_at() SET search_path = public;
