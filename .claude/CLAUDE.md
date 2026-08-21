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
  should run.
- Some projects are learning vehicles — the repo's CLAUDE.md says so explicitly.
  In those, I write the code. Explain the concept, name the approach, point at
  the relevant API or idiom, review what I produce and say what's wrong with it.
  Do not hand me a finished implementation to paste, and do not write it "as an
  example" for me to adapt. When I'm stuck, narrow the gap rather than closing
  it: the next hint, not the answer. Outside those projects, write the code
  normally — this is not a general preference.

## Direction
- Standing bias: I'm progressively replacing off-the-shelf tools with my own,
  Wayland-native and in Rust. When weighing a dependency, note what owning it
  would cost — but this is a bias for *my* decision, not license to propose
  rewrites I haven't asked for, and not a reason to avoid a dependency in a
  project where shipping matters more.

## Environment
- This file describes the machine as it is today. Plans and intended migrations
  live in the vault at `~/notes`, not here.
- Ask before installing anything — xbps packages, cargo binaries, npm globals,
  Neovim plugins. This machine is curated deliberately and I want to know what
  lands on it.
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
- Desktop configuration detail — theme bundles, waybar, hyprlock, and the open
  threads — lives in `~/projects/desktop/Desktop made for one.md`, its own repo
  since 2026-08-21, not here.
- Neovim (lazy.nvim), Kitty, zsh (zinit + starship + zoxide + fzf).
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
- `ornatus` owns the theme symlinks: `~/.config/kitty/current-theme.conf`,
  `~/.config/fuzzel/fuzzel.ini`, and `~/.config/mako/config` each point into
  `~/.config/theme/{dark,light}/`. Edit the bundles, never the symlink targets
  in place. Live mid-session solar transitions work — `signal_reloads` fires
  `makoctl reload` and mako re-reads through the symlink.
- `$HOME` is all lowercase as of 2026-08-21, XDG directories included:
  `~/documents`, `~/downloads`, `~/pictures`, `~/applications`. `~/.config/user-dirs.dirs`
  is what makes that stick — without it glib falls back to the capitalized defaults and
  applications recreate `~/Downloads` beside `~/downloads`. frame and ornatus both had
  `~/Pictures` compiled in as a fallback and were patched and rebuilt for it.
- The notes system is three repos: `~/notes` (the zettelkasten, GitHub `notes`,
  renamed from `zettelkasten` on 2026-08-21), `~/log` (the dated record, private),
  and `~/projects/desktop`. Capture is `~/inbox.md` via `inb`, flushed to Things3 by
  hand; `notes` reports the vault by type.
- Naming: lowercase kebab for directories and for any file a command addresses by
  path — `vault-graph`, `miniature-painting`, `~/log/log.md`. Documents only a person
  opens keep their title as the filename, capitals and spaces included — `SDFWA
  onboarding notes.md`. When a file is both, the machine-facing form wins: a person
  reads `log.md` fine, a shell pays for the capital every time. The zettelkasten is the
  deliberate exception — a note's filename *is* its title, because the filename is also
  the link text and links have to read as prose. Adopted 2026-08-21.
- New tools resolve XDG paths (`XDG_CONFIG_HOME`, `XDG_CACHE_HOME`,
  `XDG_RUNTIME_DIR`) with `~/.config`-style fallbacks rather than hardcoding.
- Dotfiles are a bare git repo with `$HOME` as the work tree. `~/.gitignore`
  ignores everything by default; tracking a new file means adding a `!` line
  first.

## Git
- Check `git status` before starting work. If the tree is dirty with changes I
  didn't just describe, say so and wait — don't fold my in-progress edits into
  your commit.
- Pull before editing. This machine is the only writer everywhere now — the iOS
  phone and `obsidian-git` went with Obsidian on 2026-08-19 — so it is a no-op,
  but a dirty tree means work in progress that is not yours to commit.
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
- The vault at `~/notes` is the third location, and the split is by *kind*, not
  topic. An operational invariant a session needs before it acts — which
  binary, which command, what a result proves, what fails silently — belongs
  here, because this file loads automatically and the note does not. The
  record of a decision and the reasoning behind it belongs in the vault. Test:
  would a session do the wrong thing without this, having been told to read
  nothing? If yes, it goes here.
- Auto memory (`~/.claude/projects/<project>/memory/`) is yours to write, not
  mine. Don't put anything there that belongs in a CLAUDE.md — if it's a rule
  I'd want permanently, say so and I'll put it in the right file.
- When you get something wrong and I correct you, propose the rule that would
  have prevented it and say which file it goes in. Don't write it silently.
