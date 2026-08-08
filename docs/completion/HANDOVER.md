# feature/completion — Session Handover

**Living baton between Claude sessions.** This project (extending the Space World '97 demo into a fuller, playable adventure) spans multiple sessions. Read this first, update it before ending your session. Authoritative plan: `~/.claude/plans/in-docs-you-hinted-linear-hearth.md`. Narrative target: `docs/index.html` §2/§3 ("Story of Nihon").

Branch: `feature/completion`. We have **abandoned the `make compare` byte-match guarantee** — this is a downstream romhack now. Correctness = **builds warning-clean + boots & plays in SameBoy**. Do **not** touch `roms.sha1`.

---

## Verification vocabulary (be honest about this)

- **BUILD-VERIFIED** = assembles, links, correct bytes confirmed in the symbol map. Claude can do this.
- **PLAYTEST-PENDING** = needs SameBoy (and/or real hardware) to confirm in-game behavior. Claude cannot run the emulator — **the user playtests**. Never claim a gameplay behavior "works" without a playtest; say "build-verified, playtest-pending".

---

## Standing build rules (every session)

- Build target: `make -j8 gold_debug silver_debug gold silver` (debug ROMs give the debug field menu for warp/testing). **Never run bare `make`** (it invokes `compare`, which is expected to fail now).
- **TEST THE `-correctheader` DEBUG ROM ON SAMEBOY**, i.e. `pokegold-spaceworld-debug-correctheader.gb` / `pokesilver-...`. The base `.gb` is stamped **MBC1** (`0x0147=03`) only to byte-match the original dump, but the game drives an **RTC** (`StartRTC`, clock-set intro) which lives on **MBC3** — so the base ROM misbehaves/won't run on an accurate emulator. The `-correctheader` variant is re-stamped **MBC3+TIMER+RAM+BATTERY** (`0x0147=10`) + corrected global checksum, and is the actually-runnable build. (Confirmed 2026-08-06: base debug ROM does not play on SameBoy; correctheader does.)
- Keep `-Weverything -Wtruncation=1` clean.
- RGBDS pinned **v1.0.3** (`.rgbds-version`). Confirmed installed.
- **ROM is at 100% capacity (1 MB, MBC1, 64 banks).** Any bytes you add to a bank that's already full will fail linking with `section ... would overflow ROMX by N bytes`. Fix by reclaiming garbage padding (see "Reclaiming ROM space" below). ~377 KB of reclaimable garbage exists, incl. 11 fully-empty banks (`$20,$22,$28–$2e,$35,$3d`).
- For a strict global-checksum-correct ROM (flashcarts/verifiers), use the `-correctheader` variants (rgbfix `-f hg`). SameBoy ignores the global checksum.

---

## DONE this session (all BUILD-VERIFIED, all PLAYTEST-PENDING)

### M0 — Boot the authored story intro ✅ (also byte-verified)
- `engine/menu/main_menu.asm` `NewGame::`: `jp z, DemoStart` → **`jp z, GameStart`**. This is the clean source equivalent of the TCRF `0x5585` boot patch. Byte-verified: ROM `0x5583` is now `CA BB 55` = `jp z, $55BB`; sym confirms `GameStart = 01:55bb`, `DemoStart = 01:558d`.
- `engine/movie/oak_speech.asm`: swapped the `; unreferenced` comments — `GameStart` is now the booted intro; `DemoStart` is now the dead path (left in place).
- **Boot flow (important, verified by reading):** a plain Main-Menu **New Game** never sets `DEBUG_FIELD_F`, so it always takes `jp z` → `GameStart` (full intro: Oak speech, name self, name rival, set clock) → `IntroCleanup` → `OverworldStart` → spawn at `PLAYER_HOUSE_2F`. `GameStart` does **not** call `SetDemoEventFlags`, so story flags start clean and the authored intro plays. `InitializeNewGameWRAM` (called before the branch) already sets `START_MONEY`, name lists, a PC Repel, and Silent Hill as map — so `GameStart` is fully initialized; it deliberately gives **no** starter (you get it from Oak in the lab).
- **Main-menu label fix (added after first SameBoy test):** the demo computed the save-based menu choice (New Game / Continue) then discarded it (`ldh a, [hJoyState]` overwrote it) and forced the `M_PLAY_GAME` index set — so the menu only ever showed **"Play Pokemon" + "Option"**, never New Game. (Functionally harmless: "Play Pokemon" = `PLAY_POKEMON` → jumptable → `NewGame` → `GameStart`, so it already booted the story.) Fixed in `MainMenu::` to use the save-based choice → **NewGameMenu** (no save) / **ContinueMenu** (save exists), keeping the hidden DOWN+B+A → Set Time combo. `GetMenuIndexSet` (`home/menu.asm`) selects the Nth option-set list by `wWhichIndexSet` (M_NEW_GAME=0…M_SET_TIME=3).
- **Debug field menu still works for warp-testing:** Debug Menu → FIELD sets `DEBUG_FIELD_F` → `DebugSetUpPlayer` (all badges/mons, `SetDemoEventFlags` pre-completes the story) → free warp. So in a debug build you can choose: **New Game** (test the story from scratch) or **Debug→FIELD** (warp a pre-completed world). No gating of `SetDemoEventFlags` was needed.

### M1a — First rival battle fixed ✅ (byte-verified; superseded my first wrong attempt)
- **The docs' §2 diagnosis was backwards, and so was my first fix.** The real bug: `RivalGroup`'s three starter entries were **leftover Red/Blue-format data** — `db level, species, 0` with **no `"name@"`, no TRAINERTYPE byte, and no `-1` terminator**. `ReadTrainerParty` (`engine/battle/read_trainer_party.asm`) skips trainers by scanning for `$ff` and reads `"name@", TRAINERTYPE, mons…, -1`; with none of that present it ran off into neighbouring data and built a garbage battler (playtest showed a "level 8 Qwilfish" one-shotting the player).
- **Species use `DEX_*`, NOT `MON_*`.** Proven by the working trainers in the same file (`db 7, DEX_PARAS, …`) and by the player's starter (given via `GivePoke` with `wPlayerStarter = DEX_HONOGUMA`, which the user confirmed produced a correct Honoguma). My first attempt changed `DEX_→MON_` (wrong direction) — reverted.
- Final fix in `data/trainers/parties.asm` `RivalGroup::` — rewrote the 3 entries in the real format (byte-verified `50 00 05 9e ff` etc.):
  ```
  db "@", TRAINERTYPE_NORMAL
  db 5, DEX_KURUSU        ; ID 1 (also HAPPA / HONOGUMA for ID 2 / 3)
  db -1
  ```
  The `"@"` name is a placeholder — for `TRAINER_RIVAL`, `GetOTName` (`read_trainer_attributes.asm`) overrides the on-screen name with `wRivalName`. (+6 bytes → reclaimed from `Bank 0e Garbage`.)
- Mechanism: rival battle = trainer **class 9 = `TRAINER_RIVAL`**, ID 1–3 chosen by `GetLabPokemon` (`maps/SilentHillLabFront.asm`) from `wRivalStarter` (a `DEX_` value) via the `LabPokemon` table.
- **Known cosmetic follow-up:** the "wants to battle" line is `WantsToBattleText` = `wOTClassName`(=`wRivalName`) + `wStringBuffer1`(= the `"@"` empty data-name), so it reads slightly oddly (`<Rival>の　が…`). Harmless; polish later.
- PLAYTEST: fight the rival after each of the 3 starter choices; confirm a coherent **L5** counter-starter, winnable, and (bug #3) that **losing no longer resets** — `LostBattle` special-cases `TRAINER_RIVAL` (`core.asm:1680`) to show `RivalWinText` → `HealParty` → continue, so the reset was a side effect of the garbage battler and should be gone now.

### M1f — Evolutions restored ✅
- `data/pokemon/evos_attacks.asm`: the demo had **commented out** evolutions for demo-available species (to stop them evolving). Restored (uncommented) 10 developer-authored first-stage evolutions — zero invention:
  - Starters: **Happa→Hanamogura(L16)**, **Honoguma→Volbear(L16)**, **Kurusu→Aqua(L16)**. (Second stages Hanamogura→Hanaryu(L32) etc. were already active.)
  - Demo Gen-1: Pidgey→Pidgeotto(18), Rattata→Raticate(20), Ekans→Arbok(22), Pikachu→Raichu(Thunderstone).
  - Other proto: Hoho→Bobo(20), Mitsuboshi(18), Poponeko(18).
- Fixed **Eevee's corruption**: its evolution list (6 stone eeveelutions incl. proto Heart/Poison/Leaf-stone Espeon/Umbreon/Leafeon) was missing its terminating `db 0` — restored. Header comment updated.
- This added exactly **32 bytes** to `EvosAttacks`, overflowing bank `$10`. Reclaimed 32 bytes of `Bank 10 Garbage` padding (`garbage/garbage.asm`) by skipping the first 32 bytes of each of the 4 padding INCBINs (added `, 32`; the silver-normal one went `186`→`218`). See technique below.
- PLAYTEST: level a starter to 16 and confirm it evolves.

### M1-bug2 — Battle-loss handling (no more game-over reset) ✅ (PLAYTEST-VERIFIED 2026-08-07)
- **Root cause of the "any loss resets the game":** `OverworldLoop_ExitBattle` (`home/std_scripts.asm`) unconditionally did `.DemoGameOver` on `wBattleResult == LOSE` — print `つぎは　がんばるぞ！！` then `jp Init` (soft reset). This fired for **both** the rival fight and wild/trainer losses. (The "rival winning text then reset" the user saw was this game-over message, not the scene's dialogue — the scene script never got to run.) `LostBattle`'s existing `TRAINER_RIVAL` heal branch was real but moot: `ExitBattle` clears `wOtherTrainerClass`/`wBattleType` in `.CleanUpBattleRAM` **before** `OverworldLoop_ExitBattle` runs, and `StartBattle` overwrites the loss-carry with its own `scf`, so by the time we're in the overworld there was no surviving signal of what kind of loss it was.
- **Fix — new persistent flag `wBattleLossContinues`** (`ram/wram.asm`, repurposed the reserved padding byte after `wBattleResult`; symbol `00:cd5e`):
  - Reset to 0 at every battle start in `ClearBattleRAM` (`start_battle.asm`).
  - Set to 1 in `LostBattle`'s `TRAINER_RIVAL` branch (`core.asm`), right after the heal. `wBattleResult` is deliberately **left = LOSE** so the rival end-scene shows the correct "rival won" line (`SilentHillLabFrontTextString19`; TextString18 is the player-won line).
  - `OverworldLoop_ExitBattle` rewritten: on LOSE, if `wBattleLossContinues` ≠ 0 → return to main (scripted "can lose" fight, story continues in-place). Otherwise → **white out**: `predef HealParty`, then `hMapEntryMethod = MAPSETUP_TELEPORT` (reuses the proven debug-warp/teleport path → `MapSetup_FallingWarp`→`NewGame`→`LoadSpawnPoint`) to send the player to `wDefaultSpawnPoint`.
- **Respawn target = last Pokémon Center, with hometown fallback.** No Pokémon Center content exists yet (M1d pending), so `wDefaultSpawnPoint` is `SPAWN_POINT_NONE` for a fresh game. The whiteout falls back to `SPAWN_POINT_SILENT` (Silent Hill town, `$05,$05`) and stores it, so blackout always has somewhere to go. **Forward-compatible:** when M1d adds a Pokémon Center, its nurse/heal script should set `wDefaultSpawnPoint` to that town's spawn index (see `engine/events/field_moves.asm` for the setter pattern) and the same whiteout code will route there automatically. It does **not** hijack normal door warps (`MAPSETUP_WARP` doesn't call `LoadSpawnPoint`) or `Continue` loads (`MAPSETUP_CONTINUE` doesn't either); a New Game re-zeros it in `SetUpGameEntry`.
- **Known cosmetic follow-up:** the post-battle map is reloaded twice on a whiteout — `OverworldLoop_StartBattle` already set `MAPSETUP_RELOADMAP` (brief fade-in at the battle map) before `OverworldLoop_ExitBattle` overrides it to `MAPSETUP_TELEPORT` (fade out → fade in at spawn). So expect a ~½s flash of the battle location before the teleport. Harmless; to remove, decide the whiteout in `OverworldLoop_StartBattle` (where the loss result is still fresh) instead of `ExitBattle`.
- PLAYTEST: (a) **lose** the first rival fight → should show the rival's "I'll get stronger, bye!" line and continue the lab scene (no reset); (b) **win** it → unchanged; (c) faint to a **wild** mon or **trainer** → party healed + warped to Silent Hill town (no reset). +8 bytes reclaimed from `Bank 0f Garbage`.

### M1-bug3 — Phantom "Continue" + corrupt-save load fixed ✅ (PLAYTEST-VERIFIED 2026-08-07)
- **Root cause:** `CheckIfSaveFileExists` (`engine/menu/main_menu.asm`) trusted **`sOptions` bit 0** as the "a save exists" flag. On fresh/never-properly-saved SRAM that byte is `$ff` (see the comment on `InitOptions` in `home/load_options.asm`: `EmptyAllSRAMBanks` fills SRAM with `$ff`; the retail game instead zero-fills all of SRAM, "which this demo probably should've done"). So the main menu showed **Continue** for a nonexistent save, and picking it ran `TryLoadSaveFile` → checksum mismatch → `レポートの　ないようが　こわれています` ("save data corrupted") and loaded garbage → glitched city. The `.sav` the user saw appear during the clock-set is just the RTC/SRAM-enable being battery-persisted by the emulator — the intro never writes a real save (only `SaveMenu`/link do, via `SaveOptionsAndGameData` + `SavePokemonData`).
- **Fix:** rewrote `CheckIfSaveFileExists` to **validate the real game-data checksum** (the same test `VerifyChecksum` uses on load): a save "exists" only if `sChecksum + 2` is not the `$ff` sentinel **and** equals the checksum of `sGameData`. Both empty-SRAM patterns are handled — `$ff`-fill hits the sentinel; `$00`-fill mismatches (checksum of all-zero ≠ 0). The checksum loop is **inlined** (the shared `Checksum` lives in bank `$05`, and `farcall` clobbers `hl`, which `Checksum` needs as its data pointer). +43 bytes reclaimed from `Bank 01 Garbage`.
- Net effect: Continue only appears for a genuine, checksum-valid save; a real in-game save (once you reach a save point) still shows and loads Continue normally.
- PLAYTEST: (a) fresh boot / after the intro → title shows **New Game only**, no Continue; (b) once a real save exists (needs a save point — M1d, or the debug menu if it saves), Continue appears and loads cleanly.
- **Alternative / deeper fix if ever wanted:** zero-fill all SRAM banks on first boot like the retail game (the `InitOptions` comment's suggestion). Not needed given the checksum validation, and riskier (must not wipe a real save), so deferred.

### M1-bug4 — In-game SAVE option restored ✅ (PLAYTEST-VERIFIED 2026-08-07)
- **Root cause:** the start (overworld) menu never showed **SAVE** in normal play. `StartMenuItems` (`engine/menu/start_menu.asm`) has 5 item-sets; **set 4 is the only one WITHOUT SAVE**, and `GetStartMenuState` forced set 4 for all non-debug play (`ld b, 4` then `bit DEBUG_FIELD_F` → store). The demo deliberately disabled saving in normal play; debug-field play (with `SetDemoEventFlags`) fell through to the story-progressive sets 0–3, which all include SAVE — that's why saving only ever "worked" in debug.
- **Fix:** removed the `b = 4` non-debug shortcut so `GetStartMenuState` always derives the set from story events (0 pre-starter → 1 chose starter, adds PARTY → 2 got Pokédex, adds POKEDEX → 3 rival battled, adds BACKPACK). **All of sets 0–3 include SAVE**, and Debug→FIELD still lands on set 3 (it pre-sets every event). Set 4 is now unused (left in the data; harmless). Net byte reduction, no garbage reclaim needed.
- `StartMenu_Save` → `predef SaveMenu` → `SaveOptionsAndGameData` + `SavePokemonData` (party/badges/bag/position/dex persist). **Boxes still don't persist** — `Dummy_SaveBox` is stubbed; that's the separate M1e work. With M1-bug3, a real save now produces a valid checksum so **Continue works after saving**.
- PLAYTEST: open the field menu (START) in normal play → **SAVE present**; save, soft-reset, and confirm **Continue** loads your progress. The menu should also grow as you progress (PARTY after starter, POKÉDEX after Oak, BAG after the rival fight).

### M1-bug1 — Lab-back Poké Balls vanish after being taken ✅ (BUILD-VERIFIED, playtest-pending)
- **Mechanism learned:** per-scene object visibility is driven by the **NPCID list** attached to each `script_pointer` (2nd word). `InitObjectMasks` (`home/map.asm`) masks *all* objects then unmasks only those in the current scene's NPCID list; `_InitializeVisibleSprites` spawns unmasked ones. `RunMapTextSubroutine`→`RunMapScript` runs the scene script (`ScriptN`) indexed by `wMapScriptNumber` **every overworld frame** (`OverworldLoop_Main`). Object consts equal their map-object indices (`object_const_def` starts at `NUM_RESERVED_OBJECTS`=2; `STARTER_HONOGUMA`=4, `KURUSU`=5, `HAPPA`=6 = the 3 ball object_events in header order).
- **Fix (`maps/SilentHillLabBack.asm`):** two small helpers using home `DeleteObjectStruct` (takes map-object index in `a`; removes the sprite **and** masks the object):
  - `SilentHillLabBackRemovePlayerBall` = `wChosenStarter + STARTER_HONOGUMA`.
  - `SilentHillLabBackRemoveRivalBall` = the next ball in the cycle (`honoguma→kurusu→happa→honoguma`), i.e. `((wChosenStarter+1) mod 3) + STARTER_HONOGUMA`. Verified against the rival's movement table: player HONOGUMA→rival KURUSU, KURUSU→HAPPA, HAPPA→HONOGUMA.
  - **Player's ball** removed in `ConfirmPokemonSelection` right after `GivePoke` (i.e. immediately after the Yes/No confirm).
  - **Rival's ball** removed in `SilentHillLabBackScript5` right after the "rival received X" line (`TextString13`).
  - **Re-entry persistence:** `SilentHillLabBackScript7` (the `CUTSCENE_OVER` steady-state script) calls both removers, so walking back into the room after the cutscene keeps the two taken balls gone. `DeleteObjectStruct` is idempotent, so the per-frame re-call is a cheap no-op once deleted. The **third, untaken ball stays** on the table (not deleted) — matches the live cutscene.
- **+~35 bytes → bank `$34` overflowed by 35**; reclaimed 35 from the four `Bank 34 Garbage` trailing padding INCBINs (skip `115`→`150` for debug-gold/silver + non-debug-gold, and `149`→`184` for non-debug-silver). Note bank `$34`'s garbage is a fragile *corrupt-data reconstruction* with offset arithmetic — **only** the trailing `INCBIN "garbage/[debug/]bank34_*.2bpp", N` lines are safe to trim.
- PLAYTEST: for each of the 3 starter choices, confirm (a) your ball vanishes right after the Yes/No confirm; (b) the rival's ball vanishes when he takes it; (c) the remaining untaken ball is still there; (d) walk out to the lab front and back in — the two taken balls stay gone, the third remains.

---

## Reclaiming ROM space (the technique you WILL need)

When adding bytes overflows a full bank:
1. Identify the overflowing bank from the linker error (`Bank NN Garbage ... overflow by X bytes`).
2. In `garbage/garbage.asm`, find that bank's section. It ends in one or more `INCBIN "garbage/...NN....2bpp"` padding lines (usually 4 variants: gold/silver × debug/normal, guarded by `if DEF(_DEBUG)`/`if DEF(_GOLD)`).
3. Trim X bytes from **each** variant's padding by skipping the first X bytes: `INCBIN "...", X` (or if it already has an offset `, n`, use `, n+X`). No need to know file sizes — the skip shortens the include.
4. For **large** additions, instead delete a whole `"Bank NN Garbage"` block for one of the 11 empty banks and add a real `SECTION "...", ROMX` there, registering it under the matching `ROMX $NN` header in `layout.link`. New `.asm` files must be added to `ROM_OBJ` in the `Makefile`.
5. Only if you cross 1 MB total: grow `layout.link` past `ROMX $3f`, switch rgbfix `-m` to **MBC5** in the `Makefile`, and check `home/bankswitch.asm` writes the full bank number.

---

## NEXT UP — remaining Milestone 1 (the "polished first act")

All of the below is content/scripting that is best done **with the user playtesting each step**. Do not dump large untested assembly blobs.

### M1b — Verify the authored intro cluster plays (PLAYTEST-led) — IN PROGRESS
**Playtest round 1 (user, 2026-08-07) found 3 lab bugs; round 2 (2026-08-07) confirmed rival party fixed but loss-reset + phantom-Continue still broken — both now addressed at the source:**
1. **Chosen Poké Ball doesn't vanish from the lab-back table** — FIXED (see **M1-bug1** below), build-verified, playtest-pending.
2. **Rival battle party** — FIXED (see M1a), user confirmed in round 2.
3. **Game resets after losing** (rival AND wild/trainer) — FIXED properly this round; the round-1 note blaming the garbage battler was wrong. Real cause = `OverworldLoop_ExitBattle`'s `.DemoGameOver` reset on any LOSE. See **M1-bug2** above. Re-verify per its PLAYTEST checklist.
4. **Phantom "Continue" loads a corrupt/glitched save** (found round 2) — FIXED. See **M1-bug3** above.

Remaining intro verification after re-test: naming screens, bedroom spawn, movement stability, and the full path to `SCENE_SILENT_HILL_LAB_FRONT_FINISHED` (6 Poké Balls, free roam).
The intro is fully authored across `PlayerHouse2F/1F.asm`, `RivalHouse.asm`, `SilentHill.asm` (rival boast + Blue's grass tutorial), `SilentHillLabBack.asm` (choose 1 of 3 proto starters; rival takes the counter), `SilentHillLabFront.asm` (Oak speech, Pokédex, **fixed** rival battle, Nanami's backpack, 6 Poké Balls → `SCENE_SILENT_HILL_LAB_FRONT_FINISHED`). Now that `SetDemoEventFlags` no longer pre-sets flags, walk it start→finish and fix any scene-ID/flag ordering the demo-skip was masking. Docs warned the raw byte-patch "destabilises overworld movement… tends to crash" — verify our clean source build is stable; if movement breaks, investigate `SetUpGameEntry`/`SpawnPlayer` and the `PLAYER_HOUSE_2F` spawn.

### M1c — Polish first route (QuietHills + Route1/Route2 → Old City)
`maps/QuietHills.asm` already has 5 `InitTrainerBattle` calls + wild grass (`data/wild/maps/QuietHills.asm`), reachable from Route1/Route2. Add trainer dialogue, a signpost objective ("Old City lies west"), chain warps toward Old City, and confirm/add wild tables for Route1/Route2 (`data/wild/maps/`, listed in `data/wild/grassmons.asm`).

### M1d — Script Old City (Pokécenter, Mart, Gym #1, story hook) — the big one
Old City maps exist as geometry-only stubs. Use the **content pipeline pattern** (below). Deliverables: nurse dialogue (healing engine works — **and the nurse/heal script should set `wDefaultSpawnPoint` to this town's `SPAWN_POINT_*` so the M1-bug2 whiteout routes here instead of the Silent Hill fallback**), a Mart item roster, **Gym #1** (guide NPC + 1–2 gym trainers + a leader battle with a new `TRAINER_*` class/party + badge award via a `wJohtoBadges` bit consumed by `PrintNumBadges`), and the first **§3 story hook** NPC(s): the "missing professor" radio bulletin / a townsperson pointing at Old City's sealed Five-Story Pagoda and the phantom-bird rumor / a line foreshadowing the High-Tech "other Oak".

### M1e — Box save persistence — DEFERRED, needs care + playtest ⚠️
**Do not just delete the `ret` in `Dummy_SaveBox`** (`engine/menu/empty_sram.asm:225`). Investigated: `wBox` is **not** in the saved `wPokemonData` region; `TryLoadPokemonData` does **not** restore `wBox`; Bill's PC operates on the WRAM `wBox`; and **no `sBox`→`wBox` load exists anywhere**. So un-stubbing save alone is unsafe: load game → empty `wBox` → save again → `SaveBox` overwrites good `sBox` with empty → boxed mons lost. Correct fix = un-stub `SaveBox` **and** add a symmetric load-current-box-on-load (`sBox[wCurBox]`→`wBox`, after `TryLoadPokemonData`) **and** handle box-switch save/load in Bill's PC. Verify a boxed mon survives save+reset in SameBoy. **Off the critical path** — party/badges/bag/position already persist via the working main save; boxes only matter when the party is full and you catch more.

---

## Content pipeline pattern (repeat per town/route)

Maps are **hand-written Z80 assembly** in `maps/*.asm` (no Gen-2 bytecode DSL) calling engine routines. Macros in `macros/scripts/` structure headers/events/text/movement.
1. Pick an existing stub map (geometry + warps already exist for 200+ maps).
2. Add events in the header via `macros/scripts/maps.asm` (`def_object_events`/`object_event`, `def_warp_events`, `def_bg_events`). Model: `maps/SilentHill.asm:1-40`.
3. Write scene scripts as hand assembly (`OpenTextbox`, `FreezeAllOtherObjects`, `LoadMovementDataPointer`, `SetMapStatus`, `InitTrainerBattle`). Model: `maps/SilentHillLabBack.asm` (clean, self-contained) and `SilentHillLabFront.asm` (cutscene+battle).
4. Register scenes in **`data/maps/scenes.asm`** (`scene_pointers MAP, Label`) — this file is the index of "the authored game" (currently ~13 maps).
5. Add trainers (`data/trainers/parties.asm` + `attributes.asm` + `constants/trainer_constants.asm` + pic) and wild tables (`data/wild/maps/`).
6. Gate progression with `SetEvent`/`CheckEvent` (`macros/scripts/events.asm`).
7. Test via the debug warp menu (`data/maps/debug_warps.asm`) before wiring the normal path.

### Pokémon Center healing + blackout respawn (needed for M1d; ties into M1-bug2)
Confirmed 2026-08-07: **no Pokémon Center currently heals** — every center map is a stub. Silent Hill's (`maps/SilentHillPokecenter.asm`) nurse deliberately says `しゅうりちゅう` ("under repair, can't heal"); that's intended for the starting town, leave it. The heal engine exists and is unused by maps: **`predef HealParty`** (full heal) and **`AnimateHealingMachine`** (`engine/overworld/healing_machine.asm`, the ball-flash animation). The M1-bug2 whiteout already warps a fainted player to `wDefaultSpawnPoint` and heals — it just needs content to set that spawn. So each real town center (starting with Old City, `maps/OldCityPokecenter1F.asm`) should, in its nurse script:
1. Animate + `predef HealParty` (model a nurse on retail Gen-2 structure; none exists here yet, so you're authoring the first).
2. **Set `wDefaultSpawnPoint`** to this town's spawn index so blackout returns here (setter pattern: `ld a, SPAWN_POINT_OLD` / `ld [wDefaultSpawnPoint], a`).
3. **Spawn-point coords caveat:** entries in `data/maps/spawn_points.asm` are currently **outdoor town** coords (e.g. `SPAWN_POINT_OLD` = Old City `$1b,$1d`), so a blackout drops the player **in the town, healed**, not inside the center like retail. If you want retail-style "wake up inside the Pokémon Center," add a center-interior spawn entry (its own `SPAWN_POINT_*` + `GROUP_*_POKECENTER_1F` map/coords) and point the nurse at that. Either is fine — the whiteout code is agnostic.

---

## Roadmap beyond M1 (see plan file for detail)
M2 West + Gym #2 + assistant NPC + first Geruge-dan grunt → M3 Old City pagoda + phantom Ho-Oh (`houou`) + lab-PC letter, Gym #3 → M4 High-Tech city + impostor Oak (`SPRITE_EVIL_OKIDO`, `maps/HighTechImposterOakHouse.asm`) + Team Rocket, Gym #4 → M5+ remaining towns/gyms, Time Machine, Kanto-as-one-city + Elite Four, pagoda finale. Cross-cutting: author remaining ~100 proto evolutions/learnsets (retail fallback for corrupt lines).

---

## Engine facts worth remembering (from initial exploration)
- Near-complete Gen-2 **battle engine** (wild+trainer, damage/status/weather/AI): `engine/battle/`.
- **251 statted species** w/ level-up + TM learnsets: `data/pokemon/base_stats/`, `evos_attacks.asm`. Proto beta species present (Honoguma, Kurusu, Happa, Warwolf, …). Two numbering spaces exist: `MON_*` (`constants/pokemon_constants.asm`, Gen-1 internal order) and `DEX_*` (`constants/pokedex_constants.asm`, pokédex number). **Party/species-facing data uses `DEX_*`** — `wCurPartySpecies`, `wPlayerStarter`/`wRivalStarter`, trainer party species, `GivePoke`/`GetLabPokemon` all take `DEX_` values (verified: working trainers use `DEX_PARAS` etc.; player starter given via `DEX_HONOGUMA` works). The `MON_*` constants appear mainly in leftover Red/Blue data and are **not** what the party builder expects. When authoring parties/gifts, use `DEX_*`.
- Working **bag + item effects + Poké Ball catching** (`engine/items/item_effects.asm`), **party/box UI** (`engine/pokemon/`), **save/load w/ checksums** (`engine/menu/empty_sram.asm`), overworld encounters (`engine/overworld/wildmons.asm`).
- Minigames exist (`engine/games/`). Debug tools: `engine/debug/` (field menu, fight test, warps).

---

## Localization (English) — in progress

Turning the JP prototype English, reusing retail Gold/Silver's localization design.
Full plan: `~/.claude/plans/continuing-from-docs-completion-handover-compiled-trinket.md`.
Scope = **playable slice**: build the English infrastructure game-wide, translate all
name tables + system/battle/menu text + dialogue for **implemented** maps only; defer
Pokédex flavor & long descriptions. Insertion = script-assisted for fixed tables,
hand-authored for dialogue/fragments. Source of English strings: `docs/_glossary/`.

**Transition trick:** Latin charmap entries are aliased onto the SAME bytes as the kana
(retail's approach), so untranslated JP `db "…"` still assembles — it renders as Latin
gibberish until translated. Build stays green section by section.

### L0 — Font + charmap + name widths ✅ (BUILD-VERIFIED, playtest-pending)
- `gfx/font/font.png` swapped to retail pokegold's Latin tilesheet (same 128-tile/1bpp
  geometry; `LoadFontGraphics` base = byte `$80`).
- `constants/charmap.asm`: added `A–Z`→`$80`, `a–z`→`$a0`, ASCII space→`$7f`, punctuation
  (`' - ? ! . & / ,` etc.) at retail byte slots, all aliased over the kana.
- Name widths: `PLAYER_NAME_LENGTH` 6→8, `MON_NAME_LENGTH` 6→11 (retail), `STRING_BUFFER_LENGTH`
  10→13; `wPlayerName/wMomsName/wRivalName` now use the constant.
- **WRAM crunch (important):** this proto has flat 8KB WRAM, **no CGB WRAM banking** — widening
  overflowed WRAM by 79B. Fixes: (a) PC box (`wBox`/`sBox`) kept at JP width via new
  `BOX_MON_NAME_LENGTH`/`BOX_MON_OT_LENGTH` (`= NAME_LENGTH_JAPANESE`) since boxes are deferred
  (M1e); (b) the dormant 1352B `wBox` moved into a UNION arm overlapping `wOverworldMapBlocks`
  in the "Map Buffer" section (retail-style overlap; mutually exclusive with box access) — frees
  ~1.3KB. **M1e must** widen box widths AND verify the overworld map reloads on PC exit.
  **Crash fix (playtest round 1):** moving `wBox` out of the Party tail made
  `InitializeNewGameWRAM`'s 2nd ByteFill (`wBoxMonNicknamesEnd - wPlayerName`) go **negative**
  → runaway fill wiped the stack → "Illegal Opcode. Halting." at New Game. Fixed to clear
  `wPokemonDataEnd - wPlayerName` (Game Data + Party, contiguous); `wBox` is still zeroed by the
  1st ByteFill (`wShadowOAM..wNewGameWRAMEnd` covers the Map Buffer). Lesson: a buffer moved out
  of either clear range must not make those label subtractions negative.
- Reclaimed 10B Bank 0a garbage; fixed a picross `-Wcharmap-redef` warning (`newcharmap`).

### L1 — English naming keyboards ✅ (BUILD-VERIFIED, playtest-pending)
- `data/text/text_input_chars.asm` `TextEntryChars`: kana grid → **English UPPERCASE** 5-row
  keyboard (kept the existing 15-col×row geometry, so cursor tables/`GetLastCharacter` are
  unchanged). **Lowercase page + SELECT toggle added** (playtest round 2): `TextEntryCharsLower`,
  `wNamingScreenLetterCase` flag, `NamingScreen_PlaceKeyboard` (picks the page; InitText falls
  through to it), and a `.jumpselect` handler in `.ReadButtons` that flips case and redraws.
- `engine/menu/text_entry.asm`: grid row count 8→5 (`InitText` + cursor up/down clamps);
  prompts → English (`YOUR NAME?`, `RIVAL'S NAME?`, `MOTHER'S NAME?`, `BOX NAME?`, `NICKNAME?`);
  per-type max length split into `.StoreMonIconParams` (10, from `MON_NAME_LENGTH-1`),
  `.StoreSpriteIconParams` (7), `.StoreBoxIconParams` (8).
- Preset name menus English: `constants/player_constants.asm` (GOLD/SATOSHI/JACK, SILVER/SHIGERU/JOHN,
  MOM/MAMA/MOMMY) + `data/names/{player,rival,mom}_names.asm` ("NEW NAME"/"NAME").
- Reclaimed 8B Bank 01 garbage (prompts) + 81B Bank 04 garbage (lowercase page/toggle code).
- **START menu fix (playtest round 2):** the field/START menu lists the player name as an item;
  its box (`start_menu.asm` `.StartMenuHeader`) was 5 text cols wide, so a 6-char name overran
  the right border. Widened `menu_coords $0C→$0A` (7 text cols) and translated the items
  (POKEDEX/POKEMON/PACK/<PLAYER>/SAVE/OPTION/EXIT/FRAME/RESET). This is the general cascade:
  **any name/text box sized for 5-char JP names may overflow with 7-char English names** — widen
  per-box as they surface in playtest.
- **Known cosmetic (verify in playtest):** the on-screen END key is byte `$F0` → renders as `¥`
  in the Latin font (START also confirms); name-entry field placeholders are bytes `♂`/`♀`
  — confirm they still look like blanks; nickname prompt now on its own line (row 4).

**PLAYTEST (first real font check — do this before the big text translation):** on
`*-debug-correctheader.gb`, New Game → the name menu shows **NEW NAME + GOLD/SATOSHI/JACK**,
pick NEW NAME → **English A–Z keyboard**, type a name (B deletes, START confirms), then rival
& mom the same. Confirm letters render crisply (validates the font/charmap). NOTE: surrounding
text (main menu, Oak's speech) is still Japanese → **gibberish for now** (that's L-system/L-dialogue,
next). If the keyboard letters look correct, the whole foundation is proven.

### L2 — Name tables ✅ (BUILD-VERIFIED, playtest-pending)
Script-generated from each table's existing iid comment (scripts in scratchpad):
- **Pokémon** (`data/pokemon/names.asm`): 251 fixed **10-wide** `@`-padded entries. 1-151 use the
  iid = official English name (4 fixups: NIDORAN♀/♂, FARFETCH'D, MR.MIME); 152-251 use the demo
  romaji iid. `GetPokemonName` stride changed `rept 5` → a loop of `MON_NAME_LENGTH-1` (kept the
  home routine small). +1255B reclaimed from Bank 14 garbage (+40 more for type names).
- **Moves/Items/Trainer classes** (`@`-terminated, width 12): English via the glossary's
  `pretty()`/`MOVE_OVERRIDES`/`ITEM_OVERRIDES`/`TRN` (uppercased; trainer notes like "(proto…)" /
  "/ Green" stripped). Reclaimed Bank 10 +896 (moves), Bank 0e +161 (trainers), Bank 01 +116 (items).
  Unused/disabled item slots render as `?`.
- **Types** (`data/types/names.asm`): English strings (メタル→STEEL, とり→BIRD proto-only).
- **Length constants** bumped: MOVE/ITEM/TRAINER_CLASS `→13`. (TYPE_NAME_LENGTH still 5 — long type
  names like FIGHTING may clip in a narrow display column; verify/ widen if it shows in playtest.)
- **Inline engine name-strings** (`home/text.asm`): `#`→"POKéMON", <TRAINER>→"TRAINER", <PC>→"PC",
  <TM>→"TM", <ROCKET>→"ROCKET", EnemyText→"Enemy ", <GA> particle→" ".
- **Still JP (minor, deferred):** `data/maps/landmark_names.asm` (Town Map locations),
  `data/battle/stat_names.asm`.

**PLAYTEST:** get the starter → PARTY shows English mon name; battle → English move names (FIGHT),
enemy/own mon names, types; BAG → English item names; a route trainer → English class name. Watch
for **name overflow in party/battle/summary layouts** (boxes sized for 5-char JP names).

### L3a — Title / main menu + options menu ✅ (BUILD-VERIFIED, playtest-pending)
- **Main menu** (`main_menu.asm`): CONTINUE / NEW GAME / OPTION / PLAY # (=POKéMON) / SET TIME;
  widened `menu_coords` x2 13→14 for "PLAY POKéMON".
- **Options menu** (`options_menu.asm`): TEXT SPEED (FAST/NORMAL/SLOW), BATTLE SCENE (ON/OFF),
  BATTLE STYLE (SHIFT/SET), MONO/STEREO, EXIT, FRAME. **Column-critical:** the ▷ cursor X's are
  hardcoded (text speed 1/8/15; on-off 1/10), so each option word is placed one column right of its
  arrow — verified against the JP columns. Keep those columns if editing.
- **Continue save-info** (`DisplaySaveInfoOnContinue`/`PlayerInfoText`): PLAYER / BADGES / POKéDEX /
  TIME. Known follow-up: the player-name field (col 13) can overflow this box for a 7-char name
  (pre-existing tight layout) — widen the box if it shows.

### Playtest-round bugs — FIXED ✅ (PLAYTEST-VERIFIED by user 2026-08-07, round 8)
All 4 traced back to the widened name lengths (MON_NAME_LENGTH 6→11) exposing hardcoded
5-char-name assumptions (#1, #3) or an undersized WRAM buffer left at the old width (#2, #4 —
the same root cause). Took 4 rounds of playtest+fix (rounds 5-8, all same session) to land —
see the round-by-round breakdown in the session log below for what each pass actually fixed vs.
regressed. User confirmed all clean as of round 8.

1. **Party screen: level tag overwrote the name, then the HP number, then wasn't right-aligned
   with the bar (3 rounds).** Round 6 moved status/HP-bar/level all to the row below the name
   (matching retail: line 1 = name + HP text, line 2 = level + bar) but didn't account for
   `mon_stats.asm` `DrawHP`'s *own* internal offset — it unconditionally prints the HP current/max
   text 1 row *below* whatever `hl` (the bar position) it's given, so once the bar moved to the row
   below the name, the text landed a further row down (into the *next* mon's name row), not on the
   name's own row as intended. **Round 7 fix:** changed `DrawHP`'s text offset from `bccoord 1,1,0`
   (+1 row) to `-SCREEN_WIDTH+1` (-1 row, i.e. back onto the bar's row *above* — which, now that the
   bar itself sits one row below the name, is the name's own row). `DrawHP` has exactly one caller
   (the party screen) so this is safe to repoint outright. Also swapped status ↔ level columns on
   the bar row: status moved to col 3 (under the name/cursor), level moved to col 8, immediately
   left of the bar (col 11) with no gap, so level+bar now read as one right-aligned unit as
   described. Final layout per mon: row *N* = name (col 3) + HP text (col 12); row *N*+1 = status
   (col 3) + level (col 8) + HP bar (col 11–19).

2. **Enemy (rival) mon nickname overran into the player's own nickname.** Two independent bugs,
   both needed fixing:
   - **Source never filled:** `TryAddMonToParty` (`engine/pokemon/move_mon.asm`) only initialized
     the nickname for `wMonType == PARTYMON`, explicitly skipping OT/trainer party mons (comment:
     "Only initialize the nickname for party mon") — because it always wrote to the hardcoded
     `wPartyMonNicknames` destination, which would be wrong for an OT mon. So `wOTPartyMonNicknames`
     was **never written at all** for any trainer's auto-filled mon (species-default nickname) and
     stayed as leftover WRAM. Route trainers with explicit data happened to look fine by luck; the
     rival (auto-filled) read garbage. Fixed: mirrored the existing OT-name pattern — pick
     `wPartyMonNicknames` vs `wOTPartyMonNicknames` by `wMonType` and always fill both cases with
     the species default name via `GetPokemonName`. +4B reclaimed from `Bank 03 Garbage`.
   - **Destination undersized:** `ram/wram.asm` still had `wEnemyMonNickname:: ds 6` and
     `wBattleMonNickname:: ds 6` — never widened to `MON_NAME_LENGTH` (11) during L0, even though
     every write site copies a full `MON_NAME_LENGTH`-byte string in. `wBattleMonNickname` sits
     directly before the `wBattleMon` struct (Species/Item/Moves…) in WRAM, so the 11-byte copy
     overflowed 5 bytes into it — this was **also the root cause of bug #4 below**. Fixed both to
     `ds MON_NAME_LENGTH`.

3. **Battle menu "Pokémon" option now uses the real `Pk`/`Mn` ligature tiles.** Found them in the
   retail font sheet (`gfx/font/font.png`) at tile row 6, cols 1–2 (bytes `$e1`/`$e2` — previously
   an unmapped gap between `'` at `$e0` and `-` at `$e3`); visually confirmed by cropping/rendering
   the tiles. Added `charmap "<PK>", $e1` / `charmap "<MN>", $e2` to `constants/charmap.asm`.
   Translated the battle bottom menu in `engine/battle/menu.asm` (FIGHT / PACK / `<PK><MN>` / RUN)
   and `core.asm`'s "no will to fight" message. +3B `Bank 09 Garbage`, +3B `Bank 0f Garbage`.
   (The separate `gfx/font/font_battle_extra.png` asset is unused/not wired into the build — turned
   out to be unrelated HP-bar/HUD graphics, not the ligature.)
   **Round 6 follow-up:** initial word ORDER was wrong (FIGHT/PACK/`<PK><MN>`/RUN top-left→bottom-
   right), which put the two widest words FIGHT+PACK on the same row → "FIGHT" (exactly 5 chars)
   filled its whole column pitch (`wMenuData_2DMenuSpacing` = 5, unchanged) with zero gap, so PACK's
   text ran on immediately after and its last letter spilled past the box's right border. **Fixed
   per user-supplied retail ordering:** top-left FIGHT, top-right `<PK><MN>`, bottom-left PACK,
   bottom-right RUN (`.MenuData` list is row-major, so this is just item-list order).
   **Round 7 follow-up:** even in the correct order, FIGHT (exactly 5 chars) still fully consumed
   the 5-col pitch with zero gap before `<PK><MN>`, so the cursor arrow (drawn 1 col left of each
   item, i.e. right where the gap should be) landed on top of FIGHT's last letter when `<PK><MN>`
   was selected. Per user ("retail's box is one tile wider"): widened `BattleMenuHeader`'s box left
   edge from col 9 to col 8 (`menu_coords 8,12,19,17`) and bumped the column pitch (`wMenuData_
   2DMenuSpacing`, the `db` right after `dn 2,2`) from 5 to 6 — both needed together: wider pitch
   alone would push the right column past the box's right border; the extra column of box width is
   exactly what the wider pitch needs to still fit RUN (3 chars) in the bottom-right cell without
   crossing the border. Hand-verified column math for both rows before building.

4. **Moves displayed as all "PETAL DANCE" with impossible PP (30/20) — root cause was bug #2's
   undersized `wBattleMonNickname`.** Traced end-to-end: `LoadBattleMonFromParty`
   (`engine/battle/core.asm`) copies Species/Item/Moves into `wBattleMon` *first*, then copies the
   11-byte nickname into `wBattleMonNickname` *last* — and since that buffer was only 6 bytes, the
   trailing 5 bytes of the nickname (species names are `@`-padded to a fixed width, so a short name
   like "HONOGUMA" is followed by `@@@` padding/terminator bytes = `$50`) spilled into
   `wBattleMon`'s Species/Item/Move0-2 fields, overwriting them with `$50` — which happens to equal
   `MOVE_PETAL_DANCE`. Fixed by the same `ds MON_NAME_LENGTH` widening in bug #2. Honoguma's
   `evos_attacks.asm` data and the generic move-name lookup were both verified correct in the
   compiled ROM (byte-for-byte) — not the issue.
   **Round 6 follow-up:** fixing the move data surfaced a display-only bug in the same info box —
   the move's **type name** (e.g. "NORMAL") is printed via `predef PrintMoveType` at
   `engine/battle/core.asm` `MoveInfoBox`, previously `hlcoord 15, 16` inside a box whose interior
   only spans cols 10–18 (from `hlcoord 9,12 / ld b,4 / ld c,9 / call DrawTextBox`) — col 15 left
   only 4 columns before the right border, and `PlaceString` has no wrapping of its own, so text
   past col 19 just continued into the next tilemap row raw (explains the user's garbled
   "wraps mid-word, spills to bottom-left" report — that's the tilemap address wrapping around, not
   an intentional line break). Fixed: moved the print column to `hlcoord 10, 16`, directly under the
   (still-JP) "わざタイプ" label on the row above, giving the full 9-column interior width — fits
   the longest type names (FIGHTING/ELECTRIC, 8 chars) with no overflow.

### Next: PLAYTEST-VERIFIED as of round 8 (2026-08-07) → continue L-system rest (battle text, party/bag/summary), then L-dialogue.

### L-system continuation — core.asm battle master text ✅ (BUILD-VERIFIED, playtest-pending, 2026-08-07)
Translated all 76 `docs/_glossary/system_data.py` `"core.asm:*"` entries — every text block in
`engine/battle/core.asm` (fled/fainted/status-hit/weather/perish-song/safeguard/spikes/held-item/
no-PP/disabled/no-moves-left/encore/exp-gain/level-up/send-out/recall/can't-escape/no-will-to-fight/
trainer-switch/trainer-sent-out/rival-win/rival-loss/out-of-usable-mons/move-info-box labels). This
is the file that renders during **every battle**, including the one the user has been repeatedly
playtesting, so it was worth doing thoroughly rather than skimming.

**Text-engine mechanics learned (needed for every future Phase-3 file — read this before
translating another battle/menu text file):**
- `PlaceString` (`home/text.asm:102`) is the low-level char-placer. It stops the instant it hits a
  literal `@` byte (`charmap "@", $50`) and returns control to the **top-level** command dispatcher,
  `TextCommandProcessor`/`NextTextCommand` (`home/text.asm:403`). That dispatcher reads the very next
  byte as a **raw opcode index** into `TextCommands` (`TX_START`=0, `TX_RAM`=1 for `text_from_ram`,
  `TX_NUM`=9 for `deciram`, `START_ASM`=8, `TX_END`=$50, …) — it does **not** know about `<LINE>`/
  `<PARA>`/`<CONT>`/`<NEXT>`/`<PROMPT>`/`<DONE>` (those are charmap tokens $49–$58, only recognized
  **inside** an active `PlaceString` run, via its internal `CheckDict` table).
  - **Rule:** a literal `text "...@"` fragment must end in `@` iff another `text_from_ram`/`deciram`/
    `text_move`/`start_asm`/fresh `text`/`text_end` command follows immediately — that `@` is what
    hands control back to the top-level dispatcher for the next opcode. `<PLAYER>`/`<RIVAL>`/`<MOM>`/
    `<USER>`/`<TARGET>`/`#`(POKéMON)/`<PC>`/`<TM>`/`<TRAINER>`/`<ROCKET>` are all inline `CheckDict`
    tokens (like `<LINE>`) and can be used anywhere inside a run with no `@` needed around them.
  - **Rule (the one that will bite you):** `<LINE>`/`<PARA>`/`<CONT>`/`<NEXT>` can only appear
    **inside** an active `PlaceString` run. Writing a bare `line "..."` directly after a
    `text_from_ram`/`deciram` call is **broken** — the `<LINE>` byte ($4f) gets read as a raw
    top-level opcode index (garbage jump) instead of a cursor move. Fix: insert a bare `text_start`
    (emits `TX_START` with zero literal argument) between the RAM op and the `line`/`cont`/`para` —
    this opens a fresh `PlaceString` run whose first byte *is* the `<LINE>` token, which is valid.
    This exact idiom already existed once in the original source (`BattleText_EnemyWasDefeated`'s
    `text_from_ram` → `text_start` → `line`) — I just didn't recognize it as *required* until I
    traced `TextCommandProcessor` and found the opcode-table mechanism. Grep the file for
    `text_start` before `line`/`cont`/`para` as the template.
  - `TEXTBOX_INNERW` = 18 (`SCREEN_WIDTH`(20) − `BORDER_WIDTH`(2)) — the safe per-row character
    budget for the standard bottom textbox. `<PLAYER>`/`<RIVAL>`/`<TARGET>`/`<USER>`/name buffers
    expand to up to `PLAYER_NAME_LENGTH-1`(7) or `MON_NAME_LENGTH-1`(10) chars at render time — budget
    for the **worst case** width when a name shares a row with fixed text, or give the name its own
    row via `line`. Several encouragement/switch-in lines (GoForItMonText's "Go for it!",
    BattleText_EnemyWasDefeated's class+trainer-name row) were left un-linebroken for parity with the
    original's row-concatenation approach and **may overflow for a long name/trainer-name** — cosmetic
    only (raw tilemap-row wraparound, not a crash), flagged here rather than over-engineered, since
    these are rarer paths (mon switching mid-battle, defeating a trainer) than the very-common
    fled/fainted/status-hit lines which got dedicated `line` rows and are safe up to the full 10-char
    name width.
- **Found and fixed a real pre-existing bug while translating `TrainerAboutToUseText`** (shown when
  an opponent trainer is about to send in their next Pokémon mid-battle — i.e. **any multi-mon
  trainer fight**, which doesn't exist yet in the reachable content but will as soon as M1d/gym
  trainers are added): the original had a bare `line` (no `"@"` argument) sitting directly after a
  `text_from_ram` call — exactly the broken pattern above, and it was *already* flagged by a
  `; BUG:` comment above it (a pret-contributor note on an original prototype bug: "forgot to
  terminate the line… makes the game halt the script early"). Fixed by adding the missing `"@"`,
  matching the correct pattern already present one label below it (`TrainerSentOutText`). This was a
  latent crash risk for any future multi-mon trainer battle; now fixed at the source alongside the
  translation.
- `.Disabled`/`.Type` (`MoveInfoBox`, the small 9-col box under the move list) → `"DISABLED!"` /
  `"MOVE TYPE"`, both exactly 9 chars to fit the box's interior (no line-wrap available there, it's a
  raw `PlaceString` call, not a `text`-macro-driven textbox).
- Reclaimed **314 bytes** from `Bank 0f Garbage` (`garbage/garbage.asm`, offset 86→400 on all 4
  variants) — English battle text is substantially longer in byte count than the terse kana it
  replaced, even accounting for the many added `line`/`cont`/`text_start` control bytes.
- All 4 ROMs + `-correctheader` variants build warning-clean.
- PLAYTEST: fight the rival (win and lose), get poisoned/burned/asleep with a nightmare, faint a mon,
  win money, level up, catch enough EXP to see "grew to LV_", switch Pokémon mid-battle (Enough!/OK!/
  Good! + "Come back!"), try to run/can't-escape a trainer battle. Watch specifically for **name
  overflow** on the "Go for it! <NAME>!" and post-trainer-win "<CLASS> <NAME> defeated, you won!"
  lines if a caught mon or trainer ends up with a long name.

**Next: Phase 3 continues with `effect_commands.asm`** (89 glossary keys — move-effect messages,
seen on nearly every single turn of every battle, so second-highest priority after `core.asm`), then
`start_battle.asm`/`used_move_text.asm` (battle-start and "used MOVE!" text), then work down the
glossary's per-file key counts (`item_effects.asm`, `start_menu.asm`, `party_menu.asm`,
`pokecenter_pc.asm`, `learn.asm`, `bills_pc.asm`, `pokemart_menu.asm`, …) → then Phase 4 dialogue.
Apply the same text-engine rules above to every file — particularly the `text_start`-before-bare-
`line` rule, since every file with `text_from_ram`/`deciram` calls is at risk of the same bug class.

### L-system continuation — effect_commands.asm move-effect text ✅ (BUILD-VERIFIED, playtest-pending, 2026-08-07)
Translated all 89 `system_data.py` `"effect_commands.asm:*"` entries — every move-effect message in
`engine/battle/effect_commands.asm` (sleep/freeze/paralysis/confusion/flinch/recharge/disable/
infatuation/obedience/PP/miss/crash/type-effectiveness/critical/rage/substitute/status-infliction/
stat-up-down/multi-hit/charge-move flavor text/recoil/screens/protect/safeguard/held-item-activation).
Also translated `data/battle/stat_names.asm` (ATTACK/DEFENSE/SPEED/SP.ATK/SP.DEF/ACCURACY/EVASION —
not itself a glossary entry, but every stat-up/down message renders one of these, so leaving it
Japanese would have produced broken-looking mixed text on the single most common battle message).

- **Extended the `core.asm` text-engine rules**: same `text_start`-before-bare-`line` requirement
  applied throughout. `Text_BattleEffectActivate`/`Text_BattleFoeEffectActivate` (the "X's STAT rose!"
  /"sharply rose!" texts — used by every stat-changing move) use the pre-existing `<SCROLL>` control
  code (`_ContTextNoPause`) to scroll the stat name from row 2 up to row 1 before appending "sharply"/
  "harshly" fresh on row 2 — translated in place without altering that mechanism, since it already
  correctly solves the width problem (stat name and qualifier never share a row).
- **Hit a hard ROM-space wall this file** (new gotcha for future files, not just a "reclaim more
  garbage" situation): `SECTION "Effect Commands", ROMX` (bank `$0d`) is a single, hard-capped 16 KB
  (`0x4000`) RGBDS section — a section can never span multiple banks — and it was already close to
  full before translation (only 128 B of `Bank 0d Garbage` padding existed). The English text alone
  overflowed it by 387 bytes, which **no amount of garbage-padding trimming can fix** (that technique
  only helps when the *neighboring* section has slack, not when the section itself exceeds one full
  bank). Fixed by: (a) reclaiming the 128 B of `Bank 0d Garbage` (now skip-to-empty), (b) **deleting
  `Unreferenced_OldSleepTarget`** (~230 B) — a pret-flagged, zero-caller dead Gen-1-leftover sleep
  routine (comment already called it out: "Unreferenced. Seems to be early sleep code leftover from
  Gen 1"), confirmed via a codebase-wide grep for zero references before removing, and (c) tightening
  wording across ~20 of the wordier multi-line messages (merging redundant `line`/`cont` rows,
  dropping filler clauses like "Its moves may be blocked" → "paralyzed!", "were eliminated!" → folded
  into one line "All stats reset!"). **Lesson for future files:** if a bank-overflow error says
  "Section ... grew too big (max size = 0x4000...)" instead of the usual linker "would overflow ROMX
  by N bytes", garbage-trimming won't help — check for dead/unreferenced code in that file first
  (grep the label name codebase-wide for zero hits) before cutting translation wording.
- **Byte-efficiency note for future translation:** `<USER>`/`<TARGET>`/`<PLAYER>`/`<RIVAL>`/`#`
  are single-byte dict tokens at runtime regardless of the name's rendered width — prefer them over
  spelling out a literal pronoun/word ("affect <TARGET>" costs ~8 bytes; "affect it" costs ~10) when
  both read naturally.
- All 4 ROMs + `-correctheader` variants build warning-clean.
- PLAYTEST: see the consolidated **"Testable action points"** list the user requested — every
  status condition, stat change, multi-hit move, held item proc, and screen/protect move needs a
  battle to trigger it, so this is best covered by a longer play session hitting a variety of moves
  rather than one scripted path.

### L-system continuation — start_battle / used_move_text / item_effects / start_menu ✅ (BUILD-VERIFIED, playtest-pending, 2026-08-08)
Translated the next four files on the glossary's priority list (11 + 8 + 50 + 44 keys). All 4 ROMs +
`-correctheader` variants build warning-clean; emitted text bytes spot-checked against the ROM with a
charmap decoder (control opcodes, `text_from_ram` targets and `<LINE>`/`<PROMPT>` placement all verified).

**`engine/battle/used_move_text.asm`** — "X used MOVE!". This file lives *inside* `effect_commands.asm`
(it's `INCLUDE`d near the end), i.e. inside the hard-capped 16 KB bank-`$0d` section that hit the wall
last session, so it had to come out **smaller**, not bigger. It did (~30 B), and bank `$0d` now has
38 B of slack again.
- The Japanese sentence was assembled from a grammar table: `<USER>` + a particle (`の` / `は`, picked
  by `GetMoveGrammar` from `data/moves/grammar.asm`) + move name + one of **five** different sentence
  enders (`を つかった！` / `を した！` / `した！` / ` こうげき！` / `！`). English needs none of that
  distinction: both particle strings became `" used"` and all five enders became `"!"`, giving
  `<USER> used` / `MOVE!` (retail's rendering).
- **The grammar machinery is deliberately left in place.** `GetMoveGrammar`'s side effect —
  `ld [hl], a` into `wLastPlayerCounterMove`/`wLastEnemyCounterMove` — is what makes COUNTER work, and
  `wMoveGrammar` is a **union alias of `wNumSetBits`** (same WRAM byte, see `ram/wram.asm:1436-1443`),
  which is how `MoveNameText`'s ender-table index gets set. Don't "simplify" either away.
- Dropped `.UsedInsteadText` (the disobedience infix). English can't use it: the infix lands on row 1
  *before* `MoveNameText`'s `line`, so `<USER>`(10) + `" used"`(5) + `" instead,"`(9) = 24 columns, well
  past the 18-column interior. Disobedience is already announced by `IgnoredOrdersText` immediately
  before this text, so nothing is lost. `UsedMove1Text`/`UsedMove2Text` now share one
  `UsedMoveText_GetMoveNameText` tail.

**`engine/battle/start_battle.asm`** — battle-start banners, Pay Day payout, link-battle result strings.
- `WildPokemonAppearedText` / `HookedPokemonAttackedText` / `WantsToBattleText` were all restructured so
  **the name gets its own row** (`text "Wild @"` → RAM → `text_start` → `line "appeared!"`). A species
  name renders up to `MON_NAME_LENGTH - 1` = 10 columns; "Oh! A wild <NAME>" or "<NAME> appeared!" both
  blow past 18. Result: `Wild <NAME>` / `appeared!`, `Hooked <NAME>` / `attacked!`,
  `<CLASS> <NAME>` / `wants to battle!`.
- `BattleText_PlayerPickedUpPayDayMoney` → `<PLAYER> picked up` / `<n> yen!`.
- Link-battle `.YouWin`/`.YouLose`/`.Draw` and the `'Ｖ'`/`'Ｓ'` VS tiles ($69/$6a — JP-font-only glyphs
  that the retail Latin sheet doesn't have there) → plain `'V'`/`'S'`. Link play is unreachable content;
  translated for completeness only.

**`engine/items/item_effects.asm`** (50 keys) — ball-throw outcomes, capture/PC-transfer, nickname
prompt, vitamins, POKé FLUTE, Coin Case, PP restore/raise, TM/HM boot-up, and every "can't use that
here" refusal. Notable width decisions (all forced by the 10-char mon-name / 12-char item-name budget):
- `Text_GotchaMonWasCaught` → `Gotcha! <NAME>` / `was caught!`; `BallSentToBillsPCText` /
  `BallSentToSomeonesPCText` → `<NAME> went to` / `BILL's <PC>!` (resp. `someone's <PC>!`).
  **Naming call:** the glossary renders マサキ literally as "Masaki"; since this is an *English*
  localization and Bill has an official English name, the string says **BILL**. Easy to flip back.
- `ItemStatRoseText` → `<MON>'s base` / `<STAT> went up!` — the mon name (10) and the stat name (7)
  can't share a row. `StatStrings` → HEALTH/ATTACK/DEFENSE/SPEED/SPECIAL.
- `ItemUsedText`/`ItemGotOnText`/`ItemGotOffText` keep their `text_low` (TX_LOW) second-row jump:
  `<PLAYER> used` on row 1, item name + `!` on row 2.
- `.TMHMNotCompatibleText` lost its second paragraph (the redundant "<MOVE> can't be learned!"); the
  first one already says it, and neither the mon name nor the move name fits beside other words.

**`engine/menu/start_menu.asm`** (44 keys) — the whole PACK/field-menu surface: pocket title rows, item
action menus, toss confirm, held-item give/take, MAIL, party move-details pane, and the Trainer Card.
- **Static menu boxes: usable text columns = `x2 - x1 - 2`** (the cursor column is included in that
  budget). `SelectedItemMenu` had only 3 columns (JP `つかう`/`すてる`), so its `menu_coords` left edge
  moved `$0E`→`$0D` to fit **TOSS**. Menus are now USE/TOSS/SET (debug), USE/TOSS, GIVE/TAKE,
  READ/TAKE/QUIT.
- **Pocket title rows are fixed-width full-row strings** drawn with `PlaceString` over row 1 (plus a
  blank row 0). Each replacement keeps the original row's exact character count (20 / 20 / 19 / 18 / 20)
  so it still blanks the whole row: `ITEMS`, `KEY ITEMS`, `PACK`, `BALL HOLDER`, blank.
- **Party move-details pane got a layout change.** The JP put both labels on one row
  (`タイプ／ … いりょく／`, type value at col 5, power at col 15). English type names print **in full**
  via `PrintMoveType` (which `PlaceString`s the real string — only `GetTypeName`'s copy is truncated by
  `TYPE_NAME_LENGTH`), so FIGHTING/ELECTRIC (8 chars) would have run straight through the power label.
  Split it: `TYPE/` + value on row 12, new `PartyPowerText` (`POWER/`) + value on row 13. Row 13 was
  free — the surrounding `ClearBox` covers rows 11-16 and `PrintMoveDescription` starts at row 14.
- **Trainer Card:** it uses the normal font (it `PlaceString`s `wPlayerName` on the same screen), so the
  labels translate normally. `next` there steps **two** rows, which is why the labels land on rows 2 / 6
  / 10 next to the name (6,2), money (7,6) and dex count. `NAME` is deliberately 4 chars — the player
  name is placed at column 6 and would overwrite a 5th. "caught" is 6 columns where `ひき` was 2, so the
  dex count moved `13,10`→`10,10` and its suffix `16,10`→`13,10`. Badge page header → `LEAGUE BADGES`
  (dropping `#`, which expands to 7 characters and would have overflowed the row).
- Reclaimed **+187 B from `Bank 03 Garbage`** (item_effects) and **+139 B from `Bank 04 Garbage`**
  (start_menu). `used_move_text`/`start_battle` needed none — they shrank.

**Deferred from these files:** the `'▶'` / `'」'` cursor-and-marker tile literals in `start_menu.asm`
(party/trainer-card arrows) were left at their existing byte values — they're glyph tiles, not letters,
and the party screen already playtested fine with them.

**PLAYTEST for this batch:** (a) any battle — the start banner ("Wild X appeared!", trainer
"<CLASS> <NAME> wants to battle!"), then "<MON> used <MOVE>!" every turn; (b) BAG: open each pocket
(title rows), select an item (USE/TOSS menu — check TOSS isn't clipped), toss some, try using a
field-only item in battle and a battle-only item in the field (the refusal texts), press SELECT with
nothing registered; (c) party screen: pick a mon → move details (TYPE/ and POWER/ on their own rows,
values not overlapping), and the move-reorder prompt; (d) Trainer Card from the field menu (NAME/MONEY/
POKéDEX labels lined up with their values, badge page header); (e) catch something with a Poké Ball —
break-free/almost-had-it lines, "Gotcha! X was caught!", the dex-data line, and the nickname prompt;
(f) give/take a held item and the swap prompt.

**Next: `poker_minigame.asm` (27) / `party_menu.asm` (24) / `pokecenter_pc.asm` (21) / `learn.asm` (16)
/ `bills_pc.asm` (16) / `pokemart_menu.asm` (15)** — of these, `party_menu.asm`, `learn.asm` and
`pokemart_menu.asm` are on the reachable path for M1d (Old City mart + a gym), so they're the
higher-value ones; the minigames and PC are not reachable yet. Then Phase 4 dialogue. Keep applying the
text-engine rules above (`text_start` before a bare `line` after `text_from_ram`/`deciram`; 18-column
interior; give a name its own row whenever it would share one with more than ~8 characters), and check
for the hard 16 KB section wall in any near-full bank.

## Session log
- **2026-08-06** — M0 (boot GameStart, byte-verified), M1a (rival party fix), M1f (evolutions restored + 32B garbage reclaim). All build-verified, all playtest-pending. M1e investigated & deferred (unsafe blind). Established gotcha: **must test the `-correctheader` (MBC3/RTC) debug ROM on SameBoy** — the base MBC1 ROM doesn't run. First SameBoy test also surfaced the main-menu label bug (only showed "Play Pokemon") → fixed to show real New Game / Continue. Remaining: M1b/c/d content (playtest-led), then M1e.
- **2026-08-07** — Playtest round 1 feedback (3 lab bugs). Fixed **rival battle** properly (M1a rewrite: real trainer format + `DEX_` species, byte-verified; my earlier MON_ attempt was wrong) and by analysis the **loss-reset** (bug #3, was a garbage-battler side effect). Also fixed the **main-menu** to show real New Game/Continue. Still open: **bug #1** (chosen Poké Ball doesn't vanish in lab-back) — cosmetic, needs playtest to confirm intended behavior. Reclaimed 6B from `Bank 0e Garbage` for the reformatted rival party. _Next: user re-tests the rival battle (win AND lose) on `pokegold-spaceworld-debug-correctheader.gb`; if good, fix bug #1 then proceed to M1c/M1d._
- **2026-08-07 (cont.)** — Playtest round 2: rival party confirmed fixed, but (a) **losing any battle still reset** and (b) title showed a **phantom Continue** that loaded a glitched/corrupt save. Both fixed at the source, all 4 ROMs build warning-clean:
  - **M1-bug2** (loss handling): the reset was `OverworldLoop_ExitBattle`'s demo `.DemoGameOver` (`jp Init`) on any LOSE — not the garbage battler as round 1 guessed. Added `wBattleLossContinues` flag (set in `LostBattle`'s rival branch, cleared each `ClearBattleRAM`); rewrote `OverworldLoop_ExitBattle` so the rival fight continues in-place and wild/trainer losses **white out** (heal + `MAPSETUP_TELEPORT` to `wDefaultSpawnPoint`, hometown fallback). +8B from `Bank 0f Garbage`.
  - **M1-bug3** (phantom Continue): `CheckIfSaveFileExists` trusted `sOptions` bit 0 (= `$ff` on fresh SRAM). Rewrote it to validate the real game-data checksum (inlined; matches `VerifyChecksum`). +43B from `Bank 01 Garbage`.
  - Both **build-verified, playtest-pending** — see the M1-bug2 / M1-bug3 PLAYTEST checklists. _Next: user tests on `*-debug-correctheader.gb`: lose the rival (should continue), lose a wild/trainer (should heal+warp to Silent Hill town), and confirm the title shows New Game only until a real save exists. If good, fix bug #1 (lab-back Poké Balls) then M1c/M1d._
- **2026-08-07 (round 3)** — User confirmed bugs #2 and #3 fixed. Two follow-ups: (a) blackout heals in front of the house (Silent Hill outdoor spawn) — user OK with this as a fallback since Silent Hill's center is intentionally "under construction"; the ask is that **future town centers heal-warp correctly**, which is M1d content (see "Pokémon Center healing + blackout respawn" in the content pipeline — the whiteout mechanism is already generic, needs a nurse to set `wDefaultSpawnPoint`). (b) **SAVE missing from the field menu** — fixed (**M1-bug4**): `GetStartMenuState` forced the only no-SAVE item-set (set 4) for normal play; now it uses the story-progressive save-enabled sets (0–3). All 4 ROMs build warning-clean.
- **User confirmed ALL fixed** (M1-bug2/3/4 now PLAYTEST-VERIFIED). The lab intro (M1b) is effectively working end-to-end save the cosmetic bug #1. _Next: bug #1 (lab-back Poké Balls don't vanish) → M1c (QuietHills/routes) → M1d (Old City incl. the first working Pokémon Center + save point + Gym #1)._
- **2026-08-07 (round 4)** — Fixed **bug #1 / M1-bug1** (lab-back Poké Balls now vanish when taken; player's on confirm, rival's when he picks; third ball stays; persists on re-entry). All 4 ROMs build warning-clean; +35B reclaimed from `Bank 34 Garbage`. Build-verified, playtest-pending (see M1-bug1 checklist). Two side notes for the user:
  - **SGB border question (Gengar → Gold):** *not* a code change on this branch — nothing under `gfx/sgb`, `engine/gfx/sgb_layouts.asm`, `options_menu.asm`, or `load_options.asm` was touched. The border is a **user toggle** (SELECT in Options) stored in `sOptions` bit `SGB_BORDER`, read on boot by `LoadSGBBorderOptions`. `sgb_border_alt` = the "Pocket Monsters" **Gengar** border (bit clear), `sgb_border_gold` = the **Pokémon Gold** version border (bit set). Default follows raw SRAM: a brand-new/untouched `.sav` is `$ff` → bit set → **Gold** border; after the game's own `EmptyAllSRAMBanks`/`InitOptions` zero-fill (SRAM-clear menu) it's `0` → **Gengar**. So the observed flip is a `.sav`/SRAM-state artifact, not our edits; toggle back with SELECT in Options anytime.
  - **Save-then-reset showed no Continue (user, not reproducible):** had a valid post-rival save, started New Game, progressed to the starter-pick point, saved (overwrote), heard the jingle, `Cmd+R` reset → title showed **New Game only**. Could not reproduce afterward. Most likely a SameBoy `.sav`-flush timing artifact on soft-reset rather than a logic bug (a save at the pre-starter point *should* checksum-validate and show Continue via the M1-bug3 `CheckIfSaveFileExists`). **Watch item:** if it recurs, capture exact steps + whether a *hard* reset / clean quit (which forces a `.sav` write) also loses Continue; if so, investigate `SaveMenu`/`SavePokemonData` vs. the inlined checksum in `CheckIfSaveFileExists` for a region/ordering mismatch.

- **2026-08-07 — English localization started (big multi-session effort; see the "Localization (English)" section above and the plan `~/.claude/plans/continuing-from-docs-completion-handover-compiled-trinket.md`).** Scope = playable slice; strings sourced from `docs/_glossary/`. Completed & BUILD-VERIFIED this session (all 8 ROMs warning-clean): **L0** font+charmap+name-widths (incl. the flat-WRAM `wBox`→Map-Buffer-union overlap + `InitializeNewGameWRAM` ByteFill fix that resolved an early New-Game crash), **L1** English UPPER/lower naming keyboards (SELECT toggles case; START menu widened + items translated), **L2** name tables (Pokémon/moves/items/trainers/types + inline `#`/TRAINER/PC/TM/ROCKET strings; lots of garbage reclaimed across banks 01/0e/10/14), **L3a** title main menu + full options menu + Continue save-info labels. **PLAYTEST-VERIFIED by user:** English keyboards, lowercase toggle, START menu, title/main menu. **4 OPEN BUGS from playtest** (party level overwrites name; rival enemy-nickname overrun; battle Pokémon menu needs `<PK><MN>`; starter moves show all "PETAL DANCE" w/ bad PP) — full diagnoses + file:line leads in the **"OPEN BUGS"** subsection of the Localization section above. _Next session: fix those 4, then continue Phase 3 (battle/party/bag/summary system text) → Phase 4 (dialogue for implemented maps)._ Two minor name tables still JP: `data/maps/landmark_names.asm`, `data/battle/stat_names.asm`.
- **2026-08-07 (round 5)** — Fixed all 4 playtest-round localization bugs from the previous session (see "Playtest-round bugs — FIXED" in the Localization section above for full diagnoses). All 4 ROMs build warning-clean throughout.
  1. **Party level tag** (`party_menu.asm` `.PrintLevel`): moved from `name_start+5` to `+10` columns, clear of the widened 10-char name field.
  2. **Rival enemy nickname overrun** — two bugs: (a) `TryAddMonToParty` never filled the nickname for OT/trainer party mons at all (only player-party mons) — fixed to fill both, picking the right destination table by `wMonType`, mirroring the existing OT-name pattern (+4B `Bank 03 Garbage`); (b) `wEnemyMonNickname`/`wBattleMonNickname` in `ram/wram.asm` were still `ds 6`, never widened to `MON_NAME_LENGTH` during L0 — fixed to `ds MON_NAME_LENGTH`.
  3. **Battle menu `<PK><MN>` ligature** — found the actual tiles in `gfx/font/font.png` (row 6, cols 1–2; confirmed by cropping/rendering), added `charmap "<PK>"`/`"<MN>"` at `$e1`/`$e2`, translated the battle bottom menu (FIGHT/PACK/`<PK><MN>`/RUN) and the "no will to fight" message. +3B `Bank 09 Garbage`, +3B `Bank 0f Garbage`.
  4. **Starter moves all "PETAL DANCE" w/ bad PP** — traced to the *same* undersized `wBattleMonNickname` from bug #2: it sits directly before the `wBattleMon` struct in WRAM, so the 11-byte nickname copy overflowed 5 bytes into Species/Item/Move0-2, and the nickname's `@`-padding tail (byte `$50`) happens to equal `MOVE_PETAL_DANCE`. Fixed by the same widening; no separate change needed. Verified Honoguma's `evos_attacks.asm` data and the generic move-name lookup were both byte-correct in the compiled ROM before concluding this — the bug was purely the WRAM buffer overflow.
  - _Next: user playtests round 5 on `*-debug-correctheader.gb`: party screen with a full name (level shouldn't overlap), the rival battle (its name shouldn't run into the player's, and the player's own name shouldn't show corruption from a subsequent enemy encounter), the battle FIGHT menu's `Pk`/`Mn` option (should render as the two-line ligature, not gibberish or the full word), and the starter's FIGHT menu (should show real moves — SCRATCH/LEER for a level-5 Honoguma — with sane PP, not "PETAL DANCE" x4). If clean, continue Phase 3 (battle/party/bag/summary system text) → Phase 4 (dialogue)._
- **2026-08-07 (round 6)** — Playtest round 5 found #2 and #4 clean, but #1 and #3 needed follow-up fixes (see "Playtest-round bugs" section above for full diagnoses); all 4 ROMs build warning-clean throughout.
  1. **Party level tag, take 2:** landed on the HP current/max text (`:L5/ 20`) — turns out `mon_stats.asm` `DrawHP` prints the HP fraction on the *name's own row*, not the bar's row. Matched retail's real layout per user correction (name+HP on line 1, level+bar on line 2 below): swapped the status/HP-bar block to the row *below* the name instead of above, moved level there too. Each mon's block now spans rows `[2i+1, 2i+2]` instead of `[2i, 2i+1]` (row 0 goes unused) — icon position is index-driven, unaffected.
  3. **Battle menu order:** initial FIGHT/PACK/`<PK><MN>`/RUN ordering put the two widest words (FIGHT, PACK) on the same row, exactly filling the 5-column pitch with zero gap → "FIGHTPACK" concatenation and PACK's last letter spilling past the border. Fixed to retail's actual order (user-supplied): FIGHT top-left, `<PK><MN>` top-right, PACK bottom-left, RUN bottom-right — pairs each wide word with the 2-tile ligature instead of another wide word; fits the box's ~8-column interior with the pitch unchanged.
  4. **Move type overflow (found while fixing #4 last round):** `MoveInfoBox`'s type-name print (`hlcoord 15, 16`) only had 4 columns before the box's right border — `PlaceString` doesn't wrap, so long names ("NORMAL", "ELECTRIC") ran off the tilemap row and reappeared mid-word on the row below. Moved to `hlcoord 10, 16` (under the "わざタイプ" label), giving the full 9-column interior.
  - _Next: user re-playtests rounds 5+6 together. If clean, continue Phase 3 (battle/party/bag/summary system text) → Phase 4 (dialogue)._
- **2026-08-07 (round 7)** — Playtest of round 6 found #2 and #4 fully fixed; #1 and #3 needed one more pass each (see "Playtest-round bugs" section above for full diagnoses). All 4 ROMs build warning-clean.
  1. **Party level tag, take 3:** round 6 moved the bar/level to the row below the name but didn't account for `mon_stats.asm` `DrawHP` printing its HP-fraction text a further row below *whatever row the bar is on* — so once the bar moved down, the text landed on the *next mon's* name row instead of staying on *this* mon's name row. Fixed `DrawHP`'s offset from `bccoord 1,1,0` to `-SCREEN_WIDTH+1` (`DrawHP` has exactly one caller, so safe to repoint). Also swapped status↔level columns on the bar row so level sits immediately left of the bar (col 8) with no gap, reading as one right-aligned unit; status moved to col 3.
  3. **Battle menu cursor overlap:** even with the correct word order, FIGHT (exactly 5 chars) still fully consumed the 5-col pitch, so the cursor arrow for the next item landed on FIGHT's last letter. Per user ("retail's box is one tile wider"): widened `BattleMenuHeader`'s box by 1 col (`menu_coords 8,12,19,17`) and bumped the column pitch 5→6 — both needed together, since a wider pitch alone would push the bottom-right RUN past the border; the extra box width is exactly what makes RUN still fit.
  - _Next: user re-playtests rounds 5–7 together. If clean, continue Phase 3 (battle/party/bag/summary system text) → Phase 4 (dialogue)._
- **2026-08-07 (round 8)** — Playtest of round 7 found: `DrawHP`'s repointed offset (round 7 fix #1) also broke the **battle HUD** (name overwritten) — `DrawHP` isn't party-screen-only, it's shared by `DrawPlayerHP` (battle HUD **and** stats screen) and `DrawEnemyHP` (party screen only); round 7 changed the shared code path instead of just the party one. Also found the **battle menu PKMN/PACK actions swapped** (a leftover from the round-6 text reorder), and the **party screen HP bar/sprite rendering grayscale** instead of colored. All fixed, all 4 ROMs build warning-clean (+10B reclaimed from `Bank 14 Garbage` for the `DrawHP` branch).
  1. **`DrawHP` battle-HUD regression:** made the offset conditional on `wWhichHPBar` (already set to 1 by `DrawPlayerHP`, 2 by `DrawEnemyHP` — the one piece of state that already distinguished the two callers). `wWhichHPBar==1` (battle/stats) keeps the original `+SCREEN_WIDTH+1`; `wWhichHPBar==2` (party) uses the round-7 `-SCREEN_WIDTH+1`.
  2. **Battle menu PKMN↔PACK swap:** `BattleMenu`'s dispatch (`engine/battle/core.asm`, ~line 3218) reads `wStartmenuCursor`/`wMenuCursorPosition` (a 1-indexed row-major position: TL=1,TR=2,BL=3,BR=4 — verified via `Battle_2DMenu`'s `cursorX + (cursorY-1)*numRows` math) and still branched `cp 2 → Pack, cp 3 → PKMN`, matching the *original* JP order (FIGHT/ITEM/POKe/RUN) rather than the round-6 reordered display (FIGHT/`<PK><MN>`/PACK/RUN). Swapped to `cp 2 → PKMN, cp 3 → Pack` to match the display.
  3. **Party screen grayscale HP bar/sprite:** traced to `data/sgb/blk_packets.asm` `BlkPacket_PartyMenu`, the SGB color-region table for the party screen — unrelated to any DMG/CGB palette code, this project's only in-game colorization is via SGB ATTR_BLK packets. Two bugs found: (a) the 6 per-mon HP-color rects' Y-coordinates were never updated for the round-6/7 row swap (still `12,2i` / `18,2i+1`, one row too high — same category of bug as #1 above, just in SGB data instead of code); (b) their region mask was `%010` (SGB "line/border only" — the *interior* of the rect, where the bar/text actually render, was never recolored, matching "only a hair of color" symptom), should be `%011` (line+inside) matching the *exact* same pattern already used successfully by `BlkPacket_Battle`'s equivalent small HP-color rects (region mask `%011`, palette bytes `\2=\3=`health color`, \4=0` — identical structure to what `SGB_ApplyPartyMenuHPPals` already writes into the party packet's palette byte, confirming the mask was the only thing wrong). Also widened the icon-column block's Y-range (`02,12`→`02,15`) since icons are 2 tiles tall and mon 5's (index 5) icon pixel position works out to tile rows 13–15, past the old bottom edge — **this one is a lower-confidence fix** (reasoned from the icon Y-position formula in `mon_icons.asm`, not cross-checked against a known-working reference like the HP-bar fix was) and may need another look if sprites are still off after this.
  - **User confirmed all clean** — battle HUD, battle menu actions, and party screen colors (bar + icon) all correct. Localization Phase 1/2/L0-L3a + the M1b playtest-round bugs are now fully closed out. _Next: continue Phase 3 (battle/party/bag/summary system text) → Phase 4 (dialogue for implemented maps)._
- **2026-08-07 (Phase 3 start)** — Translated all 76 `core.asm` glossary strings (the battle master text — fled/fainted/status/weather/perish-song/safeguard/spikes/held-items/PP/disabled/no-moves/encore/exp/level-up/send-out/recall/escape/no-will-to-fight/trainer-switch/rival-win-loss/out-of-mons/move-info-box). All 4 ROMs build warning-clean; +314B reclaimed from `Bank 0f Garbage`. See the new **"L-system continuation — core.asm battle master text"** subsection above for the full text-engine mechanics writeup (the `PlaceString`/`TextCommandProcessor` opcode-boundary rules — required reading before translating any more battle/menu text files) and a real pre-existing crash bug found+fixed in `TrainerAboutToUseText` (bare `line` after `text_from_ram` reads the `<LINE>` byte as a garbage top-level opcode; fixed by inserting `text_start`). Build-verified, playtest-pending — see that section's PLAYTEST checklist. _Next: `effect_commands.asm` (89 keys, move-effect messages seen almost every turn) is the next-highest-value file, then `start_battle.asm`/`used_move_text.asm`, then down the glossary's per-file key counts toward Phase 4 dialogue._
- **2026-08-07 (Phase 3 cont.)** — Translated all 89 `effect_commands.asm` glossary strings (every move-effect message: status conditions, confusion, stat changes, multi-hit, charge-move flavor text, substitute, screens, held items) plus `data/battle/stat_names.asm` (needed by the very common stat-change text, not itself a glossary entry). Hit and resolved a new class of problem: the "Effect Commands" section is a hard-capped 16 KB RGBDS section (can't span banks) and was already nearly full — garbage-padding trimming alone couldn't fix the 387-byte overflow. Fixed via reclaiming the 128B of `Bank 0d Garbage`, deleting a pret-flagged zero-caller dead subroutine (`Unreferenced_OldSleepTarget`, ~230B, verified via codebase-wide grep before removing), and tightening wording on ~20 of the wordier messages. See the new **"L-system continuation — effect_commands.asm move-effect text"** subsection above for the full writeup and the "hard 16KB wall" lesson for future files. All 4 ROMs build warning-clean. Build-verified, playtest-pending. _Next: `start_battle.asm`/`used_move_text.asm`, then `item_effects.asm`/`start_menu.asm`, watching for the same bank-size wall in any near-full bank._
- **2026-08-08 (Phase 3 cont.)** — Translated `start_battle.asm` (11 keys), `used_move_text.asm` (8), `item_effects.asm` (50) and `start_menu.asm` (44) — the battle-start banners, the per-turn "X used MOVE!" line, every ball/capture/item-refusal message, and the whole PACK + party-details + Trainer Card menu surface. All 4 ROMs + `-correctheader` variants build warning-clean; emitted bytes spot-verified in the ROM. Reclaimed +187 B `Bank 03 Garbage` and +139 B `Bank 04 Garbage`; `used_move_text.asm` shrank ~30 B, which put 38 B of slack back into the wall-bound bank `$0d` "Effect Commands" section. Three structural notes worth carrying forward: the JP move-grammar machinery in `used_move_text.asm` is kept even though English ignores it (its `GetMoveGrammar` side effect drives COUNTER, and `wMoveGrammar` is a union alias of `wNumSetBits`); static menu boxes give `x2 - x1 - 2` text columns, so `SelectedItemMenu` needed its left edge widened for "TOSS"; and the party move-details pane now puts TYPE and POWER on separate rows because English type names print in full (up to 8 chars) and collided with the old shared-row layout. See the new **"L-system continuation — start_battle / used_move_text / item_effects / start_menu"** subsection for the full writeup + consolidated PLAYTEST checklist. _Next: `party_menu.asm` / `learn.asm` / `pokemart_menu.asm` (the three remaining Phase-3 files on M1d's reachable path), then the unreachable ones (`poker_minigame`, `pokecenter_pc`, `bills_pc`), then Phase 4 dialogue._
