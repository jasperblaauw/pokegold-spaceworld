# feature/completion — Session Handover

**Living baton between Claude sessions.** This project extends the Space World '97 demo into a
fuller, playable English adventure. Read this first. Keep it lean: **durable pitfalls, what's next,
and the plan** — nothing else. Per-round fix/playtest history lives in `git log`, not here. When you
finish work, fold any *new durable* lesson into "Common pitfalls" and update "NEXT UP"; don't append a
session changelog.

Authoritative plans: `~/.claude/plans/in-docs-you-hinted-linear-hearth.md` (content) and
`~/.claude/plans/continuing-from-docs-completion-handover-compiled-trinket.md` (localization).
Narrative target: `docs/index.html` §2/§3 ("Story of Nihon"). English strings: `docs/_glossary/`.

Branch: `feature/completion`. We have **abandoned the `make compare` byte-match guarantee** — this is
a downstream romhack now. Correctness = **builds warning-clean + boots & plays in SameBoy**. Do
**not** touch `roms.sha1`.

- **BUILD-VERIFIED** = assembles, links, bytes confirmed in the symbol map / decoded from the ROM.
- **PLAYTEST-PENDING** = needs SameBoy. Claude can playtest itself via the `sameboy-playtest` skill
  (`.claude/skills/sameboy-playtest/`, computer-use); anything it couldn't observe stays pending for
  the user. Never claim a gameplay behaviour "works" without a playtest.

---

## Standing build rules (every session)

- Build: `make -j8 gold_debug silver_debug gold silver`. **Never run bare `make`** (it invokes
  `compare`, which is expected to fail now).
- **Test the `-correctheader` DEBUG ROM in SameBoy** (`pokegold-spaceworld-debug-correctheader.gb`).
  The base `.gb` is stamped MBC1 (`0x0147=03`) to match the original dump, but the game drives an RTC
  (MBC3) — the base ROM misbehaves on an accurate emulator. `-correctheader` is re-stamped
  MBC3+TIMER+RAM+BATTERY with a corrected global checksum, and is the actually-runnable build.
- Keep `-Weverything -Wtruncation=1` clean. RGBDS pinned **v1.0.3** (`.rgbds-version`).
- **ROM is at 100% capacity** (1 MB, 64 banks). Anything you add needs space reclaimed — see below.
- Verify new code by decoding it back out of `pokegold-spaceworld-debug.gb` (label → `.sym` → bytes).

---

## Common pitfalls & solutions (the durable part — read before editing)

### ROM space
1. Linker says `section ... would overflow ROMX by N bytes` → in `garbage/garbage.asm` find that
   bank's section and trim N bytes from **each** padding variant (usually 4: gold/silver × debug/normal)
   by skipping: `INCBIN "...", N` (or bump an existing `, n` to `n+N`). No file sizes needed.
2. Assembler says `Section ... grew too big (max size = 0x4000)` → **garbage-trimming will not help**;
   the section itself exceeds one bank and a section can never span banks. Look for dead code in that
   file first (grep the label codebase-wide for zero callers; several pret-flagged
   `Unreferenced_*` Gen-1 leftovers have already been deleted this way), then tighten wording.
3. For **large** additions, delete a whole `"Bank NN Garbage"` block for one of the empty banks and add
   a real `SECTION "...", ROMX` there, registered under the matching `ROMX $NN` in `layout.link`; new
   `.asm` files go in `ROM_OBJ` in the `Makefile`. (Bank `$35` was converted this way for
   `SECTION "Silent Hill Town"`; **~2.5 KB of it is still spare** for M1c/M1d content.)
   Remaining fully-empty banks: `$20,$22,$28–$2e,$3d`.
4. **A map's attributes, blocks, text pointers and script loader must all live in one bank** — `map`
   emits a single `db BANK(\1_MapAttributes)` and `map_attributes` emits bare 16-bit `dw`s. Move
   `maps/X.asm` and `maps/scripts/X.asm` together.
5. Bank `$34`'s garbage is a fragile corrupt-data *reconstruction* with offset arithmetic — **only** the
   trailing `INCBIN "garbage/[debug/]bank34_*.2bpp", N` lines are safe to trim.
6. Reclaim with deliberate margin so the next batch doesn't need a round-trip.

### Text engine (read before translating or editing any text file)
- `PlaceString` stops at a literal `@` and returns to `TextCommandProcessor`, which reads the **next
  byte as a raw opcode index** (`TX_START`=0, `TX_RAM`=1, `TX_NUM`=9, `START_ASM`=8, `TX_END`=$50). It
  does **not** understand `<LINE>`/`<PARA>`/`<CONT>`/`<NEXT>`/`<PROMPT>` — those are charmap tokens
  recognised only *inside* an active `PlaceString` run.
- **Rule:** a literal `text "...@"` must end in `@` iff another command (`text_from_ram`, `deciram`,
  `text_move`, `start_asm`, a fresh `text`, `text_end`) follows immediately.
- **The rule that will bite you:** a bare `line`/`cont`/`para` directly after `text_from_ram`/`deciram`
  is **broken** — the `<LINE>` byte is read as a top-level opcode (garbage jump / halted script).
  Insert a bare `text_start` between them. Grep a file for `text_start` before `line` as the template.
  Symptom when it bites: `TEXT_DELAY_F` is left set in `wTextboxFlags`, and every later `PlaceString`
  waits a frame per letter, so an LCD-off screen (the trainer card) hangs white. The debug WARP text
  had this. Scan the whole tree with: `awk` for `text_from_ram|deciram` directly followed by
  `line|cont|para|next|prompt|done` (0 hits as of the WARP fix).
- `TEXTBOX_INNERW` = **18** columns. Inline dict tokens expand at render time: `<PLAYER>`/`<RIVAL>`/
  `<MOM>`/`<TRAINER>`/`#` = 7, `<USER>`/`<TARGET>`/any mon name = 10, `<ROCKET>` = 6, `<PC>`/`<TM>` = 2,
  `<⋯⋯>` = **2** (it's two three-dot glyphs). Item/move/trainer-class names = up to 12.
  **Give a name its own row whenever it would share one with more than ~8 characters.**
- Dict tokens are 1 byte regardless of rendered width — prefer them over spelling words out.
- **`<NEXT>` steps TWO rows in this engine**, not one (`home/text.asm`: `ld bc, 2 * SCREEN_WIDTH`).
  This is a proto/retail difference and it is load-bearing in several screens (the dex height/weight
  rows are 6 and 8; the search menu's options land on rows 12/14/16 to match its cursor table). It
  also means you *cannot* use `next` to reach the row directly below — and that a `next` from row 0
  lands on row 2, i.e. straight onto a box's top border.
- **Move/item descriptions** print into a **2-row × ≤18-col** box with `<NEXT>` stepping 2 rows.
  `data/moves/descriptions.asm` and `data/items/descriptions.asm` are both fully English now; any new
  screen showing a description inherits this box shape.
- **Rebuild the two tools before translating anything else** (they live in the session scratchpad and
  are cheap to recreate):
  - a **width linter** that expands the tokens above plus `text_from_ram` targets and reports
    worst-case row width — it once found four latent overflows in files earlier sessions had signed
    off. Keep a `KNOWN_OK` set of hand-verified false positives so re-runs are silent.
  - a **ROM text decoder** (label → `.sym` → charmap decode, plus a hexdump mode) for verifying
    emitted bytes. Charmap note: build the byte→glyph map so later Latin aliases win over the kana.

### Menus opened straight after an overworld textbox (read before adding any shop/menu to a map)
- Closing an overworld textbox runs `TextboxCleanup → ReloadObjectGFX → LoadWalkingSpritesGFX`,
  which reloads the walking-sprite frames **over the font in `vFont`**. So a menu drawn immediately
  after (e.g. a mart's BUY/CANCEL box opened right after the "Welcome!" `prompt` closes) renders its
  text as **sprite garbage**. Fix: `call LoadFont` before the first `PrintText`/menu draw (see
  `OldCityMartMenu` in `maps/OldCityMart.asm`). The box-frame tiles and font-extras live in
  `vChars2` and survive, so only the main font needs restoring; a downstream `callfar` menu inherits
  it as long as nothing between clobbers `vFont` again. The **debug** field mart never showed this
  because it runs inside an already-fonted menu context, not off the overworld.
- **Also disable `hMapAnims` for the duration.** A full-screen menu opened off the overworld leaves
  `hMapAnims` on, so VBlank keeps calling `_AnimateTileset`, which `jp hl`s through
  `wTilesetAnim`/`hTileAnimFrame` — state a full-screen redraw disturbs → intermittent `jp $0000` crash
  when a VBlank lands during a long CPU stretch. Every other full-screen menu (trainer card, party,
  pokédex, stats) does `ldh a,[hMapAnims] / push af / xor a / ldh [hMapAnims],a` on entry and restores
  on exit; `RunMartBuyMenu` now does too. Do the same for any new full-screen menu reached from the
  overworld.
- **End with `CloseText` (or `TextboxCleanup`) to restore the overworld.** A full-screen menu run
  from a map/talk script clobbers the walking-sprite VRAM (`LoadFont`/menu tiles land in `vFont`) and
  the tilemap (`ClearTileMap`). The welcome box's `OpenTextbox` runs its `TextboxCleanup` **before**
  the menu, so that early cleanup is useless; if the routine then returns straight to the overworld
  (e.g. via `MenuTextBoxBackup`, which only closes the window), the sprites redraw from garbage tiles
  and stale menu tiles linger — until the next `ReanchorMap` (opening the start menu "fixes" it). The
  fix is one `call CloseText` on the way out. Debug-menu-hosted equivalents don't need it because the
  field debug menu reloads the overworld on exit.

### VRAM bandwidth (read before optimising any "why is this screen slow" complaint)
- **Before counting frames, find the frame the user actually sees.** The overworld runs with the
  window layer enabled (`LCDC_DEFAULT` = `… | LCDC_WIN_9C00 | LCDC_WIN_ON`, `hWX` = 7), and
  `ReanchorBGMap_NoOAMUpdate` uses it as a freeze-frame: snapshot the map into `vBGMap1`, `hWY` = 0 to
  cover the screen, rebuild `vBGMap0` underneath, `hWY` = `SCREEN_HEIGHT_PX` to reveal. **Everything
  before that last store is free wall-clock; everything after it is on screen.** So where the reveal
  sits in the routine matters more than how fast any of the copying is — three rounds were spent
  optimising copies before anyone checked. When a screen "takes ages to appear", check the
  `hWY` ordering *first*, then start counting `DelayFrame`s. Corollary: work that writes VRAM nothing
  on screen is currently reading (the font, which lands in the walking-sprite half while the objects
  are frozen) belongs **after** the reveal.
- **A HRAM shadow is not the hardware register.** `hWY`/`hSCX`/`hSCY`/`hBGMapMode`/`hBGMapAddress` are
  copied into the real registers by VBlank on its own schedule. Any raw out-of-VBlank VRAM write that
  depends on one having taken effect needs an explicit `DelayFrame` (or `WaitBGMap`) after the HRAM
  write — setting the shadow does not update the hardware.
- **Count `DelayFrame`s, not routines.** Every bulk VRAM write goes through `Request2bpp`/`Request1bpp`,
  which copy **8 tiles per VBlank and burn one extra frame draining the last chunk**. So a copy of
  `n` tiles costs `ceil(n/8) + 1` frames. `WaitBGMap` is a flat **3** (`AutoBgMapTransfer` does a third
  of the screen per VBlank). Add them up before theorising — the answer is usually one loop you didn't
  suspect, not the one being blamed.
- **Do not raise the 8-tile chunk.** `VBlankCopyDouble` costs ~65 M-cycles per tile, so 8 tiles is
  ~520 of the ~1140 M-cycles in DMG VBlank; OAM DMA (~160), `AnimateTileset` and `Joypad` take most of
  the rest. 12 tiles overruns VBlank and corrupts whatever it was writing. `Request1bpp`/`Request2bpp`
  do force `hBGMapMode` to 0 for the duration, so `AutoBgMapTransfer` at least is not competing.
- **`DisableLCD` freezes VBlank — and therefore the music.** With the LCD off no VBlank/STAT
  interrupt fires, so `UpdateSound` stops and any `DelayFrame` hangs forever. A long CPU stretch under
  `DisableLCD`/`EnableLCD` (e.g. a pic decompress) is an audible music stall even though the copies are
  fast. Keep the LCD-off window to the **VRAM writes only** — `Get2bpp`/`FarCopyData`/interlace merges
  that need mode-3 protection — and do decompression and RAM/SRAM copies with the LCD *on* first
  (blank the palettes so it's not visible). (Trainer Card BADGES→CARD split the protagonist-pic
  decompress out of the LCD-off window this way to kill a stall without reintroducing a white flash.)
- **The escape hatch is writing outside VBlank.** VRAM is only locked in mode 3, so
  `ldh a, [rSTAT] / and STAT_BUSY / jr nz` before each store lets a fill or copy run during HBlank as
  well — roughly a frame's worth of throughput per *four* frames of `Request2bpp`. Two live examples:
  `ReanchorBGMap_NoOAMUpdate.Transfer` and `Pokedex_PrintSelectedNumber`.
  - **The catch:** an interrupt landing between the test and the store drops that byte, and this build
    takes a **STAT interrupt every scanline** (`rSTAT` = `STAT_MODE_0` at init, `IE_STAT` set), so it is
    not a theoretical risk. Wrap the loop in `di`/`ei` when a lost byte would be visible; skip the `di`
    only when it provably would not be (`.Transfer` writes an off-screen margin that the following
    `WaitBGMap` repaints anyway). Never hold `di` for thousands of bytes.
- **`hBGMapMode` is off more often than you think.** `WaitBGMap` sets it; `WaitForAutoBgMapTransfer`
  **clears** it. Screens that end their redraw with the latter — the Pokédex listing does — leave the
  automatic transfer off, so any later `PlaceString`/`PrintNumber` writes the tilemap and *nothing
  happens on screen* until the next full redraw. Symptom: "it only updates when I open a menu".

### Layout / box geometry
- `DrawTextBox hl, b, c` → interior `[x+1, x+c]` on rows `[y+1, y+b]`.
- A `menu_coords x1,y1,x2,y2` vertical menu gives **`x2 - x1 - 2`** text columns, *including* the
  cursor column.
- **`PlaceString` never wraps.** Anything past col 19 continues on the next tilemap row (this is what
  "wraps mid-word and spills to the bottom-left" always means).
- **Never size a box from a label address.** The original code did `ld bc, TextCommands` as an 18×13
  dimension pair; any ROM0 edit silently resized it. Use `lb bc, ...` with real constants, and grep for
  other `ld bc, <label>` used as dimensions if a mystery clipping appears.
- Anything drawn only in a "first load" branch will be erased by a later `ClearBox` in `.draw_page` —
  put tilemap blocks in the per-page path, keep only palettes/pics first-load-only.
- English type names print **in full** (up to 8 chars) via `PrintMoveType`; only `GetTypeName`'s copy is
  truncated by `TYPE_NAME_LENGTH`. They never fit beside a label.
- `Pokedex_PlaceBorder hl, b, c` spans exactly `b` rows and `c` columns starting at `hl` (it decrements
  both twice for the corners), so its interior is inset by one on every side — a different convention
  from `DrawTextBox`.
- **Sprites, not just tiles, have a budget: at most 10 per scanline.** Widening a sprite-drawn cursor
  or highlight can silently erase another sprite that shares its rows — on DMG the PPU takes the first
  10 in OAM order, and an anim object created earlier wins. Count the co-visible sprites before
  widening anything sprite-drawn. (The Pokédex selection box is capped at 8 tiles for this reason; the
  TM list cursor is 2 tiles for the same budget.)
- **Some on-screen labels are artwork, not text.** The Pokédex button labels are 3x2-tile cells in
  `gfx/pokedex/buttons.png` (20x12 px drawable interior each); a 4x5 px font with 1 px gaps fits four
  characters. After editing such a PNG, decode the built `.2bpp` back to an image and compare against
  the source to confirm rgbgfx did not remap the palette.

### Name widths & strides (the L0/L2 fallout — the biggest bug source in this project)
- Constants: `PLAYER_NAME_LENGTH` 8, `MON_NAME_LENGTH` 11, `MOVE`/`ITEM`/`TRAINER_CLASS_NAME_LENGTH` 13,
  `STRING_BUFFER_LENGTH` 13. **Box tables are still 6** (`BOX_MON_NAME_LENGTH`/`BOX_MON_OT_LENGTH`),
  deferred to M1e.
- The JP prototype used a **uniform 6-byte stride for every name table**; the English build has three
  widths. `home/util.asm` now has `SkipNames` (11) / `SkipOTNames` (8), both falling into `AddNTimes`
  (which **preserves `bc`**, so callers keep the width for the copy). `GetNicknamePointer` takes the
  width in `e`; `GetNickWithWidth::` takes it in `bc`. Runtime party-or-box sites set `bc` per branch.
  **If a name comes out as two names spliced together, or as `?`, it's a stride.**
- A WRAM buffer left at the old width silently overflows into whatever follows it — an undersized
  `wBattleMonNickname` once corrupted the adjacent `wBattleMon` struct into "PETAL DANCE" moves; an
  8-byte `wTMHMMoveNameBackup` overflowed into `wStringBuffer1`. Check the *declaration* as well as the
  copy length.
- WRAM is **flat 8 KB, no CGB banking**. Widening things overflows it. `wBox` currently lives in a
  UNION arm overlapping `wOverworldMapBlocks`; a buffer moved out of a clear range must not make
  `InitializeNewGameWRAM`'s label subtractions negative (that wiped the stack → "Illegal Opcode").

### Cross-bank calls & reads (silent assemble-time trap)
- A plain `call`/`jp` to a label in a **different** top-level `.asm` object assembles with no warning
  but jumps to whatever sits at that offset in the currently-mapped bank at runtime. Only
  `callfar`/`farcall`/`predef` are bank-safe. When something "does nothing" despite building clean,
  grep for a bare `call`/`jp` to a cross-file label.
- The same trap hits **data read via `de`/`hl`**: `ld de, SomeList` loads a bank-agnostic address, but
  if a `callfar` then switches banks, `ld a,[de]` reads the wrong bank's bytes (this corrupted WRAM and
  crashed the Old City mart until its item list was moved into bank `$3f` next to the code that reads
  it). **Rule: a mart's item list must live in the same bank as `RunMartBuyMenu` (`$3f`)** — or pass the
  bank and read it far.

### Overworld talk dispatch (read before adding a map with a real generic script loader)
- Talking is two steps, one frame apart. `QueueMapTextSubroutine` (overworld loop, on A-press facing an
  object) **arms** `wTalkingTargetType` bit 0 (NPC) or 1 (sign) + `hCurMapTextSubroutinePtr` from the
  **current** map's `wMapTextPtr`; the map's `_ScriptLoader` (via `map_generic_script` →
  `CallMapTextSubroutine`) then **consumes** it and `jp hl`s to the text routine, which returns through
  `ResetTalkingTarget` (clears the bits).
- **Trap:** a map whose loader is a **dummy `ret`** (`map_dummy_script_bank27` / `map_dummy_text_pointers`)
  never consumes the armed pointer, so it's left set. Nothing in the map-load path used to clear it
  (`ClearMapBuffer` only zeroes `wMapScriptNumber`, inside `wMapBuffer`; `wTalkingTargetType`=$cdf4 and
  the HRAM `hCurMapTextSubroutinePtr`/`hLastTalked` are outside it). Warp into a map with a **real**
  generic loader and its first-frame `CallMapTextSubroutine` executes that stale pointer → a
  `jp GameFreakText` crash. **Fixed**: `SetUpMapBuffer` now `xor a / ld [wTalkingTargetType],a`.
  Keep that reset if you touch `SetUpMapBuffer`; don't re-introduce the leak.
- `CallMapTextSubroutine` is safe with both bits clear (short-circuits to `ret`), so the reset makes a
  stale `hCurMapTextSubroutinePtr`/`hLastTalked` harmless — you don't need to clear those too.

### Collision (the "walk through walls" trap — read before adding any new map)
- The proto carries **two collision-constant eras**. The *new* set (`COLL_WALL`=$07, `COLL_COUNTER`=$90,
  `COLL_FLOOR`=$00, …) is what `CollisionTypeTable` (`data/collision/collision_type_table.asm`) actually
  marks solid; the *old* set (`COLL_OLD_WALL`=$01, `COLL_OLD_WALL_INSIDE`=$04, `OLD_MART_ITEM`=$72,
  `OLD_COUNTER`=$73, `OLD_SIGNPOST`=$70, …) mostly indexes to **LAND (passable)** in that table. A
  tileset whose walls use the OLD wall subtypes has **no wall collision at all** — the player walks
  straight through. The demo only exercised tilesets on the NEW set, so it never showed; unshipped
  tilesets hid it until Old City became reachable.
- **How to check a tileset**: `grep -oE "OLD_[A-Z_]+" data/tilesets/<name>_collision.asm`. If its walls
  read `OLD_WALL`/`OLD_WALL_INSIDE`, they are passable — convert those `tilecoll` args to `WALL`. A
  working reference tileset (`pokecenter`, `tower`, `gym`, `traditional_house`) uses `WALL`/`FLOOR`.
- **Counters**: talk-across-a-counter is done by `CheckFacingObject`, which only fires on `cp
  COLL_COUNTER` ($90). `OLD_COUNTER` ($73) is both passable *and* never matched, so an NPC behind an
  old-counter tile is unreachable and the counter is walk-through. Use `COUNTER` ($90).
- **Signposts**: `OLD_SIGNPOST` ($70) is a passable subtype too — convert to `WALL` so signs are solid
  (they're read from the adjacent tile you face).
- The collision byte the movement code sees is the raw `tilecoll` value for the facing quarter-tile
  (`GetCoordTileCollision` → block index ×4 + quarter), fed through `IsPlayerCollisionTileSolid` →
  `_IsObjectCollisionTileSolid` → `CollisionTypeTable[value] & WALL_TILE`. `collperm` packs each row's 8
  args into 16 bytes (duplicated for the flag bit), so within a type only the listed subtypes are WALL.
- **Do not "fix" this in `CollisionTypeTable`** — it's global and would flip the handful of legitimate
  `OLD_WALL_INSIDE` tiles in shipped `house`/`lab` tilesets to solid. Fix the offending tileset's data.

### Graphics / palettes
- This project has **no CGB palette path**; in-game colour is SGB `ATTR_BLK` packets only
  (`data/sgb/blk_packets.asm`), and there are exactly **4 palettes**, all assigned in battle
  (0 = player HP colour, 1 = enemy HP colour, 2 = player mon + bottom textbox, 3 = enemy mon).
  Region mask `%011` = line + inside; `%010` recolours only the border (symptom: "only a hair of colour").
  If you move rows in a menu, the matching `blk_packet` rects must move too.
- **`GetSGBLayout` returns immediately when `wSGB` is clear, i.e. on every DMG and CGB.** Never use it
  as a proxy for "the screen was repainted".

### Project conventions
- **Many WRAM names are aliases of the same byte** (`ram/wram.asm` stacks labels with a single `db`
  under them — `wTempSpecies` / `wTempByteValue` / `wNumSetBits` / `wMoveGrammar` / `wCurType` are all
  one byte). A store that looks dead often is not: the Pokédex listing's `ld [wTempByteValue], a` is
  what makes the per-row caught-ball check work. Check the label's neighbours before deleting a write.
- **A helper that reuses `d`/`de`/`bc` as scratch must be `push`/`pop`-guarded on *every* path that
  reaches it**, not just the common one (a `.cancel` path that clobbered `d` without saving it let the
  TM list scroll infinitely). Check the error/cancel branches, not just the main loop.
- **Demo scope-limiting is a recurring pattern:** the prototype gates real features behind
  `DEBUG_FIELD_F` or forces a stripped variant (no-SAVE start menu, single-pocket bag, demo PC, sealed
  lab door, `jp Init` at the Route 2 gate). When something "isn't implemented", check for a debug gate
  before writing new code.
- Follow pret convention when removing demo behaviour: keep the routine/text, mark it
  `; unreferenced (see X)`, so it's a one-line revert.
- **Naming decisions, keep consistent:** マサキ → **BILL**, ヨロイドリ → **YOROIDORI**, ケン → **KEN**,
  ナナミ → **NANAMI**; Route 2's version-exclusive cameo keeps **SHIGERU**/**SATOSHI** (literally those
  characters, not `<RIVAL>`/`<PLAYER>`).

---

## NEXT UP

**Nothing is currently PLAYTEST-PENDING.** All of the localization/menu/crash work through the mart,
Trainer Card, collision sweep, debug menus, in-field debug access, and TM-pocket/move descriptions is
PLAYTEST-CONFIRMED (see `git log` for the specifics). New work below.

### Milestone 1 content (playtest-led; do not dump large untested assembly)
- **M1c — first route: DONE.** Already fully authored in the original decompiled content (trainers,
  wild tables, signposts, warp graph). Player reaches Old City via Route1 → Route2 →
  Route2's `connection north, OldCity` edge. Nothing to do here.
- **M1d — Old City (the big one).** Maps/warps/NPC placement are already 100% present from
  decompilation; what's missing is purely the **script layer** — every building interior currently ends
  in a `map_dummy_text_pointers` stub. To scope a building fast: open its `maps/OldCity*.asm`, find the
  dummy stub at the end, and note which `SPRITE_*` objects are already placed.
  - **Pokémon Center: DONE** (nurse heals + sets spawn point, PLAYTEST-CONFIRMED). The other centre
    buildings (Route18, Kanto, Stand, Sugar, Newtype, Font, North, Blue, West, HighTech, South, Route15,
    Kanto2 Pokecenters) are all still stubs with the same `SPRITE_NURSE` object placed at (5,1) — same
    recipe applies to each, later milestones. See the "Pokémon Center healing" recipe below.
  - **Mart: DONE** (real BUY with money + pocket handling, PLAYTEST-CONFIRMED). `RunMartBuyMenu::`
    (`engine/debug/field/pokemart_menu.asm`) is now shared, reusable infrastructure — a second real town
    mart just needs its own item list (**in bank `$3f`**, see the cross-bank pitfall) + a few lines of
    script calling it via `callfar`, not a UI rewrite. **SELL: DONE** in both Old City and the debug
    FRIENDLY SHOP (PLAYTEST-CONFIRMED): `RunMartSellMenu::` (same file) sells from the PACK screen at
    half price (`SelectQuantityToSell`), refuses CANT_TOSS items and items worth under ¥2 (MAIL,
    stones), handles the ball pocket, and caps money at 999999. It needs no per-mart data.
  - **Still needed: Gym #1.** `OldCityGym.asm` already has `SPRITE_HAYATO` (presumably the
    Brock-equivalent leader), a `SPRITE_GYM_GUY` guide, and 4 trainer-shaped NPCs already placed. Needs
    a new `TRAINER_*` class/party + a badge bit consumed by `PrintNumBadges` + script. Plus the first §3
    story hooks (missing-professor radio bulletin / the sealed Five-Story Pagoda + phantom-bird rumour /
    the High-Tech "other Oak").
- **M1e — box save persistence (deferred, needs care).** **Do not just delete the `ret` in
  `Dummy_SaveBox`** (`engine/menu/empty_sram.asm`): `wBox` isn't in the saved `wPokemonData` region and
  **no `sBox`→`wBox` load exists**, so un-stubbing alone loses boxed mons on the next save. Correct fix
  = un-stub `SaveBox` **and** add a symmetric load after `TryLoadPokemonData` **and** handle box-switch
  in Bill's PC. Then: widen `BOX_MON_NAME_LENGTH`→11 / `BOX_MON_OT_LENGTH`→8 (**measured: +210 B WRAM**
  with 1220 B free; **+1050 B per SRAM bank**, banks 2/3 have 1180/1429 B free — fits, leaves ~130 B in
  bank 2) to make every stride uniform, fix `GiveMon`'s party-full branch (still copies
  `MON_NAME_LENGTH` into `wBoxMonNicknames` slot 0), translate `bills_pc.asm` + restore
  `PCITEM_BILLS_PC` to the PC menu, and verify the overworld map reloads on PC exit (the `wBox` UNION).

### Pokémon Center healing recipe (per remaining real centre's nurse script)
The whiteout mechanism is **already generic and working**: on a non-scripted loss the player is healed
and warped to `wDefaultSpawnPoint`, falling back to `SPAWN_POINT_SILENT` (Silent Hill town). Old City's
centre is the working template. Silent Hill's nurse is deliberately "under repair" (keep it; MOM in
`PlayerHouse1F` is the first act's heal source). For each remaining centre:
1. `callfar AnimateHealingMachine` (`engine/overworld/healing_machine.asm`) + `predef HealParty`.
2. **Set `wDefaultSpawnPoint`** to that town's `SPAWN_POINT_*` — the whiteout then routes there.
3. Note `data/maps/spawn_points.asm` entries are **outdoor town** coords, so a blackout drops you in
   the town, healed. For retail-style "wake up inside the centre", add a centre-interior spawn entry.

### Open decision for the user
- **EXP bar colour.** It tracks the HP colour because `BlkPacket_Battle`'s first block paints
  everything uncovered with palette 0 (= `wPlayerHPPal`). A fixed blue needs a free SGB palette and
  **there is none** (all four assigned, see Graphics/palettes). Options: (a) accept it, (b) give the bar
  its own block using palette 2 or 3 — stops it tracking HP, tints it with a species colour, (c) add CGB
  support. A 6th `attr_blk` block also costs 16 bytes (packet count 2→3 needs `ds 10` padding).

### Larger features (schedule their own session)
- **Trainer GEAR town map is not navigable.** The GEAR flow is correct (clock before Ken's upgrade,
  selectable MAP after) but the MAP card just renders — there is no region-map cursor. Retail lets you
  arrow a cursor across every landmark with the location name shown. Needs a region-map cursor sprite +
  arrow-key movement stepping through landmark coordinates + per-landmark name display.
  `AnimateTrainerGearModeIndicatorPointer.move_right` is pinned to `ret` to lock the cursor to MAP; that
  pin (and `TrainerGear_Joypad`'s A no-op) is where a real map view would hook in.
- **Pokédex AREA button is a no-op.** `.Area` (`engine/pokedex/pokedex.asm:1261`) sets `VIEW_AREA_F` but
  nothing consumes it; the real area-display routine (`pokedex.asm:627`) is explicitly "dummied out for
  the demo". Wiring it up needs the region-map area view **plus per-mon landmark/location data**.

### Small known follow-ups
- **Set the `OAK_MISSING` event when M3 lands** — the lab PC's full mail is gated on it
  (`SilentHillLabFront.asm`; the event bit is already allocated, costs no WRAM/SRAM).
- The Pokédex **species category** ("<KIND> POKéMON" on the entry screen) is still Japanese: it lives
  in `data/pokemon/dex_entries.asm`, which the localization scope defers. The category and "POKéMON"
  share one row (columns 9-18), so English categories will need the width checked.
- Still deliberately Japanese (all off the reachable path): `data/pokemon/dex_entries.asm`,
  `engine/link/*`, `engine/games/*`, `engine/pokemon/bills_pc.asm` (M1e),
  `engine/events/breeder.asm`, `engine/movie/trade_animation.asm`, `engine/debug/*`, and the kana
  keyboard tables (`text_entry.asm` / `data/text/text_input_chars.asm`).

---

## Content pipeline pattern (repeat per town/route)

Maps are **hand-written Z80 assembly** in `maps/*.asm` (no Gen-2 bytecode DSL) calling engine routines;
`macros/scripts/` structures headers/events/text/movement.
1. Pick an existing stub map (geometry + warps exist for 200+ maps).
2. Add events in the header (`def_object_events`/`object_event`, `def_warp_events`, `def_bg_events`).
   Model: `maps/SilentHill.asm:1-40`.
3. Write scene scripts as hand assembly (`OpenTextbox`, `FreezeAllOtherObjects`,
   `LoadMovementDataPointer`, `SetMapStatus`, `InitTrainerBattle`). Model: `maps/SilentHillLabBack.asm`
   (clean, self-contained) and `SilentHillLabFront.asm` (cutscene + battle).
4. Register scenes in **`data/maps/scenes.asm`** — the index of "the authored game" (~13 maps).
5. Add trainers (`data/trainers/parties.asm` + `attributes.asm` + `constants/trainer_constants.asm` +
   pic) and wild tables (`data/wild/maps/`).
6. Gate progression with `SetEvent`/`CheckEvent` (`macros/scripts/events.asm`).
7. Test via the debug warp menu (`data/maps/debug_warps.asm`) before wiring the normal path.

**Per-scene object visibility** is driven by the NPCID list attached to each `script_pointer`:
`InitObjectMasks` masks all objects then unmasks the current scene's list. Object consts equal their
map-object indices (`object_const_def` starts at `NUM_RESERVED_OBJECTS` = 2). `RunMapScript` runs the
current scene script **every overworld frame**, so steady-state scripts are the place to re-assert
state (`DeleteObjectStruct` is idempotent).

---

## Roadmap beyond M1
M2 West + Gym #2 + assistant NPC + first Geruge-dan grunt → M3 Old City pagoda + phantom Ho-Oh
(`houou`) + lab-PC letter, Gym #3 → M4 High-Tech city + impostor Oak (`SPRITE_EVIL_OKIDO`,
`maps/HighTechImposterOakHouse.asm`) + Team Rocket, Gym #4 → M5+ remaining towns/gyms, Time Machine,
Kanto-as-one-city + Elite Four, pagoda finale. Cross-cutting: author the remaining ~100 proto
evolutions/learnsets (retail fallback for corrupt lines).

## Engine facts worth remembering
- Near-complete Gen-2 **battle engine** (wild + trainer, damage/status/weather/AI): `engine/battle/`.
- **251 statted species** with level-up + TM learnsets: `data/pokemon/base_stats/`, `evos_attacks.asm`.
- Working **bag + item effects + ball catching** (`engine/items/item_effects.asm`), **party/box UI**
  (`engine/pokemon/`), **save/load with checksums** (`engine/menu/empty_sram.asm`), overworld
  encounters (`engine/overworld/wildmons.asm`), minigames (`engine/games/`), debug tools
  (`engine/debug/`: field menu, fight test, warps).
- Boot flow: Main Menu **New Game** → `GameStart` (Oak speech, name self + rival, set clock) →
  `IntroCleanup` → `OverworldStart` → spawn at `PLAYER_HOUSE_2F`. Debug Menu → **FIELD** sets
  `DEBUG_FIELD_F` → `DebugSetUpPlayer` (all badges/mons, `SetDemoEventFlags` pre-completes the story)
  → free warp. Both paths are live; use FIELD for warp-testing, New Game to test the story.
