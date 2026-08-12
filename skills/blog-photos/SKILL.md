---
name: blog-photos
description: Pull photos from the local iCloud Photos mirror into a Jekyll blog post — list candidates by date, review them visually, convert HEIC to JPEG, resize, strip EXIF, and emit the image markup. Use when drafting a post for jlbrooks.github.io that needs photos, or when the user mentions adding pictures from their phone/iCloud to the blog.
---

# Blog photos from iCloud

Two pieces: `icloud-sync` mirrors iCloud Photos to `~/Pictures/icloud/`, and `blog-photos` moves selected shots into a post in `~/projects/jlbrooks.github.io`.

## Before anything else: is the mirror current?

The library only holds the last 30 days, and syncing needs a session that Apple expires monthly.

```bash
ls ~/Pictures/icloud/$(date +%Y) | tail -3   # newest day present
icloud-sync                                  # incremental, unattended
```

If sync fails on auth, **stop and hand it to the user** — re-auth needs a TTY and a 2FA code, so it cannot be done from an agent session. Tell them to run `icloud-sync --auth`, and that when no code arrives they must put the iPhone in **Airplane Mode**, then Settings → [name] → Sign-In & Security → Get Verification Code. That option is hidden while the phone is online. Full runbook lives in the Obsidian vault at `14. Tools and Systems/14.11 Linux desktop/iCloud Photos sync.md`.

## Workflow

### 1. Find candidates

```bash
blog-photos list 2026-08-06              # one day
blog-photos list 2026-08-01..2026-08-06  # range
blog-photos list 7d                      # last N days
```

Prints stem, dimensions, size, day, and `[live]` for Live Photos.

### 2. Actually look at them

Do not pick from filenames. Generate thumbnails and read the images:

```bash
blog-photos thumbs 2026-08-06 --out <scratchpad>/thumbs
```

Then use the Read tool on the generated JPEGs. Read them all before proposing a set — a shot list chosen blind is worthless to the user. Propose picks with a one-line reason each and let the user confirm before importing.

### 3. Import

```bash
blog-photos import --slug 2026-08-06-mt-hood --range 2026-08-06 \
  IMG_4776:summit-ridge IMG_4775:lake-basin IMG_4771
```

`IMG_4776:summit-ridge` renames on the way in. **Always give descriptive names** — the archive uses `castle-peak.jpg`, not `IMG_4776.jpg`. Bare `IMG_4771` keeps the camera name, which is a fallback, not the default.

Output goes to `assets/img/<slug>/`, and the markup is printed to stdout for pasting into the post.

Useful flags: `--max-edge` (default 2000), `--quality` (default 85), `--format md` for `![](...)` instead of HTML.

## Conventions in this blog

- Posts live in `_posts/YYYY-MM-DD-slug.md`; the image directory slug matches the post filename slug.
- Frontmatter: `layout: post`, `title`, `subtitle`, `tags`, `comments: true`.
- Image markup is `<img src="{{site.url}}/assets/img/<slug>/name.jpg" alt="..."/>` — this is the default and matches ~23 posts. One recent post uses markdown `![](/assets/img/...)`; use `--format md` only if the user asks.
- Weekly posts are titled `M/D/YYYY Weekly what's up` with `tags: [weekly-whats-up]`.

## What the tool handles for you

- **HEIC → JPEG.** About a third of the library is HEIC, which browsers cannot render. Never copy a `.HEIC` into the repo by hand.
- **EXIF stripped, including GPS.** The originals carry home coordinates. Orientation is baked into the pixels first, so nothing rotates.
- **Downsized to 2000px long edge.** Originals are 7-10MB each; output is around 0.6MB. `assets/img/` is already ~438MB, so do not bypass this by copying originals.

## Live Photos

`_HEVC.MOV` files next to a still are Live Photo motion components. The blog ignores them — the user does not want playable encodes. `list` flags them `[live]` for awareness only.

## Gotchas

- Import writes into a real git repo. Check `git status` after; never commit unless asked.
- `rm -rf` in `~/projects` is blocked by a safety hook. Ask the user to remove stray directories themselves.
- The library is a 30-day window. Photos older than that need `ICLOUD_WINDOW` widened in `~/.config/icloud-sync/config` plus a full rescan, which is slow — confirm with the user first.
