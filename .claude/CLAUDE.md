## Communication
- Open by committing to the goal or the verdict before any supporting detail.
  One sentence usually carries it; expand to a short paragraph when compression
  would drop context I'd otherwise have to ask for — a "no" whose reason is
  load-bearing, a recommendation with a real caveat attached. Length is a
  ceiling, never a target. The requirement is the commitment up front, not the
  word count: an opener that hedges, previews, or restates the question has
  failed the rule regardless of how short it is.
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
  live in the zettelkasten, not here.
- Ask before installing anything — xbps packages, cargo binaries, npm globals,
  Neovim plugins. This machine is curated deliberately and I want to know what
  lands on it.
- Framework 13 AMD running Void Linux — glibc, runit, xbps. Not Debian, not
  Arch. Package names diverge from both, so don't infer an xbps name from a
  Debian one; check with `xbps-query -Rs`. The Framework's init is runit —
  systemd guidance applies to deploy targets, not this machine.
- Wayland-only, dwl v0.8 compositor — built from source at `~/projects/dwl`,
  branch `local`, with the bar and gaps patches applied. `config.h` is tracked
  deliberately via `git add -f`; upstream's `.gitignore` excludes it. Binary at
  `~/.local/bin/dwl`. No X11 fallbacks, no XWayland assumptions.
  `~/.config/hypr/` holds only `hypridle` and `hyprlock` — standalone wlroots
  tools, not Hyprland. I do not run Hyprland.
- dwl has no config reload; every `config.h` change needs logout and login.
  `cp` over `~/.local/bin/dwl` fails `ETXTBSY` while it's running — `rm -f` the
  target first. A `config.h` syntax error produces ~200 cascading "declared
  static but never defined" warnings from `dwl.c`; read the first error line and
  ignore the rest. wlroots scene rects use premultiplied alpha, so transparent
  means `0x00000000`, not zero-alpha-with-colour.
- Neovim (lazy.nvim), Kitty, zsh (zinit + starship + zoxide + fzf).
- Project sources in `~/projects/<name>/`.
- Binaries I build install to `~/.local/bin/` with `install -Dm755`. One
  exception: `~/.local/bin/frame` is a symlink into that repo's `target/`,
  which is why `cargo clean` there breaks live keybindings — see frame's
  own CLAUDE.md.
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
- New tools resolve XDG paths (`XDG_CONFIG_HOME`, `XDG_CACHE_HOME`,
  `XDG_RUNTIME_DIR`) with `~/.config`-style fallbacks rather than hardcoding.
- Dotfiles are a bare git repo with `$HOME` as the work tree. `~/.gitignore`
  ignores everything by default; tracking a new file means adding a `!` line
  first.

## Git
- Check `git status` before starting work. If the tree is dirty with changes I
  didn't just describe, say so and wait — don't fold my in-progress edits into
  your commit.
- Pull before editing. It's a no-op in repos only this machine writes to, and
  it's the difference between a clean start and a merge mess in ones where
  something else does — the zettelkasten syncs from iOS via `obsidian-git`.
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
- Auto memory (`~/.claude/projects/<project>/memory/`) is yours to write, not
  mine. Don't put anything there that belongs in a CLAUDE.md — if it's a rule
  I'd want permanently, say so and I'll put it in the right file.
- When you get something wrong and I correct you, propose the rule that would
  have prevented it and say which file it goes in. Don't write it silently.
