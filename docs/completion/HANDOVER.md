# feature/completion — Session Handover

**Living baton between Claude sessions.** This project extends the Space World '97 demo into a
fuller, playable English adventure. Read this first; **rewrite it before ending your session** —
keep only the *current* session's work plus the durable pitfalls below. Per-round history lives in
`git log`, not here.

Authoritative plans: `~/.claude/plans/in-docs-you-hinted-linear-hearth.md` (content) and
`~/.claude/plans/continuing-from-docs-completion-handover-compiled-trinket.md` (localization).
Narrative target: `docs/index.html` §2/§3 ("Story of Nihon"). English strings: `docs/_glossary/`.

Branch: `feature/completion`. We have **abandoned the `make compare` byte-match guarantee** — this is
a downstream romhack now. Correctness = **builds warning-clean + boots & plays in SameBoy**. Do
**not** touch `roms.sha1`.

- **BUILD-VERIFIED** = assembles, links, bytes confirmed in the symbol map / decoded from the ROM.
- **PLAYTEST-PENDING** = needs SameBoy. Claude cannot run the emulator — **the user playtests.**
  Never claim a gameplay behaviour "works" without a playtest.

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

## CURRENT SESSION (2026-08-09) — lab mail gate, tooling, Pokédex UI

All 8 ROMs build warning-clean; every new routine was decoded back out of
`pokegold-spaceworld-debug.gb` and checked byte by byte.

### 1. Lab PC mail gated on a story event ✅
The authored mail (Oak's assistant reporting the world is in an uproar over Oak going missing) is an
M3 beat and read oddly with Oak standing in the room. `SilentHillLabFrontText1`
(`maps/SilentHillLabFront.asm`) now picks between the full mail and a new
`SilentHillLabFrontTextString1Early` — the same assistant's mail carrying only the search report,
which foreshadows the beat either way — on a new `OAK_MISSING` event. **Set that event when M3
lands.** The event constant came free: `wEventFlags` is a `flag_array`, so bits 38-39 were already
allocated as padding in its last byte; naming one costs no WRAM and no SRAM and moves nothing.
A 41st event *will* grow the array and shift the saved data. (+64 B reclaimed, Bank 34.)

### 2. The two text tools rebuilt (keep these) ✅
Both live in the session scratchpad and are cheap to recreate; the handover has told two sessions
running to rebuild them, so the specs are now in "Common pitfalls" below.
- **Width linter** — parses every `text`/`line`/`cont`/`para`/`next` row, expands the dict tokens and
  `text_from_ram` targets, reports worst-case rendered width. **Swept the whole codebase: zero real
  overflows.** Six hits were checked by hand and are all false positives (the RAM buffer holds a
  10-column mon name, not the 12-column worst case, or the row is a `PlaceString` on the full
  20-column screen); they are listed in the tool's `KNOWN_OK` set so re-runs stay silent.
- **ROM text decoder** — label → `.sym` → charmap decode, plus a `-x` hexdump mode. Used to verify
  everything below.
- Also settled: the "rival wants to battle" cosmetic follow-up is a **non-issue in English**.
  `Battle_GetTrainerName` copies `RivalGroup`'s `"@"` placeholder into `wStringBuffer1`, which renders
  as nothing, so the line reads `<RIVAL>` / `wants to battle!`.

### 3. Pokédex UI — text, layout and button art ✅ (BUILD-VERIFIED, playtest-pending)
The dex was the queued target and was **not** just a string swap: its listing was a 5-column,
kana-width design, so 218 of 251 English names were overflowing the box border into the button
graphics before any translation.

**Listing rebuilt for 10-column names** (user's call: full names, dex number moved to the right panel).
The listing box went 11 → 13 columns wide (interior 1-11): caught ball in column 1, name in columns
2-11. The dex number is gone from the rows; `Pokedex_PrintSelectedNumber` prints `No.NNN` for the
entry under the cursor at rows 1, columns 13-18, cache-gated on the new `wDexShownNumber` (taken from
that WRAM arm's own padding) so it only touches the tilemap when the selection changes — called every
frame from `Pokedex_List` and forced on redraw from `ShowPokedexMenu`. Everything on the right moved
two columns over: counts box now columns 13-19, button cluster 14-19, SEEN/OWN at column 14, the
SELECT/START prompt on rows 8-9.
- **The selection-box sprite went 5 → 8 tiles wide, and 8 is a hardware ceiling, not a preference.**
  The Game Boy draws at most 10 sprites per scanline and the A-button menu's hand cursor is 2 tiles
  wide on the same scanlines, so a 10-wide box would make the hand cursor vanish. The box therefore
  covers columns 2-9 and the last two characters of a 10-character name sit just outside it.
  **This is the thing to look at in a screenshot.**

**Search / Unown screens.** The search screen's vertical split moved one column left (list box 0-10,
right boxes 11-19) to match the split the Unown screen already used, giving the selected-type box a
7-column interior. `data/types/search_strings.asm` is now English at a stride of
`POKEDEX_TYPE_STRING_LENGTH` = 8 (7 chars + `@`); ELECTRIC and FIGHTING are the only names that do not
fit and are the only two abbreviated (`ELECTR`, `FIGHT`) — `data/types/names.asm` keeps full names
everywhere else. Menus are SEARCH/MORE/CANCEL and SEARCH/REDO/CANCEL; header `TYPE SEARCH` / `CHOSEN`;
Unown page `UNOWN'S FORMS` + `FOUND!`.

**Dex entry screen.** `HT`/`WT` labels with the `?` placeholder columns aligned to the digits
PrintNumber writes over them, at exactly the original byte lengths. (The species *category* beside
"POKéMON" is still Japanese — it lives in `data/pokemon/dex_entries.asm`, deferred by scope.)

**Button artwork redrawn** (`gfx/pokedex/buttons.png`): DATA / CRY / AREA / FIND / NUM / A-Z / BACK.
Each button is 3x2 tiles with a **20x12 px drawable interior**; a 4x5 font with a 1 px gap fits
**four characters** (19 px), which is why every label is ≤4. Only the interiors were touched — frames,
arrows and the unused `とじる` graphic (split across the sheet's row boundary, which is why the code
comment says the A menu borrows the SELECT menu's BACK button) are untouched. The compiled `.2bpp`
round-trips to the source PNG exactly, so rgbgfx did not remap the palette. Generator script is in the
scratchpad. **Needs a screenshot check.**

Garbage reclaimed this session: Bank 34 +64, Bank 10 +96, Bank 23 +64.

### ⚠️ STILL OPEN from round 11: textbox opens after a ~1 s delay (BUILD-VERIFIED, PLAYTEST-PENDING)

**This is the one thing to playtest, and it is the change most likely to be wrong.**

The delay **cannot be cached away.** `LoadOverworldSprite` writes each sprite's standing frames at
`hl` and its walking frames `$800` higher — which *is* `vFont`. So `TextboxCleanup` →
`ReloadObjectGFX` destroys the font on **every** textbox close. The overworld arm of the
`ram/vram.asm` UNION wants `vNPCSprites` (120) + `vNPCSprites2` (120) + tilesets (96) + font (128) +
font extras (32) = **496 tiles in 384 tiles of VRAM**; BG bytes `$80-$ff` and OBJ tiles `$80-$ff` both
resolve to `$8800-$8fff`, so font and walking frames cannot both be resident. The swap is forced.

What was done instead — copy only what was actually lost:
- **`wDirtyFontTiles`** — a watermark of how many tiles at the start of `vFont` may be stale.
  `MarkFontTilesClobbered` (in `LoadOverworldSprite`, before the walking-frame copy) records it;
  `LoadFontGraphicsPartial` (`load_gfx.asm`) re-uploads exactly that many and clears it.
  `LoadFontGraphics` sets the full count and falls through, so every existing caller is unaffected.
  **Payoff is map-shaped:** a house with 3-4 sprite slots dirties ~48 of 128 tiles; an outdoor map is
  a fixed 10-slot `SpriteSets` entry and dirties 120. Towns/routes will still feel slower than houses.
- **`wFontExtraInVRAM`** — the extras + textbox frame live at `vChars2 $60+`, above `vExteriorTileset`,
  so nothing in the overworld clobbers them; worth ~5 of ~21 frames everywhere.
- Every routine that writes those VRAM regions must call `InvalidateVRAMFonts`: `LoadMap`,
  `LoadHPBar`, `LoadBackpackGraphics`, `LoadBirdSpriteGraphics_Old` all do now.

**PLAYTEST:** talk to several NPCs in a row indoors (bedroom, lab) and outdoors (Silent Hill, Route 1),
read signs, open/close the START menu — text must always be **letters, never sprite garbage or a mix**.
Repeat straight after a battle, after the PACK, the summary screen, the Pokédex, and a map change.
**Any garbled row = a VRAM writer still missing its `InvalidateVRAMFonts`.** Indoor textboxes should
open noticeably faster; outdoor ones only a little.

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
- **Rebuild the two tools before translating anything else** (they live in the session scratchpad and
  are cheap to recreate; rebuilt again 2026-08-09):
  - a **width linter** that expands the tokens above plus `text_from_ram` targets and reports
    worst-case row width — it once found four latent overflows in files earlier sessions had signed
    off. Keep a `KNOWN_OK` set of hand-verified false positives so re-runs are silent.
  - a **ROM text decoder** (label → `.sym` → charmap decode, plus a hexdump mode) for verifying
    emitted bytes. Charmap note: build the byte→glyph map so later Latin aliases win over the kana.

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
  widening anything sprite-drawn.
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
  `wBattleMonNickname` once corrupted the adjacent `wBattleMon` struct into "PETAL DANCE" moves. Check
  the *declaration* as well as the copy length.
- WRAM is **flat 8 KB, no CGB banking**. Widening things overflows it. `wBox` currently lives in a
  UNION arm overlapping `wOverworldMapBlocks`; a buffer moved out of a clear range must not make
  `InitializeNewGameWRAM`'s label subtractions negative (that wiped the stack → "Illegal Opcode").

### Species / trainer data
- Two numbering spaces exist. **Party- and species-facing data uses `DEX_*`**, not `MON_*`
  (`wCurPartySpecies`, `wPlayerStarter`/`wRivalStarter`, trainer party species, `GivePoke`). `MON_*`
  appears mainly in leftover Red/Blue data.
- Trainer party format is `db "name@", TRAINERTYPE_*`, mons, `db -1`; `ReadTrainerParty` skips entries
  by scanning for `$ff`. Red/Blue-format leftovers (`db level, species, 0`) build garbage battlers.

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

### Immediate — two playtests owed
1. **Round 11's textbox change** — textboxes first and hard (see above). Nothing else is blocked on it.
2. **The Pokédex**, which is new this session and is layout-heavy. Open the dex after Oak hands it
   over and check, in this order: (a) the **listing** — long names like CHARMANDER/JIGGLYPUFF render
   in full inside the box, the caught ball is in column 1, and the selection box (8 tiles) sits over
   the name; (b) **`No.NNN` in the top-right updates as you move the cursor**, including when the list
   scrolls past the top/bottom; (c) the **button cluster** in its new columns 14-19, with English
   labels (DATA/CRY/AREA and NUM/A-Z/FIND/BACK), and the arrow buttons still animate when pressed;
   (d) the **A-button menu** with the cursor on a *top* list row — the hand cursor must stay visible
   (this is the 10-sprites-per-scanline limit); (e) **SELECT → type search**: the header, the type
   list, the chosen-type box, SEARCH/MORE/CANCEL, and a search that finds nothing; (f) the **dex
   entry** screen's HT/WT rows lining up with their numbers; (g) **START → Unown forms** if reachable.

### Milestone 1 content (playtest-led; do not dump large untested assembly)
- **M1c — first route.** `maps/QuietHills.asm` has 5 `InitTrainerBattle` calls + wild grass, reachable
  from Route1/Route2. Needs a signpost objective ("Old City lies west"), chain warps toward Old City,
  and wild tables for Route1/Route2 (`data/wild/maps/`, listed in `data/wild/grassmons.asm`).
- **M1d — Old City (the big one).** Maps exist as geometry-only stubs. Deliverables: a **working
  Pokémon Center** (see below), a Mart roster (build on `pokemart_menu.asm`, the debug mart is the only
  implementation), **Gym #1** (guide NPC + 1-2 trainers + leader with a new `TRAINER_*` class/party +
  badge bit consumed by `PrintNumBadges`), and the first §3 story hooks (missing-professor radio
  bulletin / the sealed Five-Story Pagoda + phantom-bird rumour / the High-Tech "other Oak").
- **M1e — box save persistence (deferred, needs care).** **Do not just delete the `ret` in
  `Dummy_SaveBox`** (`engine/menu/empty_sram.asm`): `wBox` isn't in the saved `wPokemonData` region and
  **no `sBox`→`wBox` load exists**, so un-stubbing alone loses boxed mons on the next save. Correct fix
  = un-stub `SaveBox` **and** add a symmetric load after `TryLoadPokemonData` **and** handle box-switch
  in Bill's PC. Then: widen `BOX_MON_NAME_LENGTH`→11 / `BOX_MON_OT_LENGTH`→8 (**measured: +210 B WRAM**
  with 1220 B free; **+1050 B per SRAM bank**, banks 2/3 have 1180/1429 B free — fits, leaves ~130 B in
  bank 2) to make every stride uniform, fix `GiveMon`'s party-full branch (still copies
  `MON_NAME_LENGTH` into `wBoxMonNicknames` slot 0), translate `bills_pc.asm` + restore
  `PCITEM_BILLS_PC` to the PC menu, and verify the overworld map reloads on PC exit (the `wBox` UNION).

### Pokémon Center healing + blackout respawn (M1d)
The whiteout mechanism is **already generic and working**: on a non-scripted loss the player is healed
and warped to `wDefaultSpawnPoint`, falling back to `SPAWN_POINT_SILENT` (Silent Hill town). No centre
heals yet — every centre map is a stub, and Silent Hill's nurse is deliberately "under repair" (keep
it; MOM in `PlayerHouse1F` is the first act's heal source). Each real centre's nurse script should:
1. `AnimateHealingMachine` (`engine/overworld/healing_machine.asm`) + `predef HealParty`.
2. **Set `wDefaultSpawnPoint`** to that town's `SPAWN_POINT_*` — the whiteout then routes there.
3. Note `data/maps/spawn_points.asm` entries are **outdoor town** coords, so a blackout drops you in
   the town, healed. For retail-style "wake up inside the centre", add a centre-interior spawn entry.

### Open decision for the user
- **EXP bar colour.** It tracks the HP colour because `BlkPacket_Battle`'s first block paints
  everything uncovered with palette 0 (= `wPlayerHPPal`). A fixed blue needs a free SGB palette and
  **there is none** (all four assigned, see above). Options: (a) accept it, (b) give the bar its own
  block using palette 2 or 3 — stops it tracking HP, tints it with a species colour, (c) add CGB
  support. A 6th `attr_blk` block also costs 16 bytes (packet count 2→3 needs `ds 10` padding).

### Small known follow-ups
- **Set the `OAK_MISSING` event when M3 lands** — the lab PC's full mail is gated on it.
- The Pokédex **species category** ("<KIND> POKéMON" on the entry screen) is still Japanese: it lives
  in `data/pokemon/dex_entries.asm`, which the localization scope defers. Note the category and
  "POKéMON" share one row (columns 9-18), so English categories will need the width checked.
- Still deliberately Japanese (all off the reachable path): `data/pokemon/dex_entries.asm`,
  `data/moves/descriptions.asm`, `data/items/descriptions.asm`, `engine/link/*`, `engine/games/*`,
  `engine/pokemon/bills_pc.asm` (M1e), `engine/events/breeder.asm`, `engine/movie/trade_animation.asm`,
  `engine/debug/*`, and the kana keyboard tables (`text_entry.asm` / `data/text/text_input_chars.asm`).

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
