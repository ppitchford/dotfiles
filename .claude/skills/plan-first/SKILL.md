---
name: plan-first
description: Structured planning workflow for substantial coding work. Use when the user requests a new feature, a refactor touching multiple files, a non-trivial bug fix, a new module or component, or any implementation requiring more than three sequential changes. Trigger phrases include 'add', 'implement', 'build', 'refactor', 'integrate', or 'migrate'. Do NOT use for: single-line edits, typo fixes, variable renames, syntax questions, debugging a single file, code explanations, read-only analysis, or one-shot answers. Analyzes the project, establishes whether it is a learning project, asks clarifying questions, creates a TODO.md, gets user approval, then executes one step at a time.
---

# Plan-First Workflow

## Rules

These are absolute. Each is restated in context within the phases below; this section is the quick reference.

- Never write code, create files, or run commands before `TODO.md` is approved.
- **Never start planning before the project is classified.** Learning project or not decides who writes the code, and getting it wrong is the failure this skill exists to prevent.
- Never assume missing information. Ask. If too many unknowns exist to resolve in a single round of questions, surface that fact and ask the user to narrow scope before planning.
- Never skip phases. Follow them in order.
- **The whole plan is approved up front; the plan is then executed one step at a time.** These are not in tension — the plan is a proposal to agree on, not a sequence to run blind.
- Never go off-plan. Work discovered mid-execution goes into `TODO.md` under a `Discovered Tasks` section and waits for approval.

---

## Phase 1 — Analyze the Project

Before asking anything, read the project silently. Check:

1. Directory structure (top two levels).
2. Project manifest: `Cargo.toml`, `package.json`, `pubspec.yaml`, `go.mod`, `requirements.txt`, `pom.xml`, or equivalent.
3. Existing dependencies and their versions.
4. Build system and scripts (`Makefile`, `scripts/`, CI config).
5. `README.md` or equivalent.
6. Existing `TODO.md`, `TASKS.md`, `.todo`, or open-issue files.
7. Any files the repo's `CLAUDE.md` names as required reading. `CLAUDE.md` itself is already loaded at session start; the files it points to are not.

Do not output analysis results unless they're directly relevant to a clarifying question.

**Greenfield exception:** if the project doesn't yet exist (empty directory, or only a `CLAUDE.md` / `README` placeholder), skip the analysis and proceed to Phase 2 to gather everything needed to scaffold it.

---

## Phase 2 — Classify: Is This a Learning Project?

This determines who writes the code, so settle it before anything else.

**First, check whether it is already decided.** If the repo's `CLAUDE.md` declares the project a learning vehicle, or declares that it is explicitly not one, that is the answer. Do not re-ask. As of this writing `frame`, `ornatus` and `artspacesocal` are learning vehicles; `personal-website` explicitly is not.

**If nothing declares it, ask — before the clarifying questions, not mixed in with them.** Put the trade-off in prose and recommend, then ask directly:

1. **Does this contribute to your overall goals, or is it a means to something else?** Work that is itself the point is a candidate for learning; plumbing in service of something else usually isn't.
2. **What is the level of effort, and what is the appetite for it?** Learning is slower by design. A project with a deadline or a blocked dependency downstream is a poor vehicle for it.
3. **Is this a language, stack or domain you want to own, or one you want the result of?** Owning it means writing it.
4. **Is there a shipped definition?** Every learning project needs one, or it becomes learn-forever. If there isn't one, that is the first thing to write down.

**Record the answer in the repo's `CLAUDE.md`** before proceeding, so the next session does not have to ask again. If it is a learning project, that entry states which rung of the fade ladder applies now — explain-then-write, review-after, or hint-only.

### What classification changes

| | Not a learning project | Learning project |
| --- | --- | --- |
| Who writes the code | You | The author |
| Your role in Phase 6 | Implement each task | Explain the approach, then review what the author wrote and say plainly what is wrong |
| `TODO.md` tasks | Written as work you will do | Written as work the author will do, sized to one sitting each |
| Marking a task `[x]` | When you finish it and it passes | When the author's implementation passes review |
| Exceptions | — | Diagnosis is yours: reading code to explain it, and locating a bug's cause. Writing the fix is the author's. A repo may name further exceptions — infrastructure is the usual one |

The user-level `CLAUDE.md` holds the full terms, including the fade ladder. Do not restate them in `TODO.md`.

---

## Phase 3 — Ask Clarifying Questions (One Round)

After analysis and classification, identify gaps that would block correct implementation.

- Ask only what is critical and cannot be inferred from the codebase.
- Aim for fewer than 5 questions. If more than 5 critical unknowns exist, surface that fact and ask the user to narrow scope before planning.
- Number the questions.
- Do not ask about things the project files already answer.
- Do not split into multiple rounds.

**On menus.** A menu of options is allowed and is often faster than prose. The rule it must satisfy: **the answer has to be in it.** The recurring failure is three options when the user's position is between two of them. So:

1. Put the trade-offs and a recommendation in prose **first**. A menu never replaces the reasoning.
2. Make the options genuinely distinct — not three shades of one position.
3. State in the prose that combining two options, or rejecting all of them, is a valid reply.
4. If a constraint already recorded in `CLAUDE.md`, `README.md` or `ROADMAP.md` decides the question, there is no fork and no menu. Read those first.

Example:

```
Before I create the plan, I need a few things clarified:

1. Should the new endpoint require authentication?
2. Is there a preferred database (the project has both SQLite and Postgres configs)?
3. Should existing tests be updated, or only new ones added?
```

Wait for the user's response before proceeding.

---

## Phase 4 — Create `TODO.md`

Using the analysis, the classification, and the user's answers, write `TODO.md` in the project root.

### Structure

```
# TODO

## Goal
One sentence describing what will be built or fixed.

## Mode
Learning project (author writes the code, Claude reviews) — or — Standard (Claude writes the code).

## Tasks

### 1. <Phase Name>
- [ ] <Concrete, measurable action>
- [ ] <Concrete, measurable action>

### 2. <Phase Name>
- [ ] <Concrete, measurable action>
- [ ] <Concrete, measurable action>

## Notes
Constraints, decisions, or known risks.
```

### Requirements

- Tasks are small and independently verifiable — one logical change each.
- Tasks are ordered by dependency. Prerequisites come first.
- Each task is checkable as done or not done. No vague items like "fix things" or "improve code."
- On a learning project, each task is sized to one sitting for the author.

**The full plan is shown at once, and that is deliberate.** It is a proposal to agree on before any work starts — not a list of instructions to be executed without pausing. Execution in Phase 6 is one step at a time.

After writing the file, show its contents to the user and ask:

```
I've created TODO.md. Does this plan look correct?
Reply YES to start, or tell me what to change.
```

---

## Phase 5 — Revision Loop

If the user requests changes:

1. Ask targeted follow-up questions if needed to resolve the disagreement.
2. Rewrite `TODO.md`.
3. Show the updated plan and ask for approval again.
4. Repeat until approved.

---

## Phase 6 — Execute, One Step at a Time

Once approved, work through the tasks in order. **One task per message. Stop after each and wait.**

Two reasons for the pace, and they shape how each step is written: on a learning project the author has to actually do the work before the next step means anything, and on any project a step's result can invalidate what was planned after it. Stopping is what makes a pivot possible while it is still cheap.

### Every step opens with its place in the plan

Before the content of the step, show where it sits. For a short plan, one line:

```
Plan: 7 steps · done 1–2 · **now: 3 — wire the migration runner** · next: 4 — add the handler
```

For a plan with phases, the list, with completed items struck through and the current one bold:

```
1. ~~Scaffold the module~~
2. ~~Define the schema~~
3. **Wire the migration runner**  ← now
4. Add the handler
5. Seed and verify
```

Then state what this step is and, on a learning project, explain the approach rather than writing the implementation.

### Completing a step

- Mark it done in `TODO.md` by changing `- [ ]` to `- [x]`.
- On a standard project, that happens when you have finished it and verified what is mechanically verifiable.
- On a learning project, that happens when the author's implementation has been reviewed and is right. Not when you have explained it.
- Do not start the next task until the current one is complete.

### Pivoting

A step can change the plan, and that is a feature. Stop and say so when:

- **Something is harder or wrong** — an assumption in the plan does not hold, or a task turns out to depend on work nobody listed.
- **Something is easier than planned** — the discovery that a later task is now unnecessary, or that a simpler approach became available, is worth as much as finding a problem and is more easily missed.

In both cases: stop, add the change to `TODO.md` under `## Discovered Tasks` (or strike the tasks that are no longer needed, with a one-line reason), say what was found and why it matters, and wait for approval before continuing.

When all tasks are marked `[x]`:

```
All tasks in TODO.md are complete.
```
