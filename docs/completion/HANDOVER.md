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

## CURRENT SESSION (2026-08-09, round 14) — textbox delay, actually fixed

Round 13's items 2 and 3 (Pokédex) are **PLAYTEST-CONFIRMED working**. Only the textbox delay
survived, and rounds 11-13 had been optimising the wrong thing.

### 4. Intermittent 1-frame black flash on textbox open ✅ (PLAYTEST-CONFIRMED fixed)
Follow-up from item 1's playtest: mostly fixed, but occasionally a ~1-frame black horizontal band
flashed across part of the screen right before the box appeared.

`hWY` is only a HRAM **shadow** — `VBlank`/`VBlank2`/`VBlank3` (`home/vblank.asm`) copy it into the
real `rWY` once per VBlank *interrupt*, on their own schedule. `ReanchorBGMap_NoOAMUpdate`
(`engine/overworld/init_map.asm`) sets `hWY = 0` (engaging the window-as-freeze-frame) and then called
`.Transfer` immediately — a raw `STAT_BUSY`-polled loop that blanks the live `vBGMap0` outside VBlank,
not through the VBlank-synced copy queue. Nothing forced a VBlank to actually happen between those two
lines, so the CPU could win the race: if `.Transfer` started before the *next* real VBlank interrupt
fired, the real `rWY` was still the old value, the window wasn't actually covering anything yet, and
`.Transfer` blanked the still-displayed `vBGMap0` in full view — a black band for whatever part of the
screen the raster hadn't scanned past yet. Intermittent because it depends on exactly where in the
VBlank cycle the reanchor happened to run.

Fix: `call DelayFrame` between `ldh [hWY], a` and `call .Transfer` — the same primitive `WaitBGMap`
already uses, guaranteeing at least one real VBlank (and thus the `rWY` copy) has happened before
touching VRAM outside the copy queue. Costs one extra frame (~11 total now, still nowhere near
retail's ~12). Verified in the assembled ROM: `call DelayFrame` (`$0317`) immediately precedes
`call .Transfer` (`$6506`) in the decoded bytes.
**Corollary for later VRAM-bandwidth work:** any raw out-of-VBlank VRAM write that depends on `hWY`/
`hSCX`/`hSCY`/`hBGMapMode`/`hBGMapAddress` having already taken effect needs an explicit `DelayFrame`
(or a `WaitBGMap`) after the HRAM write — setting the shadow is not the same as the hardware register
being updated.

### 5. Start menu open feels slow — attempted fix REVERTED, playtest broke the game ❌
User's follow-up: "the start menu still feels as delayed as NPC dialogue used to." Diagnosis (still
believed correct, just not yet fixed): `DisplayStartMenu` (`engine/menu/start_menu.asm`) calls
`ReanchorMap` (freeze→redraw→**reveal**, all three back to back — the same shared
`ReanchorBGMap_NoOAMUpdate`/`LoadFonts_NoOAMUpdate` pair textboxes use) and only *then* calls
`OpenMenu`, which draws the box border and item strings live on top of the already-revealed plain map,
via the ordinary `hBGMapMode=1`+`AutoBgMapTransfer` path with no `WaitBGMap`. So the reveal itself is
never late here — the box is just never drawn before it. Same family of bug as item 1, mirrored: there
content was ready early and the reveal was late; here the reveal is early and the content paints in
live afterward, a visible two-stage "pause, then pop."

**Attempted fix (BUILD-VERIFIED, byte-decoded correct, then PLAYTEST-FAILED and reverted):** split
`OpenMenu` (`home/menu.asm`) into `OpenMenu_Draw` (box + item text + `hBGMapMode=1`) and `OpenMenu_Wait`
(`GetStaticMenuJoypad`), and had `DisplayStartMenu`'s first open draw the menu behind the freeze before
revealing — bankswitch to `ReanchorBGMap_NoOAMUpdate`'s bank, freeze, bankswitch back to this file's own
bank (needed because `OpenMenu_Draw` reads this file's own ROMX string/item tables, so unlike
`ReanchorMap`'s textbox equivalent the freeze and the draw can't share one bankswitch), `PlaySFX` +
`LoadMenuHeader` + `GetStartMenuState` + `OpenMenu_Draw` + `WaitBGMap`, bankswitch again, reveal via
`LoadFonts_NoOAMUpdate`, bankswitch back, `OpenMenu_Wait`. Every instruction sequence and bank target
was confirmed correct via `.sym`-guided decode of the assembled ROM (`ReanchorBGMap_NoOAMUpdate` →
bankswitch → `OpenMenu_Draw` → `WaitBGMap` → bankswitch → `LoadFonts_NoOAMUpdate` → bankswitch →
`OpenMenu_Wait`, in that order) and it built warning-clean on all 8 ROMs.

**On the user's playtest it broke the game outright:** pressing START opened nothing, distorted the
BGM, and left the player free to walk around and enter buildings as if no menu were open at all. That
combination — audio corruption plus the input state clearly never reaching the menu's joypad-wait —
smells like a ROM-bank race rather than a logic error in the draw/reveal reordering itself (stack
balance and label scoping were both checked by hand and looked correct; the byte decode matched intent
exactly). Prime suspect: the *extra* bankswitch round-trips this added. `ReanchorMap`'s original,
still-safe pattern is **one** bankswitch spanning both the freeze and the reveal, with nothing else
running in between; this attempt needed **two** separate bankswitch pairs with real work (SFX, string
loads, `GetStartMenuState`, `WaitBGMap`'s 3-frame halt-and-wait-for-VBlank) sandwiched *between* them,
multiplying the window in which a VBlank interrupt — which does its own `hROMBank`-save-and-restore
dance around `UpdateSound` (`home/vblank.asm`) — could land at a moment this code didn't anticipate.
Static analysis didn't find the exact race, and it needs to be actually understood before trying again,
not just avoided by luck.

**Reverted in full** (`home/menu.asm`'s `OpenMenu` and `engine/menu/start_menu.asm`'s
`DisplayStartMenu` are back to their pre-session bytes, confirmed via `git diff` — zero diff on either
file) — all 8 ROMs rebuild clean. **The delay is still unfixed.** Do not re-attempt the same
two-extra-bankswitch shape without first understanding why it corrupted audio; if retried, get the user
to playtest a *minimal* change first (e.g. just moving the reveal later with no bank juggling, even if
that alone doesn't fully fix the two-stage pop) rather than landing the whole restructure in one shot.

### 1. Textbox delay: the reveal was after the font, not before it ✅ (BUILD-VERIFIED, PLAYTEST-PENDING)
The copying was never the problem. **The finished textbox was hidden behind the window layer while
the font uploaded.**

`LCDC_DEFAULT` has `LCDC_WIN_ON | LCDC_WIN_9C00` and `hWX` = 7, so the window draws `vBGMap1` from
screen (0,0). `ReanchorBGMap_NoOAMUpdate` uses that as a **freeze-frame**: it paints a snapshot of
the map into `vBGMap1`, sets `hWY` = 0 so the window covers the whole screen, and only then blanks
`vBGMap0` and repaints it — with the textbox in it. Nothing of that is seen. The box becomes visible
at the single instruction that puts `hWY` back to `SCREEN_HEIGHT_PX`, and in this codebase that was
the **last** thing `LoadFonts_NoOAMUpdate` did — after `LoadFontPartial`. So the box sat complete and
invisible for the entire font copy, and box + first line of text appeared together after ~1 s.

pret/pokegold's `LoadFonts_NoOAMUpdate.LoadGFX` does it in the other order — extras, `hWY` = `$90`,
sprites, *then* `LoadStandardFont` — and that is now the order here. The font lands in the
walking-sprite half of VRAM, which nothing on screen uses while the objects are frozen, so copying it
in plain view is invisible; the box's own tiles (frame `┌`…`┘` = `$79`, blank `　` = `$7f`) live in
`vChars2` above `vExteriorTileset` and are never clobbered by the overworld. Same instructions,
reordered — no ROM cost.

Frames to a visible box are now **~10 (0.17 s)**, against retail's ~12: `WaitBGMap` 3 + `.Transfer`
~1 + `WaitBGMap` 3 + `WaitBGMap` 3. `TextboxCleanup` already revealed before `ReloadObjectGFX`, which
is why closing never felt as bad as opening.

Round 13's `.Transfer` rewrite (1024-byte `STAT_BUSY`-polled VRAM fill instead of 16 frames of
`Request2bpp`) is **kept** — it is still 16 frames off both halves of every textbox, it is entirely
behind the window, and it is now most of what is left of the pre-reveal cost.

### 2. Pokédex `No.NNN` did not follow the cursor ✅ (round 13, PLAYTEST-CONFIRMED)
Not a caching bug — the number reached the tilemap every time and never reached VRAM.
`ShowPokedexMenu` ends on `WaitForAutoBgMapTransfer`, which **clears `hBGMapMode`**, so the listing
screen runs with the automatic BG map transfer off and a tilemap write is inert until something
redraws the whole screen (pressing A, or scrolling the list). `Pokedex_PrintSelectedNumber` now
pushes its six tiles into `vBGMap0` itself, same `STAT_BUSY` poll, but **with interrupts off** — a
store dropped there would leave a wrong digit on screen, where the reanchor's margin fill can afford
to lose one. Three frames of `WaitBGMap` per cursor step was the alternative and would have felt worse.

### 3. Pokédex hand cursor sat on top of the button it selected ✅ (round 13, PLAYTEST-CONFIRMED)
The hand's anchor was never touched last round; the *buttons* moved. They used to occupy columns
12-17 with two spare columns after them, and the hand pointed **left** at each button from its right,
standing in that spare space. The widened listing box pushed the cluster to columns 14-19, flush with
the screen edge: nothing to the right to stand in, so the old anchor put the hand squarely over the
label, and its fingertip (sprite-local row 5) sat above the shorter English label instead of on it.

`gfx/pokedex/cursor.png` is mirrored — it now points right, like every other cursor in the game — and
the hand approaches from the left: anchor `depixel 5, 14, 1, 0`, landing on columns 12-13 with the
fingertip on the button's left edge and centred on the label rows. The `+24 px / +16 px` offset table
still matches the 3-tile, 2-row button pitch. As in the Japanese layout, the hand's body covers part
of the *neighbouring* button on the right-hand column; with 3-tile buttons packed edge to edge there
is nowhere else for it to go.

---

## PREVIOUS SESSION (2026-08-09) — lab mail gate, tooling, Pokédex UI

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

### Round 11's font work (still the other half of the textbox cost)

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

**PLAYTEST (still owed):** talk to several NPCs in a row indoors (bedroom, lab) and outdoors (Silent
Hill, Route 1), read signs, open/close the START menu — text must always be **letters, never sprite
garbage or a mix**. Repeat straight after a battle, after the PACK, the summary screen, the Pokédex,
and a map change. **Any garbled row = a VRAM writer still missing its `InvalidateVRAMFonts`.**

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

### VRAM bandwidth (read before optimising any "why is this screen slow" complaint)
- **Before counting frames, find the frame the user actually sees.** The overworld runs with the
  window layer enabled (`LCDC_DEFAULT` = `… | LCDC_WIN_9C00 | LCDC_WIN_ON`, `hWX` = 7), and
  `ReanchorBGMap_NoOAMUpdate` uses it as a freeze-frame: snapshot the map into `vBGMap1`, `hWY` = 0 to
  cover the screen, rebuild `vBGMap0` underneath, `hWY` = `SCREEN_HEIGHT_PX` to reveal. **Everything
  before that last store is free wall-clock; everything after it is on screen.** So where the reveal
  sits in the routine matters more than how fast any of the copying is — three rounds were spent
  optimising copies before anyone checked (round 14). When a screen "takes ages to appear", check the
  `hWY` ordering *first*, then start counting `DelayFrame`s. Corollary: work that writes VRAM nothing
  on screen is currently reading (the font, which lands in the walking-sprite half while the objects
  are frozen) belongs **after** the reveal.
- **Count `DelayFrame`s, not routines.** Every bulk VRAM write goes through `Request2bpp`/`Request1bpp`,
  which copy **8 tiles per VBlank and burn one extra frame draining the last chunk**. So a copy of
  `n` tiles costs `ceil(n/8) + 1` frames. `WaitBGMap` is a flat **3** (`AutoBgMapTransfer` does a third
  of the screen per VBlank). Add them up before theorising — the answer is usually one loop you didn't
  suspect, not the one being blamed.
- **Do not raise the 8-tile chunk.** `VBlankCopyDouble` costs ~65 M-cycles per tile, so 8 tiles is
  ~520 of the ~1140 M-cycles in DMG VBlank; OAM DMA (~160), `AnimateTileset` and `Joypad` take most of
  the rest. 12 tiles overruns VBlank and corrupts whatever it was writing. `Request1bpp`/`Request2bpp`
  do force `hBGMapMode` to 0 for the duration, so `AutoBgMapTransfer` at least is not competing.
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

### Immediate — one playtest owed
1. **Textboxes.** This round added a `DelayFrame` to fix an intermittent 1-frame black flash on open
   (see item 4 above) — **needs the flash specifically retested**: talk to several NPCs in a row and
   confirm it's gone (or rare enough it wasn't just luck of the timing before). Target behaviour is
   retail Gold: NPC turns, **box appears almost immediately**
   (~0.17 s), *then* the dialogue types into it. The box and the text should read as two separate
   events — if they still appear together after a pause, the reveal is being blocked again.
   - Check **both halves** (opening and closing) and both **indoors and outdoors**. Outdoors dirties
     more of the font, but that now happens *after* the box is up, so the box should appear at the
     same speed either way; only the wait before the first character differs.
   - *Correctness:* the round-11 VRAM checklist above still applies — text must always be letters,
     never sprite garbage. Retest after a battle, the PACK, the summary screen, the Pokédex and a map
     change.
   - **New this round:** the font now uploads while the screen is visible. It writes the walking-sprite
     half of VRAM, so the frozen NPCs and player should be completely still and correct for the whole
     ~0.15 s after the box opens — **any flicker or garbled sprite in that window** means something on
     screen is reading OBJ tiles `$80-$ff` and the reveal has to move back after `LoadFontPartial`.
   - Also still worth a glance (round 13, untested): the reanchor fills the BG map outside VBlank, so
     watch the **screen edges** right after a textbox closes and as you take the first step.

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
