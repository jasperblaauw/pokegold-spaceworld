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

## CURRENT SESSION (2026-08-11, round 20) — Old City mart BUY crash ROOT-caused (cross-bank list) + debug menu fully localized

### A — Old City mart BUY crash: it was a cross-bank item-list read ✅ (BUILD-VERIFIED, PLAYTEST-PENDING)
**The real root cause, found after two misdirections.** The user's isolation test was decisive: the
**debug field mart works, only the Old City (live) mart crashes** — yet both run the *identical*
`RunMartBuyMenu`/`DebugMart_LoadItems`. That pointed at the *item list*, not the shared code:
- `DebugMart_LoadItems` (bank **$3f**) copies the caller's list with a plain `ld a,[de]` loop.
- `OldCityMartItemList` lived in `maps/OldCityMart.asm` = bank **$25** (`25:46de`). `OldCityMartMenu`
  did `ld de, OldCityMartItemList` (address load — bank-agnostic, fine) then `callfar RunMartBuyMenu`,
  which **switches the ROM bank to $3f**. So `ld a,[de]` read bank $3f's bytes at `$46de` (garbage),
  not the list. The loop copied garbage into `wCurMartCount` until it randomly hit a `$ff`, **overrunning
  `wCurMartCount` and corrupting WRAM upward** ($cda4 → $d6f3 `wTilesetAnim` → the stack) → crash.
- `DebugMart_ItemList` is at `3f:562f`, already in bank $3f, so the debug mart read it correctly and
  never corrupted anything. That's the *entire* difference between the two.
- This retroactively explains **every** earlier crash: round-19's AnimateTileset (`wTilesetAnim` was the
  first thing the overrun clobbered), and round-20's earlier `$dfb4` illegal-opcode (the overrun reaching
  the stack). Round 19 even suspected "a runaway write loop up through WRAM" but dismissed it after
  decoding the list correctly *in bank $25* — never noticing it's *read* from bank $3f. This is the
  round-15 cross-bank trap, but for a **data read via `de`** rather than a `call` (an address load
  assembles fine; the read just happens in the wrong bank).
- **Fix**: moved `OldCityMartItemList` into bank $3f, next to `DebugMart_ItemList`
  (`data/debug/field_debug_pokemart_items.asm`, `::`-exported); `maps/OldCityMart.asm` keeps only the
  `ld de` reference. Now `de` points into the bank mapped during the load.
  **General rule: every mart's item list MUST live in bank $3f** (or pass the bank and read it far).
- **Decode-verified** `OldCityMartItemList` now at `3f:5685` = `08 05 12 09 0d 0c 0a 13 14 ff` (count 8 +
  the 8 items + terminator), read same-bank.
- The round-19 `hMapAnims` save/disable is **kept** (standard full-screen-menu hygiene, matches trainer
  card/party/dex; low-risk save/restore), but it does NOT fix the crash. The `hLCDCPointer` /
  `hRedrawRowOrColumnMode` clears I briefly added this session were **reverted** — they were treating
  symptoms of the WRAM corruption, are unnecessary once the list is read correctly, and the live overworld
  context is demonstrably safe (the welcome box + BUY/CANCEL menu already drew fine over it).
- **PLAYTEST-CONFIRMED**: mart no longer crashes; can buy items and money decreases (user, round-20).

### A-followup — POKé BALL purchase now reaches the ball pocket ✅ (BUILD-VERIFIED, decode-verified)
Playtest surfaced: buying a POKé BALL charged money but the ball landed in **no** pocket. Round-15 had
hand-routed balls to `wNumBallItems` before `ReceiveItem`, but `_ReceiveItem` (`engine/items/inventory.asm`)
**auto-routes by the item's pocket attribute only when given `wNumBagItems`**: `DoesHLEqualwNumBagItems`
must match for it to dispatch a ball to `.Ball`→`ReceiveBall` (the real ball-pocket structure,
`wBallQuantities`/`GetBallIndex`). Passing `wNumBallItems` failed that check → fell through to
`PutItemInPocket`, writing a raw item ID into the ball pocket in the wrong (item,qty) format → the ball
vanished. **Fix**: `RunMartBuyMenu` always passes `ld hl, wNumBagItems` now; `_ReceiveItem` routes the ball
itself (`engine/debug/field/pokemart_menu.asm`). Decode `3f`: `21 e9 d1`(ld hl,wNumBagItems $d1e9)
`cd 44 32`(call ReceiveItem) `30 ..`(jr nc,.pack_full). **PLAYTEST-CONFIRMED**: buying a POKé BALL now puts
it in the ball pocket with money decreasing (user, round-20). (The transient "blank slot below CANCEL in the ball pocket" the user saw was
just this mis-formatted ball; it clears on reset. The ball-pocket cursor is correctly clamped to CANCEL —
no menu change needed/made.)

### B — Overworld (field) debug menu fully localized to English ✅ (BUILD-VERIFIED)
User asked to translate the START+B debug menu **and every submenu/UI reachable from it**.
- Main 3-page menu: `data/debug/field_debug_entries.asm` `FieldDebug_MenuStrings` — all 29 kana labels →
  English, **capped at 5 chars** (box is ~5 text cols; longest original `ツールギア` was 5). `つぎ▶` →
  `NEXT▶` keeps the arrow (`▶`=`$ed`).
- All field submenus: 18 files under `engine/debug/field/` + `field_debug_menu_2.asm` (heal text), 64
  string replacements — menu labels sized to each box's width, textbox lines ≤ `TEXTBOX_INNERW` (18).
  Covers change_tileset/transportation, follow_npc/mon_following, item_test (also widened its USE/TOSS
  popup 1 col: `menu_coords 14→13`), map_viewer, minigames, move_to_entrance, npc_movement_test,
  sprite_viewer, teleport, toggle_npc_movement, toolgear, vram_viewer, warp, the two unused menus, etc.
- Space: the English strings + the relocated `OldCityMartItemList` overflowed bank $3f by 97 B; reclaimed
  by trimming `Bank 3f Garbage` (`garbage/garbage.asm`, all 4 INCBIN, offset `+160`, debug `414→574` /
  non-debug `412→572`). All 8 ROMs build warning-clean.
- **PLAYTEST**: debug ROM, START+B → every menu option and its submenus now read in English.

---

## PREVIOUS SESSION (2026-08-11, round 19) — mart crash + BUY hang + Trainer Card + debug menu

First batch (items 1–4) was playtested; **items 1 & 3 PLAYTEST-CONFIRMED fixed**, items 2 & 4 had
follow-up defects the playtest surfaced, both now fixed (see the **round-19 follow-up** subsection after
item 5). Item 5 (in-field debug menu) is this round's addition. All BUILD-VERIFIED (8 ROMs
warning-clean) + decode-verified. Space reclaimed: +16 B Bank 04 Garbage (all 4 INCBIN,
`,710→726`/`,644→660`) for the CARD slide; +4 B (of +8 skipped) Home Garbage ROM0
(`home_gold ,74→82` / `home_silver ,270→278`) for the map-load reset. The debug-menu change *removed*
6 B of `_DEBUG`-only ROM0.

### 1 — Mart / Pokécenter 1F / Route 2 gate entry crash: FIXED at root (Fix B, not Fix A) ✅
The user asked for **Fix B** (the deep root), not the Fix-A band-aid, so `dummy_text_pointers.asm` is
**untouched** (`GameFreakText` still there). Refined the round-18 diagnosis by reading the actual
dispatch (`home/talk_to_npc.asm`): the crash is **stale talking-target state surviving a warp**, not a
stale `wMapTextPtr`. `QueueMapTextSubroutine` arms `wTalkingTargetType` bit 0 + `hCurMapTextSubroutinePtr`
from the **current** map's `wMapTextPtr` the instant you press A facing an object. Old City **outdoor**
uses `map_dummy_script_bank27` → `OldCity_ScriptLoader:: ret`, which **never runs
`CallMapTextSubroutine`**, so pressing A near an outdoor NPC arms the pointer to that map's dummy table
(`OldCity_TextPointers` = ten × `GameFreakText`, raw text data) but never consumes or resets it. Nothing
in the map-load path cleared it: `ClearMapBuffer` zeroes `wMapScriptNumber` (inside `wMapBuffer`) but
`wTalkingTargetType` ($cdf4) is outside that buffer, and `hCurMapTextSubroutinePtr`/`hLastTalked` are
HRAM. Warp into a building whose loader **is** generic (`map_generic_script` → per-frame
`CallMapTextSubroutine`): on the first frame it sees bit 0 still set, `CheckAllMapObjects` matches the
stale `hLastTalked` against the new map's NPC ids (intermittent — depends on which outdoor object you
last faced), and `jp hl` executes `$304c`=`GameFreakText` as code → `!`=`$e7`=`RST $20` runaway. "Never
recurs once loaded" = once any legit talk on the new map runs `ResetTalkingTarget`, the leftover is gone.
- **Fix**: `xor a / ld [wTalkingTargetType], a` at the top of `SetUpMapBuffer` (`home/map.asm`), right
  after `ClearMapBuffer` — the one routine all four `MapSetup_*` paths call. With both talk bits clear,
  `CallMapTextSubroutine` short-circuits (`bit 0`→`TalkingToBGObject`→`bit 1`→`ret z`) so the stale
  pointer/`hLastTalked` are never read until a talk is armed on **this** map. Covers mart, pokecenter 1F,
  and the gate uniformly. Safe because a talk always completes synchronously inside `TextboxIdle` before
  any warp executes — the only state that ever survives is the pathological dummy-`ret`-loader leftover.
- **Decode-verified** `00:214a`: `cd 3e 21`(call ClearMapBuffer) `af`(xor a) `ea f4 cd`(ld [$cdf4],a =
  wTalkingTargetType) then `f0 98`(ldh a,[hROMBank]) as before.
- **PLAYTEST-CONFIRMED**: mart now enters without crashing (user, round-19 playtest).

### 2 — Trainer Card BADGES→CARD now slides (was an instant snap) ✅ + white-flash follow-up ✅
Round 17's `.to_card` set `wJumptableIndex=0` = instant redraw. Added a **reverse-scroll sequence**
(new jumptable indices 18–25 in `HandleTrainerCardJumptable`, `engine/menu/start_menu.asm`) that reuses
the forward CARD→BADGES workers (`TrainerCardScroll`/`ClearTileMap`/`SetWindowY`) but ends on the main
card page (index 0) via a new `.ReturnToMainPage` instead of the badge page (index 12). `.to_card` now
sets `wJumptableIndex=18`. So both tab flips animate identically.
- **Decode-verified**: table idx 18=`TrainerCardScroll`(6f95), 19/20/22/23=`.IncreaseJumpTableIndex`(6f02),
  21=`ClearTileMap`(6fa6), 24=`SetWindowY`(6fb9), 25=`.ReturnToMainPage`(6f0a = `xor a`/`ld
  [wJumptableIndex],a`/`and a`/`ret`); `.to_card` = `3e 12`(ld a,18)/`ea 92 cb`/`a7`/`c9`.
- Playtest (round 19): slide works, but the card then **sat on a white screen for ~8 frames** before
  appearing (the forward flip is instant). **Follow-up fix**: `TrainerCardMainPage` cleared palettes and
  then ran the slow protagonist-pic load (`TrainerCardDrawProtag`) with the LCD *on* — its
  `InterlaceMergeSpriteBuffers`→`Get2bpp` used the ~8-frame VBlank copy queue (`Get2bpp` only does a
  direct copy when the LCD is off, `home/copy2.asm`). Moved `call DisableLCD` **above** ClearTileMap/
  DrawProtag so the whole draw runs LCD-off (direct copies, no VBlank wait), mirroring
  `TrainerCardBadgePage` which already does. Card now pops in instantly after the slide (and the first
  card open no longer flashes white either). Decode `04:6f10`: `cd 53 36`(ClearPalettes) `cd 01 04`
  (**DisableLCD, moved up**) `cd 3c 0e`(ClearTileMap) `cd 4e 70`(DrawProtag). **Re-playtest** the slide.

### 3 — Old City signs are now solid ✅ PLAYTEST-CONFIRMED
`data/tilesets/old_city_collision.asm`: the 6 `OLD_SIGNPOST` ($70, a passable subtype the round-16 wall
sweep didn't cover) quarters → `WALL`. Signs are read from the adjacent tile you face, so solid is
correct. **User confirmed fixed** (round-19 playtest).

### 4 — Mart BUY hang: root-caused (AnimateTileset VBlank crash) and FIXED ✅
The user's round-19 `backtrace` (bottom frames `RunMartBuyMenu` → `DebugMart_LoadItems.load_loop2` →
`.GetPrice` → `VBlank0.ok` → `AnimateTileset+8` → `$00:$0000` → runaway in OAM/`$fexx`) cracked it. The
mart opens straight off an overworld textbox with `hMapAnims` **still on**, so VBlank kept calling
`_AnimateTileset`, which `jp hl`s through `wTilesetAnim`/`hTileAnimFrame`. During the long per-item
`GetPrice` precompute a VBlank landed there against tileset-anim state the full-screen menu had
disturbed → `jp $0000`. The mart was the **only full-screen menu not saving/disabling `hMapAnims`**
(trainer card, party, pokédex, stats all do). **Fix**: `RunMartBuyMenu` now does the standard
`ldh a,[hMapAnims] / push af / xor a / ldh [hMapAnims],a` at entry and `pop af / ldh [hMapAnims],a`
before `ret` (`engine/debug/field/pokemart_menu.asm`) — covers the real mart and the debug field mart.
Decode `3f:54db`: `f0 e8 f5 af e0 e8`(save/push/xor/store hMapAnims=$ffe8) then `cd 41 57`(LoadItems).
- Also (unrelated to the hang): the two round-17 "BUY defects" were re-examined and **were not live
  bugs** — `BuyItem_MenuHeader`'s `dw $ff` makes the price compute correctly, and `ScrollingMenu` only
  returns `PAD_A`/`PAD_B` here so the `.buy_item` fall-through never mis-bought. Kept the cheap guard
  (`cp PAD_A / jr nz, .cancel_buy`) as future-proofing; no price change.
- **Re-playtest**: buy from the mart clerk (browse, pick quantity, confirm) — no hang; money decreases,
  item lands in the right pocket (POKé BALL in the ball pocket).

### 5 — In-field debug menu restored in debug ROMs (START+B), no demo functionality ✅
User request: reach the **in-field debug menu** during normal play in the debug ROMs. It was already
wired (`OverworldStartButtonCheck`, `home/overworld.asm`, `if DEF(_DEBUG)`) on **START+B**, but gated by
`bit DEBUG_FIELD_F / ret z` — and `DEBUG_FIELD_F` is the *demo's* pre-completed-story field mode (set
only by the title debug menu's FIELD option → `DebugSetUpPlayer`/`SetDemoEventFlags`), which we don't
want on an authored playthrough. Removed just that gate, so **START+B opens `FieldDebugMenu` in any
_DEBUG build**. This grants menu **access only** — it does not set `DEBUG_FIELD_F`, so no demo behaviour
(noclip, story precompletion, no-map-music, attract mode) is enabled, and the demo still can't play.
Decode `00:2c29`: after the START+B compare, straight to `3e 3f 21 e9 40 cd c6 2f`(farcall FieldDebugMenu
$3f:$40e9) — the `DEBUG_FIELD_F` check is gone. **Trigger: hold B, press START, during overworld play,
debug ROM only.** (`DEBUG_FIELD_F`-gated *demo* features like noclip in `player_movement.asm` stay off,
so some individual debug options that assume that mode may behave differently — the menu itself opens
and warp-testing works.) **Playtest**: in a debug `-correctheader` ROM, during normal gameplay, hold B +
START → the field debug menu opens; plain START still opens the normal start menu.

---

## PREVIOUS SESSION (2026-08-11, round 17) — round-2 playtest fixes (3 of 4 landed)

All four items are from the user's round-2 playtest. **Three are fixed, build warning-clean on
all 8 ROMs, and decode-verified; the fourth (intermittent entry crash) is diagnosed only as far as
static analysis allows and needs the crash PC from SameBoy.** All PLAYTEST-PENDING.

### Issue 4 — "HONOGUMA learned FALSE SWIHONO!" ✅ (a stride bug)
`wTMHMMoveNameBackup` (`ram/wram.asm`) was `ds 8` — sized for JP 8-byte kana move names — but
`engine/items/tm_holder.asm` backs up/restores `wStringBuffer2` through it at `MOVE_NAME_LENGTH`
(13) across the party menu. The 13-byte copy overflowed the 8-byte buffer into `wStringBuffer1`;
on restore it read the party menu's leftover nickname ("HONO…") back into the move name's tail.
Widened to `ds MOVE_NAME_LENGTH`, taking 4 bytes from the anonymous padding above so
`wStringBuffer1` keeps its address (**verified: still `$cd64`; backup now `$cd57`–`$cd63`, 13 B**).
This is the same L0/L2 stride class as everything in "Name widths & strides" below — a buffer left
at the old JP width overflowing its neighbour.

### Issue 3a — Trainer Card 7-char name showed "NAMEAAAAAAA" ✅
The JP label was `"なまえ／"` (label + `／` separator); localization dropped the slash, jamming
`"NAME"` against the value. The name field is capped at cols 6–12 (protagonist pic starts col 13),
so a separator only fits if the label starts at col 1. `engine/menu/start_menu.asm`: new
`TrainerCardNameLabel` = `"NAME/@"` placed at `hlcoord 1, 2`; MONEY/POKéDEX split into their own
`TrainerCardText` at `hlcoord 2, 6` (kept at col 2). Value `wPlayerName` unchanged at `hlcoord 6, 2`
→ 7 chars land in cols 6–12, inside the underline. **Decoded: `8d 80 8c 84 f3 50` = "NAME/@".**

### Issue 3b — CARD/BADGES tabs now on the Badges page too ✅
The badge grid ends at row 15, so row 16 was free. `DrawTrainerCaseBadgePage` now draws the same
`CARD | BADGES` selector (arrow starts on BADGES, `wFlyDestination=1`). `TrainerCardBadgeInput`
rewritten to mirror the main page: ←/→ move the arrow; **A on the *other* tab (CARD) flips back to
the card page** (`wJumptableIndex=0`, instant redraw — no reverse-scroll animation, acceptable); A
on the current tab (BADGES) or B exits to the start menu (`wJumptableIndex=$11` =
TrainerCardSetClearFlag). **Decode-verified**: `.to_card`→`ld [wJumptableIndex],0`, `.exit`→`$11`,
arrows at `$c3e4`/`$c3eb` (cols 4/11 row 16), `wFlyDestination=$cb93`. Cost +23 B in Bank 04 (start
menu's bank) → reclaimed +32 from `Bank 04 Garbage` (all 4 INCBIN variants) in `garbage/garbage.asm`.

### Issue 2 — Mart menu: sprite-garbage font ✅, then BUY item-list bugs ✅ (round-2 follow-up)
Font garbage (round-2 first report): the welcome box is an overworld textbox; closing it runs
`TextboxCleanup → ReloadObjectGFX → LoadWalkingSpritesGFX`, which reloads walking-sprite frames
**over the font in `vFont`**. `OldCityMartMenu` then `PrintText`ed with a clobbered font. Fix:
`call LoadFont` at the top of `OldCityMartMenu` (`maps/OldCityMart.asm`). **General rule (pitfall
below): any menu opened right after an overworld textbox closes must reload the font first.**
**PLAYTEST-CONFIRMED fixed** (user: font now correct).

BUY item-list bugs (round-2 second report, "still hanging after pressing buy"): two real defects in
the shared mart-list code, both now fixed:
- **Missing count byte.** `RunMartBuyMenu`/`DebugMart_LoadItems` treat the list's first byte as the
  item count (`InitScrollingMenuCursor` reads `wScrollingMenuListSize` from `[wCurMartCount]`; items
  are read from `wCurMartCount+1`). Neither `OldCityMartItemList` nor `DebugMart_ItemList` had a
  count byte, so the first item was consumed as the count: the mart misread `ITEM_POKE_BALL`(5) as
  "5 items" and showed the wrong five (POKé BALL / ESCAPE ROPE / REPEL never appeared — a mart that
  couldn't sell POKé BALLS). The debug list worked only by luck (`ITEM_BICYCLE`=7 = its 7 items).
  Added `db 8` to both lists. Decoded: `08 05 12 09 0d 0c 0a 13 14 ff`.
- **Buffer overflow into font state.** `DebugMart_LoadItems` copies the list into `wCurMartCount`,
  and feature/completion had repurposed the padding right after it into `wWildEncounterCooldown` /
  `wDirtyFontTiles` / `wFontExtraInVRAM` — so every BUY press corrupted the font-tracking vars.
  Moved those three past an 11-byte item-list scratch in `ram/wram.asm` (verified `wCurMartCount`
  `$cda4`, vars now `$cdb0`–`$cdb2`, `wListPointer` unchanged at `$cdb4`).
- **Note on the "hang":** static analysis of the whole BUY→quantity→confirm→purchase path shows
  only bounded loops and valid jumps, joypad polls under VBlank0 (works), and the debug mart shares
  the code and runs — so I could not isolate a pure infinite loop. The two fixes above are the
  concrete defects (wrong items + font-state corruption on every BUY); re-test the mart. If it still
  locks up **after** these, it is a context/timing issue and needs the crash PC (see issue 1 steps).

### Issue 1 — intermittent HARD CRASH on entry (mart / pokecenter 1F / Route 2 gate) ❌ NOT FIXED
User: full room draws, **then** hard-crashes (music left buzzing one note = CPU executing
garbage / corrupted `ret`); intermittent; **never recurs on that map once it has loaded once in a
session.** Ruled out by static analysis, all three maps vs the non-crashing Old City buildings:
- **Not tileset** — MART / POKECENTER / GATE are three different tilesets.
- **Not map structure** — headers identical in shape to the non-crashing museum/gym/houses.
- **Not the script layer** — `SetUpMapBuffer` clears `wMapScriptNumber` every load, and on plain
  entry (no A-press) `QueueMapTextSubroutine`/`CallMapTextSubroutine` do nothing, so `RunMapScript`
  can't `jp hl` through a stale index; the generic script path is bank-safe for these maps.
- **Not music** — Mart/Pokecenter share `MUSIC_VIRIDIAN_CITY` with the non-crashing museum/gym; the
  gate uses `MUSIC_ROUTE_1`.
- The three maps share **no** static differentiator the non-crashing buildings lack, so this looks
  like a **runtime timing/VRAM race in the map-load path** (same class as round 14's black-flash
  race), not map data. Intermittent + "resolves after first success per session" fits a race whose
  outcome depends on where in the frame the CPU is, and/or an interrupt landing at a bad moment
  (this build takes a STAT interrupt every scanline — see "VRAM bandwidth" below).
- **Latent bug found while investigating (NOT confirmed as the cause, left untouched):** for maps
  using `map_generic_scriptloader` that are **not** registered in `data/maps/scenes.asm` (mart,
  pokecenter 1F, museum, gym, houses…), `SetUpMapBuffer` finds no match, so `wMapScriptNumberLocation`
  stays `$0000` (cleared), and `WriteBackMapScriptNumber` then writes to `$0000` every frame — an MBC
  RAM/RTC-enable-register write (writes 0 = disable). Probably benign (SRAM unused in the overworld;
  `UpdateTime` re-latches), and it does **not** explain the gate (which is registered, valid
  location), so it is likely not the crash — but it is clearly unintended. Do not "fix" it blind: it
  affects every generic unregistered map and changing `WriteBackMapScriptNumber` is global.
- **NEXT STEP: get the crash PC.** Simplest capture in SameBoy: open the debugger console
  (Cmd-click the game window → "Show Console", or the debugger window), leave it open, and reproduce.
  On a garbage-execution crash SameBoy usually breaks on an illegal opcode and prints the `PC`; if
  not, hit Break while frozen and `reg` to read `PC`/`SP`. Map the PC through
  `pokegold-spaceworld-debug.sym` (or `-correctheader.sym`) to the routine and this is solvable
  immediately. Without it, any fix is a guess and would burn a playtest cycle.

---

## PREVIOUS SESSION (2026-08-10, round 16) — finish Phase 3 GEAR + round-1 playtest fixes

Four-phase pass (0: Old City Mart freeze, 1: Trainer Card localize, 2: Pokédex entries, 3: Trainer
GEAR). Phases 0–2 landed earlier this session; this round finished Phase 3 and fixed the user's first
playtest report. **All items below build warning-clean on all 8 ROMs and are decode-verified; every one
is PLAYTEST-PENDING** (new/changed gameplay — the user runs SameBoy).

### Phase 3 — Trainer GEAR: start-menu entry + MAP gated on Ken's upgrade ✅
Step 1 (start-menu "GEAR") was already wired: `START_GEAR`=9 → `StartMenu_Gear` (trainer-card-style
opener, `callfar OpenTrainerGear`), added to every story-progressive `StartMenuItems` set;
`constants/start_menu_constants.asm` appends the const. Finished **Step 2** — gate the MAP card, suppress
RADIO/PHONE — in `engine/trainer_gear/trainer_gear.asm`:
- `TrainerGear_PlaceIcons`: draws the MAP icon **only when** `CheckEvent RIVAL_HOUSE_GOT_POKEGEAR_MAP`
  (set by Ken in `maps/RivalHouse.asm`). RADIO/PHONE icons never drawn (view code kept, unreachable).
- `TrainerGear_InitPointerSprite`: resets `wTrainerGearCard=$ff` on every return to the icon screen (the
  single MAP card can't otherwise be reopened past DetermineView's "already here" guard), and skips
  creating the cursor sprite while locked (clock-only; B exits).
- `TrainerGear_Joypad`: A is a no-op until the event is set. `AnimateTrainerGearModeIndicatorPointer.move_right`
  is now `ret` — cursor pinned to MAP so RADIO/PHONE stay unreachable even after unlock.
- **Decode-verified**: each `CheckEvent` = `ld hl,$d46b`(wEventFlags+4)/`bit 2,[hl]` (event 34), all
  `jr z`/`ret z` land right, `wTrainerGearCard=$ff` writes $cb94, `move_right`=`c9`.
- **Playtest**: new game → START → GEAR = clock, no map icon; beat rival + Ken's upgrade in Rival's
  House → reopen GEAR → selectable MAP with player icon; radio/phone never appear.

### Round-1 playtest fixes
- **Trainer Card (Phase 1)** ✅ (`engine/menu/start_menu.asm`): the bottom row is a two-tab selector
  (CARD | BADGES, ←/→, arrow at col 4/11). The kana labels had been blanked, so both arrows pointed at
  nothing — added English `CARD@`/`BADGES@` via `PlaceString` (bytes decode-verified). Also blanked the
  stray `$FE/$BA` tiles that rendered as a lone "8" after "COLLECT BADGES".
- **Pokédex species line (Phase 2)** ✅ (`engine/pokedex/display_dex_entry.asm`): `PokedexText_Pokemon`
  was `db "#"` (7-col POKéMON token) printed flush against the category. Now `db " <PK><MN>"` — leading
  space + the Pk/Mn ligature ($e1/$e2, part of the base 128-tile font so it renders on the dex screen).
  Bytes `7f e1 e2 50`.
- **Collision — swept the whole tileset set** ✅ — the big one. Player walked through walls in the mart
  + outdoor Old City (confirmed NOT debug noclip). Root cause is a durable trap (new pitfall below):
  tilesets that never shipped in the demo authored walls with the *old* passable subtypes. Converted
  **every** offending file (`data/tilesets/*_collision.asm`), on `tilecoll` lines only:
  `OLD_WALL`($01)/`OLD_WALL_INSIDE`($04)/`OLD_MART_ITEM`($72)→`WALL`($07, solid), and
  `OLD_COUNTER`($73)→`COUNTER`($90, solid **and** the value `CheckFacingObject` keys on for talk-across —
  fixes the mart clerk being unreachable across the counter). **22 tilesets** touched: mart, old_city,
  gate (Route2↔Old City + all gates), plus the M2+ outdoor/dungeon/city tilesets (birdon, cave, font,
  forest, hightech, kanto, north, office, power_plant, radio_tower, rocket_house, ruins_of_alph, ship,
  ship_port, south, west, dept_store) and the shipped `house`/`lab` (which used mostly `WALL` already —
  only a handful of old tiles each; walls/counters becoming solid is semantically safe but **re-playtest
  PlayerHouse / RivalHouse / the lab** to be sure). Decode-verified mart block 09=`07 07 07 07`, mart
  counter quarter=`90`, gate block 02=`07 07 03 03` / block 05=`90 90 90 90`. The Silent Hill town/route
  and Old City's tower/gym/pokecenter interiors already used `WALL` and were never broken.
  **Playtest**: walls solid in mart + outdoor Old City + the Route 2 gate; clerk/attendant talkable
  across counters.

### Reported, not done (needs its own effort)
- **Pokédex AREA button does nothing** — `.Area` sets `VIEW_AREA_F` but **nothing consumes it**; the
  area-display routine (`engine/pokedex/pokedex.asm:627`) is explicitly "dummied out for the demo". A
  real fix needs the region-map area view wired up + per-mon landmark/location data. Separate feature.

---

## PREVIOUS SESSION (2026-08-09, round 15 cont'd #2) — M1d's second slice: Old City Mart

### Old City Mart, working BUY (Poké Balls + 7 healing/field items) ✅ (BUILD-VERIFIED, byte-decoded, PLAYTEST-PENDING)
`maps/OldCityMart.asm` had the same shape as the Pokécenter did: clerk + 2 NPCs placed, everything
stubbed. `engine/debug/field/pokemart_menu.asm` (the debug FIELD menu's item shop) already had almost
the whole BUY flow built — scrolling item list, quantity picker with a live running total, confirm
prompt — but the actual purchase was **never wired up**: confirming always printed "Sorry, this is
under development," even in the debug tool. Rather than write a second copy of that UI for a real town
(ROM is at 100% capacity, this would have been the second such implementation), pulled the reusable
part out into a new exported `RunMartBuyMenu::` (takes a `-1`-terminated item-ID list in `de`) and gave
it a real purchase completion. `DebugMart_Buy` now just calls it with its own item list, so **the debug
mart can actually buy things for the first time too**, as a side effect.

Purchase completion, in order (deliberately: give the item before charging, so a full pocket costs
nothing rather than needing a refund path):
1. `CompareBytes` (`home/util.asm`, already existed) against `wMoney` vs `hMoneyTemp` (the live
   price × quantity total `SelectQuantityToBuy` already leaves behind) — carry set = can't afford it.
2. `ReceiveItem` (`home/item2.asm`) into `wNumBagItems`, or `wNumBallItems` if the item is
   `ITEM_POKE_BALL` — Poké Balls have their own pocket, same as the PACK UI (`CheckItemsQuantity` etc.
   in `start_menu.asm`). Carry clear = pocket full, no charge.
3. A plain LSB-first `sbc`-chain 3-byte subtract of `hMoneyTemp` from `wMoney` (mirrors the existing
   BCD-free money-add code in `engine/battle/core.asm` for battle winnings — `wMoney` is plain binary,
   not packed BCD, unlike the debug mart's *static* per-row price display which repacks into BCD nibbles
   for `PrintBCDNumber`; don't confuse the two representations if touching this again).

`maps/OldCityMart.asm`'s own script: clerk opens a welcome box that **fully closes** (`prompt`) before a
separate `OldCityMartMenu` routine draws BUY/CANCEL (mirrors `FieldDebug_PokemartMenu`/`.DoPokemartMenu`'s
two-separate-calls shape) — deliberately *not* one continuous `start_asm`-nested text stream, because
`prompt` ends the box and hands control back to the caller rather than falling through to more text data
in the same block; an earlier draft of this session's own diff put a second `text` block after a `prompt`
and it would have been dead, unreachable data. Sells POKé BALL/POTION/ANTIDOTE/PARLYZ HEAL/AWAKENING/
BURN HEAL/ESCAPE ROPE/REPEL (8 items, same count as `DebugMart_ItemList`, a proven-safe size for the
shared `wBattleMenuRows`/`wCurMartCount` scratch buffers). No SELL option — wiring one up means reusing
the PACK's sell flow too, and a working BUY-only mart reads as complete on its own; SELL can come later
without disturbing this. The room's 2 other NPCs and its sign got flavor text only.

**Two real bugs caught by verification, not by the assembler** (both would have shipped silently):
- The first draft had `call RunMartBuyMenu` instead of `callfar` — `RunMartBuyMenu` lives in
  `main.asm`'s bank ($3f) while the map script lives in `maps.asm`'s bank ($25). RGBDS resolves `call`
  targets to a bank+offset and happily assembles a same-opcode cross-bank call with no warning; at
  runtime it would have jumped to whatever code happens to sit at that offset in **whichever bank the
  map script's own bank last had mapped**, not the mart routine. Caught only by decoding the assembled
  `call` and noticing the target address didn't match the bank actually mapped at that point. **This is
  a general trap, not specific to this file: a plain `call`/`jp` to a cross-file label always assembles
  without error even when it's wrong — only `callfar`/`farcall`/`predef` are bank-safe.** Grep for stray
  bare `call`s to labels defined in a different top-level `.asm` object when something "does nothing" at
  runtime despite building clean.
- A copy-paste during a rewrite left two different strings both named `OldCityMartTextString4`, with two
  callers each intending a different one (RGBDS would have caught this one at assemble time as a
  duplicate symbol, but it's worth naming as the kind of mistake this style of incremental same-name
  string authoring invites — number sequentially as you go, don't reuse a number after inserting text
  earlier in the file).
- **Verified by decode**: hand-traced every `jr`/`jp` target in `RunMartBuyMenu`'s purchase-completion
  block (insufficient-funds branch, ball-vs-bag-pocket branch, pack-full branch, the 3-byte payment
  loop's back-edge, all three outcomes converging on `.done`) against the `.sym` addresses — every single
  one landed exactly on its intended label, not just "close" or "probably". Also confirmed
  `OldCityMartItemList`'s assembled bytes (`05 12 09 0d 0c 0a 13 14 ff`) against each `ITEM_*` constant's
  documented hex value one at a time.
- **PLAYTEST NEEDED**: talk to the clerk, buy something (check money decreases correctly, item appears
  in PACK — POKé BALL specifically in the ball pocket, everything else in the regular pocket), try to buy
  more than you can afford (should decline gracefully, no partial charge), and CANCEL should just say
  goodbye with no purchase. This is new content, first look in an emulator.

---

## PREVIOUS SESSION (2026-08-09, round 15 cont'd) — M1c found already done; M1d's first slice (Pokémon Center)

### M1c (Quiet Hills / route to Old City) — turned out to already be complete
Checked before writing anything: `maps/QuietHills.asm` already has all 5 trainers, wild grass, and both
signposts (`QuietHillsSignpost1String` already reads "OLD CITY, this way"); `data/wild/maps/Route1.asm`,
`Route2.asm`, `QuietHills.asm` all have real (non-stub) encounter tables already wired into
`GrassWildMons`; the Route1↔QuietHills↔Route2 warp graph is fully bidirectional (checked both sides of
every `warp_event`). This is all preserved prototype content from the original decompilation, not
romhack-added — the **NEXT UP** note calling this out was stale. Player reaches Old City today via
Route1 → Route2 → the map's own `connection north, OldCity` edge (Route2 already edge-connects
directly to Old City; QuietHills is a side loop between Route1/Route2, not on that critical path).
No changes made here. Confirmed OldCity.asm itself (warps to all its buildings — Museum, Gym, Tower,
Bill's House, Mart, Pokécenter, Kurt's House, School — are already 100% present) and every one of its
building interiors (Pokécenter1F, Mart, Gym, ...) already have their **geometry and NPC placement**
from decompilation; what's actually missing for M1d is purely the **script layer** (dialogue/game logic)
— every interior currently ends in `map_dummy_text_pointers`/`_old` (a no-op stub).

### M1d, first slice: Old City Pokémon Center nurse ✅ (PLAYTEST-CONFIRMED)
`maps/OldCityPokecenter1F.asm`: replaced the `map_dummy_text_pointers_old` stub with a real
`map_generic_scriptloader`/`script_pointers`/`script` scaffold (same shape as `SilentHillPokecenter.asm`,
which already builds successfully with these same macros — no `data/maps/scenes.asm` registration
needed for this, that table is unrelated to whether a map's own `_ScriptLoader` runs; every map's
`\1_MapAttributes` embeds `dw \1_ScriptLoader` unconditionally per `macros/scripts/maps.asm`).
- **Nurse (object 1):** "Would you like me to heal your #?" yes/no, then `callfar
  AnimateHealingMachine` + `predef HealParty` + `wDefaultSpawnPoint = SPAWN_POINT_OLD` (already a valid
  spawn-point constant, and `data/maps/spawn_points.asm`'s 2nd `SpawnPoints` entry already resolves it to
  OldCity's outdoor town coords `$1b,$1d` — nothing needed there) + `SFX_FULL_HEAL`, all inside the
  `start_asm` hook while the box is still open — same proven pattern as `PlayerHouse2FCheckEmail`'s
  yes/no, and the flashing-lights animation is *meant* to play alongside the dialogue on real hardware,
  not after the box closes. Declining just gets a "take care" line.
- **Other 3 NPCs + the room's `<PC>` sign:** flavor text only. The PC deliberately does **not** call
  `PokemonCenterPC`/`bills_pc.asm` — that engine is still untranslated Japanese (M1e scope) and box-save
  is separately deferred; wiring it now would surface broken/foreign text. It just describes a dark
  screen, same spirit as Silent Hill's "under adjustment" PC.
- Two text rows initially overflowed `TEXTBOX_INNERW`=18 with `#` expanding to 7 columns ("to heal your
  #?" = 21, "My # got beat" = 19) — caught by hand-computing widths against the token-width table in
  "Text engine" below, not by a tool (this session didn't rebuild the width linter/decoder scratchpad
  tools; consider doing that before the next translation-heavy session). Fixed by moving `#` onto its own
  `cont` row in both places.
- **Verified by decode, not just build success**: `OldCityPokecenter1FHeal` ($25:47a3) — `call YesNoBox`,
  `jr c` landing exactly on `.declined` ($25:47ca), `callfar AnimateHealingMachine` (`ld a,$23` = bank
  $23, matching `layout.link`'s `ROMX $23` for the section healing_machine.asm lives in), `predef`
  dispatch, `ld a,$02`/`ld [wDefaultSpawnPoint],a` (SPAWN_POINT_OLD=2, confirmed against
  `constants/spawnpoint_constants.asm`'s const order), `ld de,$0002` (SFX_FULL_HEAL), `WaitPlaySFX`/
  `WaitSFX`, `PrintText` landing on `OldCityPokecenter1FTextString3`. Also hand-traced the text control
  bytes for both width-fixed strings against the `LINE`($4f)/`CONT`($55)/`PARA`($51) charmap tokens —
  every row's byte-span between control tokens matches its intended character count exactly (e.g. "to
  heal your" = 12 bytes between `LINE` and `CONT`, "#?@" = `CONT,$54("#"),$e6("?"),$50("@")` immediately
  followed by `START_ASM`,`call $47a3`).
- **PLAYTEST-CONFIRMED**: heal flow, animation, spawn-point respawn, and the other NPCs/PC sign all work.

---

## PREVIOUS SESSION (2026-08-09, round 15) — start menu delay, re-attempted with a minimal diff

### Save screen had a leftover "TEST" title ✅ (BUILD-VERIFIED)
`PrintSaveScreenText.MenuData` (`engine/menu/empty_sram.asm`) set `STATICMENU_PLACE_TITLE`, which makes
`PlaceVerticalMenuItems` (`home/menu_window.asm`) print an extra string onto the box's top border after
the item rows — that string was literally `"TEST@"`. Cleared the flag byte to 0 and dropped the trailing
`db 6` (title column offset) / `db "TEST@"` pair; the PLAYER/BADGES/POKéDEX/TIME rows are unaffected.

Round 14's textbox fixes (items 1 and 4 below) are now **PLAYTEST-CONFIRMED working**. This round
picked up item 5 (start menu delay), which round 14 had reverted after it broke the game outright.

### 0. Start menu open delay — re-fixed with a much smaller diff ✅ (PLAYTEST-CONFIRMED)
Same diagnosis as before: `DisplayStartMenu` revealed the screen (via `ReanchorMap`, freeze+reveal in
one call) *before* `OpenMenu` painted the box+items live on top — a visible two-stage "pause, then
pop." Round 14's fix attempt used hand-rolled `ldh a,[hROMBank]/push af/ld a,BANK(x)/call Bankswitch`
pairs to hop banks around the draw, and broke the game (audio corruption, START opened nothing, no
input reached the menu). Root cause was never confirmed then; this round found it by comparing against
**pret/pokegold's actual `StartMenu::`** (`engine/menus/start_menu.asm`), which does exactly this
draw-behind-the-freeze restructure using `farcall ReanchorBGMap_NoOAMUpdate` / `farcall
LoadFonts_NoOAMUpdate` — i.e. this codebase's existing `callfar`/`FarCall_hl` (`home/farcall.asm`), not
manual bankswitching. Re-reading round 14's design against that: **`OpenMenu` was split into a "draw"
half and a "wait" half with a live `de` register (the item-index-list base pointer) threaded across the
`ret`/`call` boundary via a `push de`/`pop de` pair that no longer had matching scope** — a `push`
without a guaranteed matching `pop` before the next `ret` corrupts the return address on the *next*
`ret`, sending execution into arbitrary code. That explains all three symptoms: a stray jump landing in
something that writes sound registers (BGM corruption), never reaching the joypad-wait loop (menu
"opened nothing"), and the game continuing to run something else entirely (free walking).

This round's fix avoids that class of bug entirely:
- **`home/menu.asm`**: `OpenMenu::` is now a thin `call OpenMenu_Draw / call OpenMenu_Wait / ret`
  wrapper (unchanged behaviour for its other five callers — bills_pc, main_menu, pokecenter_pc, both
  debug menus). `OpenMenu_Draw::` is the original body up through drawing the box/items and setting
  `hBGMapMode`. `OpenMenu_Wait::` **does not receive `de` from Draw at all** — it calls
  `GetMenuIndexSet` itself (a pure function of WRAM state `OpenMenu_Draw` already set up) to get a
  fresh copy, then `GetStaticMenuJoypad`. No register or stack value crosses the `Draw`/`Wait` boundary;
  both are independently stack-balanced (verified by decode below).
- **`engine/menu/start_menu.asm`**: `DisplayStartMenu`'s *first* open now does `ClearWindowData` →
  `callfar ReanchorBGMap_NoOAMUpdate` (freeze) → SFX/header/state setup → `OpenMenu_Draw` (box+items
  drawn while still hidden) → `callfar LoadFonts_NoOAMUpdate` (reveal) → `OpenMenu_Wait` (joypad). Only
  **one bankswitch pattern is used, twice, and it's the codebase's existing proven-safe farcall
  mechanism** (`FarCall_hl` already saves/restores `hROMBank` and `bc` around the call, used pervasively
  elsewhere in this same file for e.g. `callfar CheckItemMenu`) — no hand-written `Bankswitch` pairs.
  `.RefreshStartDisplay` (returning from a submenu like the PACK/Pokédex back to the start menu list)
  is **untouched** — it still calls plain `OpenMenu` live, no freeze, matching round 14's minimal-diff
  guidance of touching only the specific path the user complained about.
- ROM0 cost: the split is +6 bytes net in `home.asm` (a `ret`/wrapper call overhead only partly offset
  by removing a now-redundant third `GetMenuIndexSet` call and a `push de`/`pop de` pair the original
  needed to survive `UpdateSprites` clobbering `de`). This overflowed the **debug** ROM0 by 2 bytes;
  reclaimed by deleting `Unreferenced_Corrupt_GetPartyParamLocation_Old` (12-byte, zero-reference
  corrupt-data reconstruction in `garbage/garbage.asm`, `if DEF(_DEBUG)` branch — safe to delete now
  that `make compare` is abandoned, same precedent as the two prior deletions already noted there).
- **Verified by decode**: `DisplayStartMenu` at `04:5e2e` — `ClearWindowData`, `ld hl,$64c9/ld a,$01/call
  FarCall_hl` (bank 1 = `ReanchorBGMap_NoOAMUpdate`), SFX/header/state, `call $1e74` (`OpenMenu_Draw`),
  `ld hl,$651d/ld a,$01/call FarCall_hl` (`LoadFonts_NoOAMUpdate`), `call $1ec0` (`OpenMenu_Wait`), `jr`
  landing exactly on `.GotSelection` ($5e7c). `.RefreshStartDisplay`'s `call OpenMenu` ($1e6d) also
  falls through to the same `.GotSelection`. `OpenMenu`/`OpenMenu_Draw`/`.ExitMenu_NoPoppingError`/
  `OpenMenu_Wait` bytes hand-traced instruction by instruction: every `push` has a matching `pop` before
  its block's `ret`, confirmed against the disassembled bytes, not just the source.
- **PLAYTEST-CONFIRMED**: box appears with items already in it, no blank-box-then-pop, and normal menu
  navigation/selection (SAVE, PACK, Pokédex, EXIT, reopening after a submenu) all work correctly.

---

## PREVIOUS SESSION (2026-08-09, round 14) — textbox delay, actually fixed

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
  when a VBlank lands during a long CPU stretch (this was the round-19 mart BUY hang). Every other
  full-screen menu (trainer card, party, pokédex, stats) does `ldh a,[hMapAnims] / push af / xor a /
  ldh [hMapAnims],a` on entry and restores on exit; `RunMartBuyMenu` now does too. Do the same for any
  new full-screen menu reached from the overworld.

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
  generic loader and its first-frame `CallMapTextSubroutine` executes that stale pointer → the round-18
  `jp GameFreakText` crash. **Fixed round 19**: `SetUpMapBuffer` now `xor a / ld [wTalkingTargetType],a`.
  Keep that reset if you touch `SetUpMapBuffer`; don't re-introduce the leak.
- `CallMapTextSubroutine` is safe with both bits clear (short-circuits to `ret`), so the reset makes a
  stale `hCurMapTextSubroutinePtr`/`hLastTalked` harmless — you don't need to clear those too.

### Collision (the "walk through walls" trap — read before adding any new map)
- The proto carries **two collision-constant eras**. The *new* set (`COLL_WALL`=$07, `COLL_COUNTER`=$90,
  `COLL_FLOOR`=$00, …) is what `CollisionTypeTable` (`data/collision/collision_type_table.asm`) actually
  marks solid; the *old* set (`COLL_OLD_WALL`=$01, `COLL_OLD_WALL_INSIDE`=$04, `OLD_MART_ITEM`=$72,
  `OLD_COUNTER`=$73, …) mostly indexes to **LAND (passable)** in that table. A tileset whose walls use
  the OLD wall subtypes has **no wall collision at all** — the player walks straight through. The demo
  only exercised tilesets on the NEW set, so it never showed; unshipped tilesets (`mart`, `old_city`
  outdoor were the offenders) hid it until Old City became reachable.
- **How to check a tileset**: `grep -oE "OLD_[A-Z_]+" data/tilesets/<name>_collision.asm`. If its walls
  read `OLD_WALL`/`OLD_WALL_INSIDE`, they are passable — convert those `tilecoll` args to `WALL`. A
  working reference tileset (`pokecenter`, `tower`, `gym`, `traditional_house`) uses `WALL`/`FLOOR`.
- **Counters**: talk-across-a-counter is done by `CheckFacingObject`, which only fires on `cp
  COLL_COUNTER` ($90). `OLD_COUNTER` ($73) is both passable *and* never matched, so an NPC behind an
  old-counter tile is unreachable and the counter is walk-through. Use `COUNTER` ($90).
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

**Owed playtests (round 17, all decode-verified, PLAYTEST-PENDING):** Trainer Card — 7-char name now
reads "NAME/xxxxxxx" and fits; CARD/BADGES tabs on the *badge* page flip back to the card page (←/→ +
A) without exiting to the start menu. Mart clerk — "What can I do for you?" and the BUY list render as
**text, not sprites**, and a purchase completes. Teach the FALSE SWIPE TM (or any TM) to a
long-named mon — the "learned" line must show the **full move name**, not the mon name spliced in.

**Crash FIXED at root in round 19 (Fix B) — PLAYTEST-PENDING.** The round-18 "stale `wMapTextPtr`"
framing was slightly off; the real mechanism is stale **talking-target state** surviving a warp — see
CURRENT SESSION item 1 above for the full write-up and the durable pitfall below. Fix A
(`GameFreakText`→`MapDefaultText` in `dummy_text_pointers.asm`) was **deliberately NOT applied** (the
user asked for the deep fix, not the band-aid), so those dummy tables still print/execute
`GameFreakText` — but with the talk-state reset they are never reached from a freshly-loaded map. If a
future map with a real generic loader needs its outdoor NPCs/signs to actually respond, populate that
map's own text table with real routines (the dummy `ret` loaders don't dispatch at all today).

**Owed playtests (round 16, all decode-verified, PLAYTEST-PENDING):** Trainer GEAR (clock before Ken /
selectable MAP after); Pokédex species `Pk/Mn` line; collision sweep (walls solid in the mart, outdoor
Old City, and the Route 2 gate; counters talk-through) **plus a regression check of the shipped
PlayerHouse/RivalHouse/lab**, whose tilesets were also touched; Old City Mart BUY transaction.

### Milestone 1 content (playtest-led; do not dump large untested assembly)
- **M1c — first route: DONE**, turned out to already be fully authored in the original decompiled
  content (trainers, wild tables, signposts, warp graph) — see round 15 above. Nothing to do here.
- **M1d — Old City (the big one).** Maps/warps/NPC placement are already 100% present from
  decompilation; what's missing is purely the **script layer** (every building interior currently ends
  in a `map_dummy_text_pointers` stub) — see round 15 above for how to read that quickly per-building.
  - **Pokémon Center: DONE** (nurse heals + sets spawn point, PLAYTEST-CONFIRMED). The other centre
    buildings (Route18, Kanto, Stand, Sugar, Newtype, Font, North, Blue, West, HighTech, South, Route15,
    Kanto2 Pokecenters) are all still stubs with the same `SPRITE_NURSE` object already placed at (5,1)
    — same recipe applies to each, later milestones.
  - **Mart: DONE this round** (real BUY with money + pocket handling, see round 15 above,
    PLAYTEST-PENDING). `RunMartBuyMenu::` (`engine/debug/field/pokemart_menu.asm`) is now shared,
    reusable infrastructure — a second real town mart just needs its own item list + a few lines of
    script calling it, not a UI rewrite.
  - **Still needed: Gym #1.** `OldCityGym.asm` already has `SPRITE_HAYATO` — presumably the
    Brock-equivalent leader — plus a `SPRITE_GYM_GUY` guide and 4 trainer-shaped NPCs already placed,
    needs a new `TRAINER_*` class/party + badge bit consumed by `PrintNumBadges` + script. And the first
    §3 story hooks (missing-professor radio bulletin / the sealed Five-Story Pagoda + phantom-bird
    rumour / the High-Tech "other Oak").
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
and warped to `wDefaultSpawnPoint`, falling back to `SPAWN_POINT_SILENT` (Silent Hill town). Old City's
centre is now wired (round 15, PLAYTEST-PENDING) as the template — see above. Every other centre map is
still a stub, and Silent Hill's nurse is deliberately "under repair" (keep it; MOM in `PlayerHouse1F` is
the first act's heal source). Same recipe for each remaining real centre's nurse script:
1. `callfar AnimateHealingMachine` (`engine/overworld/healing_machine.asm`) + `predef HealParty`.
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
- **Trainer GEAR town map is not navigable (NEXT-SESSION action point, user-reported round 18).** The
  GEAR flow is correct (clock before Ken's upgrade, selectable MAP after) but the MAP card just renders
  — there is no region-map cursor. Retail lets you arrow a cursor across every landmark on the town map
  with the location name shown. This is a **feature, not a fix** (same class as the dummied Pokédex AREA
  view): needs a region-map cursor sprite + arrow-key movement stepping through landmark coordinates +
  per-landmark name display. `AnimateTrainerGearModeIndicatorPointer.move_right` was pinned to `ret` in
  round 16 to lock the cursor to MAP; that pin (and `TrainerGear_Joypad`'s A no-op) is where a real map
  view would hook in. Larger piece of work — schedule its own session.
- **Pokédex AREA button is a no-op.** `.Area` (`engine/pokedex/pokedex.asm:1261`) sets `VIEW_AREA_F` but
  nothing consumes it; the real area-display routine (`pokedex.asm:627`) is explicitly "dummied out for
  the demo". Wiring it up needs the region-map area view **plus per-mon landmark/location data** — a
  feature, not a fix. Until then it silently does nothing (user-reported round 16).
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
