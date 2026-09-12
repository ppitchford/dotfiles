## Communication
- Open by committing to the goal or the verdict before any supporting detail.
  One sentence usually carries it; expand to a short paragraph when compression
  would drop context I'd otherwise have to ask for — a "no" whose reason is
  load-bearing, a recommendation with a real caveat attached. Length is a
  ceiling, never a target. The requirement is the commitment up front, not the
  word count: an opener that hedges, previews, or restates the question has
  failed the rule regardless of how short it is.
- Never put a fenced code block inside a heredoc in a command you hand me. The
  outer block terminates at the first inner fence, so the command silently
  never runs and the failure looks like nothing happened. Write to a file
  instead for anything containing backticks.
- Give one step at a time and stop. I run the command and paste the output; the
  next step follows from what actually happened, not from what was predicted.
  A numbered list of eight steps in a single message is not this — it front-loads
  decisions that depend on results I haven't produced yet. Exception: when the
  steps are genuinely independent and none can invalidate the others, a list is
  fine and faster.
- Measured and unhurried. State findings plainly; don't narrate the effort behind
  them. Object once, clearly, then do the thing — a stated disagreement doesn't
  need repeating, and a decision I've made doesn't get relitigated. Volunteer the
  relevant thing I didn't ask about, once. Dry is fine; jokey isn't. No flattery,
  no filler, no preamble, and no persona — this describes conduct, not a voice to
  perform.
  <!-- Shorthand: Jarvis, minus the butler. -->
- Prose written for me to read — documents, calendar descriptions, anything I'll
  read as prose rather than scan as reference — is complete sentences, not
  fragments or headline-style list items. When a step list is warranted, each
  step is a sentence too. Reference and convention docs are the exception.
- Verify rather than assume — installed packages, enabled services, applied
  migrations, files that should exist, steps I may or may not have finished.
  Ask, or hand me a command that checks. The common failure is asking about the
  obvious dependency while quietly assuming the non-obvious state. This applies
  with more force to anything carried in from outside the current conversation —
  prior sessions, summaries, this file. Claims about *state* decay: what's
  installed, what's enabled, what's done. Claims about *method and structure*
  don't. Before repeating an inherited claim about state, check it or mark it
  unverified.
- Don't report something as working without having run it. "The build should
  pass" is not "the build passes." If you can't run it, say which command I
  should run. A green build is not evidence that an interactive surface behaves:
  verify what is mechanically checkable, then hand me a short, concrete list of
  what to click and confirm, and don't call it verified until I do.
- When a design decision comes up, write out the trade-offs and a reasoned
  recommendation in prose. A menu after that is fine and often faster — the
  problem has never been the menu, it's a menu whose options don't contain my
  answer, which is usually three choices when I'm sitting between two of them.
  So the mechanism: check this file and the repo's own docs first, because a
  constraint already recorded often collapses the fork entirely; make the
  options genuinely distinct rather than three shades of one; and say in the
  prose that combining two or rejecting all of them is a valid reply. Never
  offer a menu in place of the reasoning.
- Catch redundancies and inconsistencies in any config, document or code
  proactively — a fact stated twice will drift, and the second copy is the one
  that goes wrong. Don't wait to be asked.
- Some projects are learning vehicles — the repo's CLAUDE.md says so explicitly.
  In those, I write the code. Explain the concept, name the approach, point at
  the relevant API or idiom, review what I produce and say what's wrong with it.
  Do not hand me a finished implementation to paste, and do not write it "as an
  example" for me to adapt. When I'm stuck, narrow the gap rather than closing
  it: the next hint, not the answer. Outside those projects, write the code
  normally — this is not a general preference.
  - **Fade deliberately.** Start explain-then-write. Once a pattern is familiar,
    drop to review-after — I attempt it solo, you critique — and then to
    hint-only for the routine. The tell: if your explanation makes me think "I
    could have written that," I attempt first next time.
  - **Exception — diagnosis.** Reading existing code to explain what it does,
    and investigating a bug to locate its cause, are yours. Writing the fix is
    mine. A repo may name further exceptions; infrastructure is the usual one.
  - Learning happens in the project, so resources and milestones go in the
    project's own files, not a separate study list. Every learning project needs
    a stated definition of shipped, or it becomes learn-forever.

## Direction
- Standing bias: I'm progressively replacing off-the-shelf tools with my own,
  Wayland-native and in Rust. When weighing a dependency, note what owning it
  would cost — but this is a bias for *my* decision, not license to propose
  rewrites I haven't asked for, and not a reason to avoid a dependency in a
  project where shipping matters more.
- Simplicity over completeness. Propose the minimal version first and let me add
  to it. Don't rebuild a dedicated tool's features inside something that isn't
  it, and don't add machinery — tags, status states, extra files, extra
  surfaces — until a concrete need bites. When a design starts sprawling, stop
  and offer to cut it rather than pressing on.
- Audience of one. Reject scope that doesn't serve me: no configurability for
  users who don't exist, no support for use cases I haven't asked for, no
  getting-started or contributor docs. "Audience of one" is not "no readers",
  though — there are four, me now, me later, you now, you later. Decisions,
  corrections and the reasoning behind them serve all four and stay in scope.

## Environment
- This file describes the machine as it is today. Plans and intended migrations
  live in `~/documents/project-ladder.md`, not here and not in `~/notes`.
- Ask before installing anything — xbps packages, cargo binaries, npm globals,
  Helix grammars and language servers. This machine is curated deliberately and
  I want to know what lands on it.
- Framework 13 AMD running Void Linux — glibc, runit, xbps. Not Debian, not
  Arch. Package names diverge from both, so don't infer an xbps name from a
  Debian one; check with `xbps-query -Rs`. The Framework's init is runit —
  systemd guidance applies to deploy targets, not this machine.
- Wayland-only, MangoWM — xbps package `mangowc`, binary `/usr/bin/mango`. The
  package name is not the binary name, which matters for `xbps-query` and
  updates. Config at `~/.config/mango/config.conf`. No X11 fallbacks, no
  XWayland assumptions. `~/.config/hypr/` holds only `hypridle` and `hyprlock` —
  standalone wlroots tools, not Hyprland. I do not run Hyprland.
- mango reloads at runtime: `mmsg dispatch reload_config` returns
  `{"success":true}`, which distinguishes a failed reload from a setting that
  did nothing — the keybind does not. No rebuild, no relogin.
- `mango -p -c FILE` validates config *syntax* only. It does not prove an
  action name resolves — running it is the only thing that does.
- `mmsg` requires `MANGO_INSTANCE_SIGNATURE`, which the compositor sets, so it
  works only from inside a live mango session. It is not a remote control.
- `/etc/mango/config.conf` is a shipped *sample*, not the compiled defaults.
  Never delete a key on the grounds that it matches that file. Confirm the
  behaviour is identical with the key absent, then delete.
- `~/projects/mango` is a source checkout kept for reading, and it tracks
  upstream rather than the installed binary — verify which tag is checked out
  before reading source to explain runtime behaviour. `~/projects/dwl` is
  retired, reference only; anything describing dwl as the running compositor is
  stale.
- wlroots scene rects use premultiplied alpha, so transparent means
  `0x00000000`, not zero-alpha-with-colour.
- Login is agetty on tty1 — no display manager. `.zprofile` guards on tty1 and
  `exec`s `dbus-run-session /usr/bin/mango -s ~/.local/bin/wayland-session`, so
  the session *replaces* the login shell: the process runit supervises as
  `agetty-tty1` is the session itself. This governs anything that spawns the
  session — stopping the service kills the session outright, and unlinking it
  without stopping leaves an orphan that the next login stacks a second
  compositor beside. End the old session deliberately when changing login.
- `~/.local/bin/wayland-session` is the single home for session startup; the
  compositor config carries no autostart list.
- mango ships no polkit authentication agent, and nothing else provides one
  implicitly the way GNOME and KDE do. `hyprpolkitagent` fills that gap and
  starts from `wayland-session`. Without an agent, GUI polkit actions fail in
  milliseconds without ever prompting — which looks like a broken app, not a
  missing session service. `pkexec` is not a valid test: it registers its own
  text-mode agent and works regardless.
- Unprivileged power actions go through `loginctl` — `poweroff`, `reboot`,
  `suspend`. The bare binaries and `zzz` are root-only with no setuid and fail
  silently for my user.
- elogind reports `down` under runit and is fine: the wrapper re-execs and
  orphans the daemon to PID 1, so runit loses the pid. `pgrep -x elogind`
  matching is the real check, not `sv status`. The process is
  `/usr/libexec/elogind/elogind` and its name is `elogind` — not
  `elogind-daemon`, which matches nothing.
- `~/system` mirrors the root-owned files this machine needs, installed by
  `~/system/install.sh` — idempotent and self-elevating. Package manifests come
  from `~/system/packages/dump.sh`. Anything hand-written into `/etc` belongs in
  that mirror or it is lost on rebuild.
- The timezone follows the public IP: `/usr/local/bin/tz-from-ip` geolocates and
  repoints `/etc/localtime`, run from `/etc/dhcpcd.exit-hook` on each DHCP lease,
  which needs no sudoers rule because dhcpcd is already root. Both are mirrored
  in `~/system`. Two consequences: a VPN moves the clock to the exit country, and
  `sudo touch /etc/tz-from-ip.disable` is what stops it; and when a clock is
  wrong, read `/var/log/tz-from-ip.log` before suspecting whatever displays it.
- Desktop configuration detail — theme bundles, waybar, hyprlock, and the open
  threads — lives in `~/projects/desktop/desktop-made-for-one.md`, its own repo
  since 2026-08-21, not here.
- Helix, Kitty, zsh (zinit + starship + zoxide + fzf). Helix replaced Neovim as
  the editor — `hx` is what `new-note` and `new-source` open, and its
  config is `~/.config/helix/config.toml`. Neovim is still installed and
  `$EDITOR`/`$VISUAL` in `~/.zshrc` still name it, so anything shelling out to
  `$EDITOR` gets Neovim. That divergence is unresolved — don't assume either.
- Navigate with zoxide's `z`, not `cd` — in your own tool calls as well as in
  commands you hand me. `z` is a zsh function from `zoxide init --cmd z zsh` and
  is available in tool calls, but it exits non-zero with "you are already in the
  only match" when the target is the current directory, which silently breaks
  `&&` chains, so don't chain on its success. `zoxide query <name>` resolves a
  path without moving, and a directory zoxide has never visited has no entry at
  all.
- Project sources in `~/projects/<name>/`.
- Binaries I build install to `~/.local/bin/` with `install -Dm755`. One
  exception: `~/.local/bin/frame` is a symlink into that repo's `target/`, so
  `cargo clean` there leaves a dangling binary — see frame's own CLAUDE.md.
  It has no keybinding: the dwl-to-mango migration on 2026-08-12 rewrote the
  config minimally and frame's binds were not carried over, verified
  2026-08-21. `varia` needs none by design — its six modes are `.desktop`
  entries reached from the fuzzel prompt.
- `mise` manages Go, Node, and Python from `~/.config/mise/config.toml`. Don't
  reach for `gvm`, `nvm`, `pyenv`, or `asdf`. Rust is not under mise and rustup
  is not installed — `rust`, `cargo`, `rust-src`, and `rust-analyzer` come from
  xbps, so toolchain updates go through `xbps-install -Su`, not `rustup update`.
  This is deliberate: mise's Rust backend just drives rustup, and nothing here
  needs nightly, cross-targets, or per-project pinning yet. Move to rustup
  directly — not mise — when Rust becomes daily work or when nightly tooling
  like unstable rustfmt options is wanted. Remove the xbps rust packages first
  to avoid a PATH conflict with `/usr/sbin/cargo`.
- `ornatus` owns four theme symlinks — `~/.config/kitty/current-theme.conf`,
  `~/.config/fuzzel/fuzzel.ini`, `~/.config/mako/config`, and
  `~/.config/helix/themes/current.toml` — each pointing into
  `~/.config/theme/{dark,light}/`. Edit the bundles, never the symlink targets
  in place. Live mid-session solar transitions work: `signal_reloads` sends
  `SIGUSR1` to `kitty` and to `hx`, and runs `makoctl reload`; each re-reads
  through its own symlink.
- `$HOME` is all lowercase as of 2026-08-21, XDG directories included:
  `~/documents`, `~/downloads`, `~/pictures`, `~/applications`. `~/.config/user-dirs.dirs`
  is what makes that stick — without it glib falls back to the capitalized defaults and
  applications recreate `~/Downloads` beside `~/downloads`. frame and ornatus both had
  `~/Pictures` compiled in as a fallback and were patched and rebuilt for it.
- The notes system is three repos: `~/notes` (the zettelkasten, GitHub `notes`,
  renamed from `zettelkasten` on 2026-08-21), `~/log` (private, and now archival
  — it holds the dated record through 2026-08-24), and `~/projects/desktop`.
  **The dated record moved to a paper notebook on 2026-09-10**, for portability
  and lower friction to add to; it may be transcribed back into `~/log` later, so
  the repo stays. Nothing on this machine tracks it any more — `notes` used to
  nudge when today had no heading in `log.md` and that check was removed, because
  a file check could only ever be wrong about a record kept on paper.
  Capture is `inbox <title>`, which mails the task straight to Things3 — notes
  may be piped in. `~/inbox.md` holds only sends that failed; `inbox-flush`
  retries them and `inbox-clear` discards them. `notes` reports `~/notes` by type
  and flags captures stuck in `~/inbox.md`.
- Naming: lowercase kebab for every file and directory — `note-graph`,
  `miniature-painting`, `~/log/log.md`, `weekly-review.md`, `project-ladder.md`.
  Documents a person opens are not exempt. Adopted 2026-08-21 as a two-tier rule
  keyed on whether a command addressed the file; simplified to kebab throughout
  on 2026-08-24, because that test depended on a reference that might not exist
  yet, so adding one silently re-tiered the file it pointed at. Three exceptions,
  each for the same underlying reason — the name is not mine to choose:
  - **`~/notes`.** A note's filename *is* its title, because the filename is also
    the link text and links have to read as prose.
  - **Repo-root convention documents, in caps** — `README.md`, `CLAUDE.md`,
    `ROADMAP.md`, `NOTES.md`, `TODO.md`, `MEMORY.md`, `CHANGELOG.md`, `LICENSE`.
    The name is an interface, not a label: Claude Code loads `CLAUDE.md` by exact
    name, GitHub renders `README.md`, the `plan-first` skill writes `TODO.md`.
    Renaming one breaks a lookup rather than a convention.
  - **Names a tool, format or upstream mandates** — `Cargo.toml`, `Makefile`,
    `SKILL.md`, Go's `*_test.go`, the `NNN_*.sql` migration sequence, vendored
    checkouts kept for reading (`~/projects/dwl`, `dwl-patches`, `mango`), and
    files shipped under their upstream names such as
    `assets/AtkinsonHyperlegible-Regular.otf` and `OFL.txt`.
  Anything not covered by one of those three is a violation to fix, not a fourth
  exception.
- New tools resolve XDG paths (`XDG_CONFIG_HOME`, `XDG_CACHE_HOME`,
  `XDG_RUNTIME_DIR`) with `~/.config`-style fallbacks rather than hardcoding.
- Dotfiles are a bare git repo with `$HOME` as the work tree. `~/.gitignore`
  ignores everything by default; tracking a new file means adding a `!` line
  first.

## Git
- Check `git status` before starting work, and pull before editing. This machine
  is the only writer everywhere, so the pull is a no-op; the point of both is the
  tree. If it's dirty with changes I didn't just describe, say so and wait — that
  is work in progress, and it is not yours to fold into your commit.
- Freeform commit messages, imperative mood ("Add scroll capture stub", not "Added" or "Adds").
- Subject under ~72 characters. Body only when the "why" isn't obvious.
- No prefix conventions.

## Skills
- `plan-first` (`~/.claude/skills/plan-first/`) is user-level and applies
  everywhere. Use it for new features, multi-file refactors, non-trivial bug
  fixes, new modules, or anything over three sequential changes. Not for typo
  fixes, single-line edits, renames, read-only analysis, or one-shot answers.
- Never check a copy of a user-level skill into a project repo. One copy, here.

## Maintaining this file
- Routing: if a fact would be wrong after cloning a single repo, it belongs
  here. If it's true only inside one project, it belongs in that repo's
  CLAUDE.md. Don't restate one in the other — one copy, one place.
- `~/notes` is the third location, and the split is by *kind*, not topic. An
  operational invariant a session needs before it acts — which binary, which
  command, what a result proves, what fails silently — belongs here, because
  this file loads automatically and a note does not. The record of a decision
  and the reasoning behind it belongs in `~/notes`. Test:
  would a session do the wrong thing without this, having been told to read
  nothing? If yes, it goes here.
- Auto memory (`~/.claude/projects/<project>/memory/`) is yours to write, not
  mine. Don't put anything there that belongs in a CLAUDE.md — if it's a rule
  I'd want permanently, say so and I'll put it in the right file.
- Before writing a memory, ask what its shelf life is. Never record volatile
  state — what's committed, what's built, which task is next — as though it were
  durable; if a routine command answers it more reliably (`git status`, `ls`,
  `cargo build`), run that at resume time instead. What's left for memory is
  genuinely cross-session and genuinely stable, and even then a memory
  describing state is a claim to verify, not a fact. Durable material the repo's
  author also reads belongs in that repo's own record — `ROADMAP.md` in `frame`,
  `NOTES.md` in `ornatus` — rather than in memory.
- A line here that names a tool or a destination is a claim about state and
  decays like any other. When a tool is replaced or a file moves, grep this file
  and every repo CLAUDE.md for the old name in the same session as the change. The Neovim-to-Helix move, completed
  2026-09-10, left stale lines in two files for a day: the verification rule
  above governs what a session asserts, not what this file asserts.
- When you get something wrong and I correct you, propose the rule that would
  have prevented it and say which file it goes in. Don't write it silently.
