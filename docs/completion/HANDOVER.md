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
