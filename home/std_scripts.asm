Unreferenced_StubbedSTDScript::
	ret

Unreferenced_PokemonNewsScript::
	farcall _Unreferenced_PokemonNewsScript
	ret

PokemonBooksScript::
	farcall _PokemonBooksScript
	ret

FridgeScript::
	farcall _FridgeScript
	ret

StoveScript::
	farcall _StoveScript
	ret

SinkScript::
	farcall _SinkScript
	ret

TVScript::
	farcall _TVScript
	ret

PokecenterSignScript::
	farcall _PokecenterSignScript
	ret

WindowScript::
	farcall _WindowScript
	ret

InitTrainerBattle::
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, MAPSTATUS_START_TRAINER_BATTLE
	ld [wMapStatus], a
	ret

TestWildBattleStart::
	ldh a, [hJoyState]
	and PAD_CTRL_PAD
	ret z ; if no directions are down, don't try and trigger a wild encounter
	call CheckBPressedDebug
	jp nz, xor_a ; if b button is down, clear acc
	callfar TryWildBattle
	ld a, [wBattleMode]
	and a
	ret z ; if no battle, return
	ld a, MAPSTATUS_START_WILD_BATTLE
	call SetMapStatus
	call xor_a_dec_a
	ret

OverworldLoop_StartBattle::
	predef StartBattle
	ld a, MAPSETUP_RELOADMAP
	ldh [hMapEntryMethod], a
	ld hl, wGameModeFlags
	set 5, [hl]
	ld hl, wJoypadFlags
	set 4, [hl]
	set 6, [hl]
	ld a, MAPSTATUS_EXIT_BATTLE
	call SetMapStatus
	ret

OverworldLoop_05::
	ret

OverworldLoop_ExitBattle::
	ld a, [wBattleResult]
	cp LOSE
	jr z, .Lost
.ReturnToMain:
	ld a, MAPSTATUS_RETURN_TO_MAIN
	call SetMapStatus
	ret

.Lost:
; feature/completion: replaced the demo's game-over reset. A scripted "can lose"
; battle (the first rival fight) continues the story in-place; any other loss
; (wild/trainer) whites out the player back to their last respawn point.
	ld a, [wBattleLossContinues]
	and a
	jr nz, .ReturnToMain

; White out: heal the party and teleport to the last respawn point. Until a
; Pokémon Center sets one, fall back to the hometown (Silent Hill).
	predef HealParty
	ld a, [wDefaultSpawnPoint]
	and a
	jr nz, .haveSpawn
	ld a, SPAWN_POINT_SILENT
	ld [wDefaultSpawnPoint], a
.haveSpawn:
	ld a, MAPSETUP_TELEPORT
	ldh [hMapEntryMethod], a
	jr .ReturnToMain
