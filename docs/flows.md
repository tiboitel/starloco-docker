# Workflow Flows

> Canonical step-by-step workflows for routine tasks. Use as reference, not load every session.

---

## Feature/Behavior Change Flow

1. **Explore** — use plan mode to understand scope
2. **Plan** — draft approach, identify affected files
3. **Build** — implement changes
4. **Test** — `./run.sh start` verify
5. **Review** — invoke `@review` before commit
6. **Commit** — only after review passes
7. **Summarize** — add to session summary in `docs/ai/summaries/`

---

## Bug Investigation Flow

1. Check logs: `./run.sh logs [service]`
2. Verify status: `./run.sh status`
3. Identify root cause via logs, config, DB state
4. Plan fix (plan mode)
5. Implement (build mode)
6. Test fix
7. Review and commit
8. Update decisions.md if the fix reveals a pattern worth recording

---

## Pre-commit Gate

For any feature or behavior change:

1. Run compose validation: `docker compose config --quiet`
2. Start services: `./run.sh start && ./run.sh status`
3. Check logs for errors: `./run.sh logs | grep -i error`
4. Verify no secrets in diff: `git diff --cached | grep -i secret`
5. Invoke `@review`
6. Only commit after review passes

---

## Task Tracking

- Use `CURRENT_TASK.md` for active task state
- Update when task starts, changes focus, or completes
- Keep it short: one line per task, status marker
- Move completed tasks to `docs/ai/summaries/session-*.md`

---

## Reference

- Commit gate: `@docs/ai/modules/commit-gate.md`
- Review gate: `@docs/ai/modules/review-gate.md`
- Task planning: `@docs/ai/modules/task-planning.md`
- Verification: `@docs/ai/modules/verification.md`
- Doc sync: `@docs/ai/modules/doc-sync.md`