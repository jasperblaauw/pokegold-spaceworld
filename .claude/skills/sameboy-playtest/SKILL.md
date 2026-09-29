---
name: sameboy-playtest
description: Playtest a change yourself in the SameBoy emulator instead of asking the user to. Builds the debug ROM, launches it in SameBoy, and drives the game with computer-use (keypresses + screenshots) to verify the feature. Use whenever a change is PLAYTEST-PENDING, after build-verifying gameplay/UI/text/map changes, or when the user says "playtest", "test it in SameBoy", or "check it in the emulator".
---

# Playtest in SameBoy

Goal: verify a gameplay change by playing it, then report what you actually saw. This replaces
"please playtest X" hand-offs. It does **not** replace build verification. Build first, and only
call a behaviour "works" once you have seen it on screen.

## 1. Build

```sh
make -j8 gold_debug silver_debug gold silver   # never bare `make` (compare is expected to fail)
```

Fix any errors or warnings before going further. The ROM to test is always
**`pokegold-spaceworld-debug-correctheader.gb`**. The base `.gb` is stamped MBC1 and misbehaves
because the game drives an RTC. Use `pokesilver-spaceworld-debug-correctheader.gb` only if the
change is Silver-specific.

## 2. Protect the user's save data

SameBoy writes battery saves next to the ROM (`.sav`), and the user's save states are there too
(`.s1`–`.s5`). Before launching, back them up to the scratchpad:

```sh
cp pokegold-spaceworld-debug-correctheader.sav "$SCRATCH/sav-backup.sav" 2>/dev/null
```

- Do **not** save the game in-game unless the test needs it. If it does, restore the backup
  afterwards unless the user says to keep the new save.
- The `.sav` **always** differs after a session, even without saving: the game uses SRAM as
  scratch space (`sScratch`/sprite buffers at file offset `0x000–0x607`, the window stack at
  `0x1800–0x1fff`), and SameBoy rewrites the RTC footer past `0x8000`. Only a change in
  `sGameData` (`0x608–0xe50`) or banks 1–3 (`0x2000–0x7fff`) means the real save changed. SameBoy
  flushes the file on close/reset, so restore only after closing the ROM window (cmd+W).
- Do **not** write to save-state slots 1–5. Use slot 9 if you need a checkpoint.

## 3. Launch

Open the ROM directly. No file dialog is needed:

```sh
open -a SameBoy pokegold-spaceworld-debug-correctheader.gb
```

If SameBoy was already running an older build, first reset it with **cmd+R** (Emulation ▸ Reset)
after the rebuild, or close the window (cmd+W) and run `open` again, so the new ROM is loaded.

Then, with computer-use:
1. Load the tools in one call: `ToolSearch {query: "computer-use", max_results: 30}`.
2. `request_access` for **SameBoy** (it gets the "full" tier).
3. `open_application` SameBoy, then take a `screenshot` to find the game window.
4. From then on, use `zoom` on the game window's rectangle to read the screen. The Game Boy
   screen is only 160×144, so full-screen screenshots are too coarse for text.

## 4. Controls (this machine's SameBoy bindings)

| Game Boy | Key        | Note |
|----------|------------|------|
| D-pad    | arrow keys | `up` `down` `left` `right` |
| **A**    | `z`        | user's custom binding (A and B are swapped from SameBoy's default) |
| **B**    | `x`        | |
| Start    | `return`   | |
| Select   | `delete`   | backspace |

If a button does nothing, check SameBoy ▸ Preferences ▸ Controls and update this table.

**Press with `hold_key`, not `key`.** The game polls the joypad once per frame, so an instant tap
can land between polls and be dropped. Use `hold_key` with `duration: 0.1`. For walking N tiles,
hold the direction for about `0.27 * N` s, or do N separate 0.1 s taps and then check the screen.
Combos are chords: Start+B = `hold_key "return+x"`.

Batch predictable sequences in `computer_batch`, for example
`[hold_key z 0.1, wait 0.3, hold_key z 0.1, wait 0.3, zoom <game rect>]`, and zoom at the end of
every batch. Text boxes print letter by letter, so wait about 0.5 s before reading one, and press
A to advance.

Verified timings: menu cursor moves are fine at `0.1` s hold + `0.15–0.3` s wait. The **Start menu
takes about 1.5 s to appear**, because it hides NPC sprites first. A zoom sooner shows the overworld
with NPCs missing; that isn't a bug. Warps and map loads take about 2–3 s. When walking, a
held direction goes about 2 tiles per 0.5 s, and it stops silently at walls, so zoom after each leg.

## 5. Get to the thing under test

Choose the shortest route:

- **Title screen ▸ Select** → title debug menu (debug builds only): FIGHT / FIELD / SOUND /
  SUBGAME / MONSTER / NAME, top to bottom (FIELD = `down`, A).
  From boot, press Start until the title is up, then **zoom to confirm the title before pressing
  Select**. After cmd+R the intro timing varies, and a Select during the intro is ignored.
  - **FIELD** → `DebugSetUpPlayer`: all badges and mons, story pre-completed, noclip. Best for
    warp-testing, maps, menus and items. It is **not** representative of a normal playthrough
    (story flags are forced).
  - **FIGHT** → battle test menu.
- **Title ▸ Start/A → New Game** → Oak intro → PLAYER_HOUSE_2F. Use this path for story, event
  and flag behaviour.
- **In the overworld, Start+B** opens the field debug menu in any debug build (warps via
  `data/maps/debug_warps.asm`, items, etc.) without setting the demo flags.
- **Up+B+Select on the title screen clears SRAM.** Don't press it by accident.

Field debug menu (Start+B) order: NEXT / WARP / CHARA / RIDE / TOOL / PC / CLOSE.
**Both the field debug menu and the WARP list remember their last cursor within a session**, so
the blind `down, A` path only works on the first use after boot. Otherwise zoom and navigate by
what's on screen. WARP lists
spawn points in `data/maps/debug_warps.asm` order (SILENT, OLD, WEST, HIGH-TECH, …). The player
lands on the spawn tile from `data/maps/spawn_points.asm`. Read a map's `warp_event`s and
`object_event`s in `maps/<Map>.asm` to plan a route, and remember NPCs behind counters are
talked to from across the counter tile.

Verified routes (FIELD start: ₽999999, player "KOJI", full debug bag):
- **Old City Mart**: title ▸ Select ▸ FIELD → Start+B ▸ WARP ▸ OLD (lands at 27,29 by the
  PokéCenter) → left ~1.5 s (fence stops you) → up 1 → left ~4 s (trees stop you) → up 1 →
  left ~2.5 s → up into the SHOP door. Inside: up ~1.1 s, left 1, left again to face the
  counter, then A talks to the clerk at (1,3).

If the user left a save state that already sits at the right spot, loading it from the
File/Emulation menu is fine. Ask before overwriting it.

## 5b. Window layout and the debugger

The user may rearrange windows (for example, the Debug Console docked under the game). **Take a fresh
`screenshot` after any surprise and re-derive the game rectangle**; never reuse old coordinates. If
a batch fails because another app is in front, `open_application SameBoy` and re-screenshot.
Click the game window's title bar before sending game keys, because keys typed while the console
has focus land in its input line.

SameBoy's debugger (Develop ▸ Show Console; ctrl+C in the game window breaks) is the best tool for
hangs:
- break during the hang → the backtrace names the stuck routine (symbols load from the `.sym`).
- `print [wSymbol]` reads RAM; `watch/w wSymbol` breaks on the next write and shows the writer.
- `unwatch`, then `continue`, resumes. Clear leftover input with cmd+A, delete before typing.
Example: the trainer card hang was found by breaking (stuck in `PrintLetterDelay`), reading
`wTextboxFlags` = `$2`, then `watch/w` → `FieldDebug_ShowWarpToText`'s text script.

## 6. Test like a playtester

- Exercise the **exact** path the change touches, plus the edge paths: cancel/B-out, the
  empty/full cases, leaving and re-entering the map, reopening the menu. Most past bugs here were
  on the `.cancel` path or on exit (stale tiles, garbage sprites, font not restored).
- Check each text box against the 18-column limit and look for broken line breaks or garbage glyphs.
- After closing a full-screen menu, look for corrupted sprites or tiles in the overworld.
- If the game hangs, shows garbage, or crashes: take a zoom as evidence, note the exact input
  sequence, then use the `.sym` file (`pokegold-spaceworld-debug.sym`) to form a hypothesis.
  Fix it, rebuild, and re-test by resetting (cmd+R). Relaunching is not necessary.
- Dropped inputs happen now and then (a `down` in a long chain). Zoom to confirm the cursor
  **before** any A that commits something (buy, confirm, save).
- Keep sessions focused. If you are more than about 40 inputs in without progress, stop and tell
  the user what you tried rather than wandering.

## 7. Report and clean up

- Report per feature: **PASS** (what you saw, in which state), **FAIL** (inputs → observed vs
  expected), or **NOT REACHED** (why). Never upgrade an unobserved behaviour to PASS.
- Anything you couldn't judge visually (sound, timing feel, colours on real hardware) stays
  PLAYTEST-PENDING for the user.
- Restore the `.sav` backup if you changed it, and leave SameBoy open unless the user wants it closed.
- Update `docs/completion/HANDOVER.md` "NEXT UP" if the result changes what's pending.
