	map_attributes SilentHillLabFront, SILENT_HILL_LAB_FRONT

	object_const_def
	const SILENT_HILL_LAB_FRONT_OAK1
	const SILENT_HILL_LAB_FRONT_OAK2
	const SILENT_HILL_LAB_FRONT_RIVAL1
	const SILENT_HILL_LAB_FRONT_RIVAL2
	const SILENT_HILL_LAB_FRONT_BLUE1
	const SILENT_HILL_LAB_FRONT_BLUE2
	const SILENT_HILL_LAB_FRONT_NANAMI
	const SILENT_HILL_LAB_FRONT_OAKS_AIDE1
	const SILENT_HILL_LAB_FRONT_OAKS_AIDE2
	const SILENT_HILL_LAB_FRONT_POKEDEX1
	const SILENT_HILL_LAB_FRONT_POKEDEX2
	
SilentHillLabFront_MapEvents::
	dw $4000 ; unknown

	def_warp_events
	warp_event  3, 15, SILENT_HILL, 4, 82
	warp_event  4, 15, SILENT_HILL, 5, 83
	warp_event  4,  0, SILENT_HILL_LAB_BACK, 2, 13

	def_bg_events
	bg_event  6,  1, 1
	bg_event  2,  0, 2
	bg_event  0,  7, 3
	bg_event  1,  7, 4
	bg_event  2,  7, 5
	bg_event  5,  7, 6
	bg_event  6,  7, 7
	bg_event  7,  7, 8
	bg_event  0, 11, 9
	bg_event  1, 11, 10
	bg_event  2, 11, 11
	bg_event  5, 11, 12
	bg_event  6, 11, 13
	bg_event  7, 11, 14
	bg_event  4,  0, 15

	def_object_events
	object_event  4,  2, SPRITE_OKIDO, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  4,  0, SPRITE_OKIDO, SPRITEMOVEFN_RANDOM_SPIN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  3,  4, SPRITE_SILVER, SPRITEMOVEFN_TURN_UP, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  4,  0, SPRITE_SILVER, SPRITEMOVEFN_RANDOM_SPIN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  4, 14, SPRITE_BLUE, SPRITEMOVEFN_RANDOM_SPIN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  1,  3, SPRITE_BLUE, SPRITEMOVEFN_TURN_RIGHT, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  1, 13, SPRITE_NANAMI, SPRITEMOVEFN_RANDOM_SPIN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  1,  8, SPRITE_SCIENTIST, SPRITEMOVEFN_RANDOM_WALK_X, 1, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  6, 12, SPRITE_SCIENTIST, SPRITEMOVEFN_TURN_UP, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  0,  1, SPRITE_POKEDEX, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  1,  1, SPRITE_POKEDEX, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0

SilentHillLabFront_Blocks::
INCBIN "maps/SilentHillLabFront.blk"

	map_generic_scriptloader

SilentHillLabFrontScriptPointers::
	def_script_pointers
	script_pointer SilentHillLabFrontScript1, SilentHillLabFrontNPCIDs1, SCENE_SILENT_HILL_LAB_FRONT_DEFAULT
	script_pointer SilentHillLabFrontScript2, SilentHillLabFrontNPCIDs2, SCENE_SILENT_HILL_LAB_FRONT_START_BLUE_CUTSCENE
	script_pointer SilentHillLabFrontScript3, SilentHillLabFrontNPCIDs2, SCENE_SILENT_HILL_LAB_FRONT_BLUE_CUTSCENE
	script_pointer SilentHillLabFrontScript4, SilentHillLabFrontNPCIDs2, SCENE_SILENT_HILL_LAB_FRONT_BLUE_CUTSCENE_2
	script_pointer SilentHillLabFrontConversation1, SilentHillLabFrontNPCIDs2, SCENE_SILENT_HILL_LAB_FRONT_BLUE_CUTSCENE_CONVERSATION
	script_pointer SilentHillLabFrontScript6, SilentHillLabFrontNPCIDs3, SCENE_SILENT_HILL_LAB_FRONT_BLUE_CUTSCENE_END
	script_pointer SilentHillLabFrontScript7, SilentHillLabFrontNPCIDs4, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_ENTER_BACK
	script_pointer SilentHillLabFrontScript8, SilentHillLabFrontNPCIDs5, SCENE_SILENT_HILL_LAB_FRONT_ENTER_BACK
	script_pointer SilentHillLabFrontScript9, SilentHillLabFrontNPCIDs5, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_CUTSCENE
	script_pointer SilentHillLabFrontScript10, SilentHillLabFrontNPCIDs5, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_CUTSCENE_2
	script_pointer SilentHillLabFrontScript11, SilentHillLabFrontNPCIDs5, SCENE_SILENT_HILL_LAB_FRONT_GET_POKEDEX
	script_pointer SilentHillLabFrontScript12, SilentHillLabFrontNPCIDs6, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_WAIT_FOR_BATTLE
	script_pointer SilentHillLabFrontScript13, SilentHillLabFrontNPCIDs6, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_START_BATTLE
	script_pointer SilentHillLabFrontScript14, SilentHillLabFrontNPCIDs6, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_BATTLE_END
	script_pointer SilentHillLabFrontScript15, SilentHillLabFrontNPCIDs7, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_LEFT
	script_pointer SilentHillLabFrontScript16, SilentHillLabFrontNPCIDs7, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_LEFT_END
	script_pointer SilentHillLabFrontScript17, SilentHillLabFrontNPCIDs7, SCENE_SILENT_HILL_LAB_FRONT_GET_POKEBALLS
	script_pointer SilentHillLabFrontScript18, SilentHillLabFrontNPCIDs7, SCENE_SILENT_HILL_LAB_FRONT_GOT_POKEBALLS
	script_pointer SilentHillLabFrontScript19, SilentHillLabFrontNPCIDs9, SCENE_SILENT_HILL_LAB_FRONT_FINISHED

SilentHillLabFrontNPCIDs1:
	npc_id SILENT_HILL_LAB_FRONT_RIVAL1
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX1
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX2
	db -1

SilentHillLabFrontNPCIDs2:
	npc_id SILENT_HILL_LAB_FRONT_OAK1
	npc_id SILENT_HILL_LAB_FRONT_RIVAL1
	npc_id SILENT_HILL_LAB_FRONT_BLUE1
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX1
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX2
	db -1

SilentHillLabFrontNPCIDs3:
	npc_id SILENT_HILL_LAB_FRONT_RIVAL1
	npc_id SILENT_HILL_LAB_FRONT_BLUE1
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX1
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX2
	db -1

SilentHillLabFrontNPCIDs4:
	npc_id SILENT_HILL_LAB_FRONT_BLUE1
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX1
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX2
	db -1

SilentHillLabFrontNPCIDs5:
	npc_id SILENT_HILL_LAB_FRONT_OAK2
	npc_id SILENT_HILL_LAB_FRONT_RIVAL2
	npc_id SILENT_HILL_LAB_FRONT_BLUE2
	npc_id SILENT_HILL_LAB_FRONT_NANAMI
	npc_id SILENT_HILL_LAB_FRONT_OAKS_AIDE1
	npc_id SILENT_HILL_LAB_FRONT_OAKS_AIDE2
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX1
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX2
	db -1

SilentHillLabFrontNPCIDs6:
	npc_id SILENT_HILL_LAB_FRONT_OAK2
	npc_id SILENT_HILL_LAB_FRONT_RIVAL2
	npc_id SILENT_HILL_LAB_FRONT_BLUE2
	npc_id SILENT_HILL_LAB_FRONT_NANAMI
	npc_id SILENT_HILL_LAB_FRONT_OAKS_AIDE1
	npc_id SILENT_HILL_LAB_FRONT_OAKS_AIDE2
	db -1

SilentHillLabFrontNPCIDs7:
	npc_id SILENT_HILL_LAB_FRONT_OAK1
	npc_id SILENT_HILL_LAB_FRONT_BLUE2
	npc_id SILENT_HILL_LAB_FRONT_NANAMI
	npc_id SILENT_HILL_LAB_FRONT_OAKS_AIDE1
	npc_id SILENT_HILL_LAB_FRONT_OAKS_AIDE2
	db -1
	
SilentHillLabFrontNPCIDs8: ; (unused?)
	npc_id SILENT_HILL_LAB_FRONT_OAK1
	npc_id SILENT_HILL_LAB_FRONT_RIVAL2
	npc_id SILENT_HILL_LAB_FRONT_BLUE2
	npc_id SILENT_HILL_LAB_FRONT_NANAMI
	npc_id SILENT_HILL_LAB_FRONT_OAKS_AIDE1
	npc_id SILENT_HILL_LAB_FRONT_OAKS_AIDE2
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX1
	npc_id SILENT_HILL_LAB_FRONT_POKEDEX2
	db -1

SilentHillLabFrontNPCIDs9:
	npc_id SILENT_HILL_LAB_FRONT_OAK1
	npc_id SILENT_HILL_LAB_FRONT_OAKS_AIDE1
	npc_id SILENT_HILL_LAB_FRONT_OAKS_AIDE2
	db -1

SilentHillLabFront_TextPointers::
	dw SilentHillLabFrontText4
	dw SilentHillLabFrontText7
	dw SilentHillLabFrontText10
	dw SilentHillLabFrontText11
	dw SilentHillLabFrontTextString20
	dw SilentHillLabFrontText12
	dw SilentHillLabFrontText13
	dw SilentHillLabFrontText14
	dw SilentHillLabFrontText15
	dw SilentHillLabFrontText16
	dw SilentHillLabFrontText16

SilentHillLabFrontScript1:
	call SilentHillLabFrontMoveDown
	ret z
	ld hl, SilentHillLabFrontNPCIDs1
	ld de, SilentHillLabFrontTextPointers2
	call CallMapTextSubroutine
	ret

SilentHillLabFrontMoveDown:
	ld a, [wXCoord]
	cp 4
	ret nz
	ld a, [wYCoord]
	cp 1
	ret nz
	ldh a, [hJoyState]
	bit 6, a
	jp z, xor_a_dec_a
	call SilentHillLabFrontText3
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, PLAYER_OBJECT
	call FreezeAllOtherObjects
	ld a, PLAYER_OBJECT
	ld hl, SilentHillLabFrontMovement1
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	call xor_a
	ret

SilentHillLabFrontMovement1:
	slow_step LEFT
	step_end

SilentHillLabFrontScript2:
	ld a, SCENE_SILENT_HILL_LAB_FRONT_BLUE_CUTSCENE
	ld [wMapScriptNumber], a
	ret

SilentHillLabFrontScript3:
	ld a, 6
	call FreezeAllOtherObjects
	ld a, PLAYER_OBJECT
	call UnfreezeObject
	ld b, SILENT_HILL_LAB_FRONT_BLUE1
	ld c, PLAYER_OBJECT
	call StartFollow
	ld hl, SilentHillLabFrontMovement2
	ld a, SILENT_HILL_LAB_FRONT_BLUE1
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_LAB_FRONT_BLUE_CUTSCENE_2
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

SilentHillLabFrontMovement2:
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	slow_step UP
	slow_step RIGHT
	turn_head UP
	step_end

SilentHillLabFrontScript4:
	call FreezeAllObjects
	ld a, SCENE_SILENT_HILL_LAB_FRONT_BLUE_CUTSCENE_CONVERSATION
	ld [wMapScriptNumber], a
	ret

SilentHillLabFrontConversation1:
	ld a, SILENT_HILL_LAB_FRONT_RIVAL1
	ld d, RIGHT
	call SetObjectFacing
	ld hl, SilentHillLabFrontTextString20
	call OpenTextbox
	ld hl, SilentHillLabFrontTextString4
	call OpenTextbox
	ld a, SILENT_HILL_LAB_FRONT_RIVAL1
	ld d, UP
	call SetObjectFacing
	ld hl, SilentHillLabFrontTextString28
	call OpenTextbox
	ld hl, SilentHillLabFrontTextString5
	call OpenTextbox
	ld a, SILENT_HILL_LAB_FRONT_RIVAL1
	ld d, RIGHT
	call SetObjectFacing
	ld hl, SilentHillLabFrontTextString29
	call OpenTextbox
	ld hl, SilentHillLabFrontTextString7
	call OpenTextbox
	call SilentHillLabFrontScript5
	ret

SilentHillLabFrontScript5:
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, SILENT_HILL_LAB_FRONT_OAK1
	call FreezeAllOtherObjects
	ld a, SILENT_HILL_LAB_FRONT_OAK1
	ld hl, SilentHillLabFrontMovement3
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_LAB_FRONT_BLUE_CUTSCENE_END
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

SilentHillLabFrontMovement3:
	step UP
	slow_step UP
	remove_object

SilentHillLabFrontScript6:
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, SILENT_HILL_LAB_FRONT_RIVAL1
	call FreezeAllOtherObjects
	ld a, SILENT_HILL_LAB_FRONT_RIVAL1
	ld hl, SilentHillLabFrontMovement4
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_ENTER_BACK
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

SilentHillLabFrontMovement4:
	big_step UP
	big_step UP
	big_step RIGHT
	big_step UP
	big_step UP
	remove_object

SilentHillLabFrontScript7:
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, PLAYER_OBJECT
	call FreezeAllOtherObjects
	ld a, PLAYER_OBJECT
	ld hl, SilentHillLabFrontMovement5
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_LAB_FRONT_ENTER_BACK
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

SilentHillLabFrontMovement5:
	step UP
	step UP
	step UP
	slow_step UP
	step_end

SilentHillLabFrontScript8:
	ld a, SILENT_HILL_LAB_FRONT_OAK2
	call SetObjectLowPriority
	ld a, SILENT_HILL_LAB_FRONT_RIVAL2
	call SetObjectLowPriority
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, PLAYER_OBJECT
	call FreezeAllOtherObjects
	ld a, PLAYER_OBJECT
	ld hl, SilentHillLabFrontMovement6
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_CUTSCENE
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

SilentHillLabFrontMovement6:
	step DOWN
	step DOWN
	step DOWN
	step LEFT
	slow_step LEFT
	step_end

SilentHillLabFrontScript9:
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, SILENT_HILL_LAB_FRONT_RIVAL2
	call FreezeAllOtherObjects
	ld a, SILENT_HILL_LAB_FRONT_RIVAL2
	call ResetObjectLowPriority
	ld a, SILENT_HILL_LAB_FRONT_RIVAL2
	ld hl, SilentHillLabFrontMovement7
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_CUTSCENE_2
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

SilentHillLabFrontMovement7:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step LEFT
	slow_step LEFT
	step_end

SilentHillLabFrontScript10:
	ld a, SILENT_HILL_LAB_FRONT_RIVAL2
	ld d, RIGHT
	call SetObjectFacing
	ld hl, SilentHillLabFrontTextString21
	call OpenTextbox
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, PLAYER_OBJECT
	ld d, RIGHT
	call SetObjectFacing
	ld a, SILENT_HILL_LAB_FRONT_RIVAL2
	ld d, RIGHT
	call SetObjectFacing
	ld a, SILENT_HILL_LAB_FRONT_OAK2
	call FreezeAllOtherObjects
	ld a, SILENT_HILL_LAB_FRONT_OAK2
	call ResetObjectLowPriority
	ld a, SILENT_HILL_LAB_FRONT_OAK2
	ld hl, SilentHillLabFrontMovement8
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_LAB_FRONT_GET_POKEDEX
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

SilentHillLabFrontMovement8:
	step DOWN
	slow_step DOWN
	step_end

SilentHillLabFrontScript11:
	ld hl, SilentHillLabFrontTextString8
	call OpenTextbox
	ld hl, SilentHillLabFrontTextString9
	call OpenTextbox
	ld a, SILENT_HILL_LAB_FRONT_POKEDEX1
	call ApplyDeletionToMapObject
	ld a, SILENT_HILL_LAB_FRONT_POKEDEX2
	call ApplyDeletionToMapObject
	ld hl, SilentHillLabFrontTextString10
	call OpenTextbox
	ld hl, SilentHillLabFrontTextString15
	call OpenTextbox
	SetEvent SILENT_HILL_LAB_FRONT_GOT_POKEDEX
	call UnfreezeEverything
	ld a, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_WAIT_FOR_BATTLE
	ld [wMapScriptNumber], a
	call InitObjectMasks
	ret

SilentHillLabFrontScript12:
	call SilentHillLabFrontMoveDown
	ret z
	call SilentHillLabFrontRivalMovePokemon
	ret z
	ld hl, SilentHillLabFrontNPCIDs6
	ld de, SilentHillLabFrontTextPointers2
	call CallMapTextSubroutine
	ret

SilentHillLabFrontRivalMovePokemon:
	ld a, [wYCoord]
	cp 8
	ret nz
	ld hl, SilentHillLabFrontMovement9
	ld a, [wXCoord]
	cp 3
	jr z, .jump
	cp 4
	ret nz
	ld hl, SilentHillLabFrontMovement10
.jump
	push hl
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, SILENT_HILL_LAB_FRONT_RIVAL2
	call FreezeAllOtherObjects
	pop hl
	ld a, SILENT_HILL_LAB_FRONT_RIVAL2
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_START_BATTLE
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	call xor_a
	ret

SilentHillLabFrontMovement9:
	step DOWN
	step RIGHT
	step RIGHT
	step DOWN
	step DOWN
	slow_step DOWN
	step_end

SilentHillLabFrontMovement10:
	step DOWN
	step RIGHT
	step DOWN
	step DOWN
	slow_step DOWN
	step_end

SilentHillLabFrontScript13:
	ld hl, SilentHillLabFrontTextString17
	call OpenTextbox
	call GetLabPokemon
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, MAPSTATUS_START_TRAINER_BATTLE
	ld [wMapStatus], a
	ld a, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_BATTLE_END
	ld [wMapScriptNumber], a
	call InitObjectMasks
	ret

GetLabPokemon:
	ld hl, LabPokemon
	ld a, [wRivalStarter]
	ld b, a
.loop
	ld a, [hli]
	cp b
	jr nz, .jump
	ld a, [hl]
	ld [wOtherTrainerID], a
	ld a, 9
	ld [wOtherTrainerClass], a
	ret
.jump
	inc hl
	jr .loop

LabPokemon:
	db DEX_KURUSU
	db 1
	db DEX_HAPPA
	db 2
	db DEX_HONOGUMA
	db 3

SilentHillLabFrontScript14:
	ld hl, SilentHillLabFrontTextString19
	ld a, [wBattleResult]
	and a
	jr nz, .skip
	ld hl, SilentHillLabFrontTextString18
.skip
	call OpenTextbox
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, SILENT_HILL_LAB_FRONT_RIVAL2
	call FreezeAllOtherObjects
	ld a, SILENT_HILL_LAB_FRONT_RIVAL2
	ld hl, SilentHillLabFrontMovement11
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_LEFT
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

SilentHillLabFrontMovement11:
	slow_step DOWN
	step DOWN
	step DOWN
	step DOWN
	remove_object

SilentHillLabFrontScript15:
	call UnfreezeEverything
	ld a, SCENE_SILENT_HILL_LAB_FRONT_RIVAL_LEFT_END
	ld [wMapScriptNumber], a
	call InitObjectMasks
	ret

SilentHillLabFrontScript16:
	call SilentHillLabFrontMoveDown
	ret z
	call SilentHillLabFrontMoveRivalLeave
	ret z
	ld hl, SilentHillLabFrontNPCIDs7
	ld de, SilentHillLabFrontTextPointers2
	call CallMapTextSubroutine
	ret

SilentHillLabFrontMoveRivalLeave:
	ld a, [wYCoord]
	cp $0B
	ret nz
	ld hl, Movememt12+1
	ld a, [wXCoord]
	cp 3
	jr z, .jump
	cp 4
	ret nz
	ld hl, Movememt12
.jump
	push hl
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, SILENT_HILL_LAB_FRONT_NANAMI
	call FreezeAllOtherObjects
	pop hl
	ld a, SILENT_HILL_LAB_FRONT_NANAMI
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_LAB_FRONT_GET_POKEBALLS
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	call xor_a
	ret

Movememt12:
	slow_step RIGHT
	slow_step RIGHT
	slow_step RIGHT
	slow_step UP
	step_end

SilentHillLabFrontScript17:
	ld hl, SilentHillLabFrontTextString23
	call OpenTextbox
	SetEvent SILENT_HILL_LAB_FRONT_RIVAL_BATTLED
; feature/completion: the demo only handed over the six POKé BALLS, so NANAMI's
; speech promised a PACK with a BALL HOLDER, a TM HOLDER and a bonus TM that
; never arrived. All four now exist as real items; ReceiveItem routes each one
; to its own pocket by its ItemAttributes entry.
	ld a, ITEM_BAG
	call SilentHillLabFrontGiveOne
	ld a, ITEM_BALL_HOLDER
	call SilentHillLabFrontGiveOne
	ld a, ITEM_TM_HOLDER
	call SilentHillLabFrontGiveOne
	ld a, ITEM_TM24 ; FALSE SWIPE -- all three starters can learn it
	call SilentHillLabFrontGiveOne
	ld hl, wNumBagItems
	ld a, ITEM_POKE_BALL
	ld [wCurItem], a
	ld a, 6
	ld [wItemQuantity], a
	call ReceiveItem
	call UnfreezeEverything
	ld a, SCENE_SILENT_HILL_LAB_FRONT_GOT_POKEBALLS
	ld [wMapScriptNumber], a
	ret

SilentHillLabFrontGiveOne:
; Gives one of item a, letting ReceiveItem pick the pocket.
	ld [wCurItem], a
	ld a, 1
	ld [wItemQuantity], a
	ld hl, wNumBagItems
	call ReceiveItem
	ret

SilentHillLabFrontScript18:
	call SilentHillLabFrontMoveDown
	ret z
	ld hl, SilentHillLabFrontNPCIDs7
	ld de, SilentHillLabFrontTextPointers2
	call CallMapTextSubroutine
	ret

SilentHillLabFrontScript19:
	call SilentHillLabFrontMoveDown
	ret z
	ld hl, SilentHillLabFrontNPCIDs9
	ld de, SilentHillLabFrontTextPointers2
	call CallMapTextSubroutine
	ret

SilentHillLabFrontTextPointers2:
	dw SilentHillLabFrontText1
	dw SilentHillLabFrontText2
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw PokemonBooksScript
	dw SilentHillLabFrontText3

SilentHillLabFrontText1:
	ld hl, SilentHillLabFrontTextString1
	call OpenTextbox
	ret

SilentHillLabFrontTextString1:
	text "Looking at the"
	line "<PC>, there was"
	cont "mail!"

	para "<⋯⋯> <⋯⋯> <⋯⋯>"
	line "PROF.OAK! The"
	cont "world is in an"
	cont "uproar over your"
	cont "going missing!"

	para "By the way, that"
	line "certain #"
	cont "you asked me to"
	cont "find: far from"
	cont "finding it, I"
	cont "can't even grasp"
	cont "a single clue."

	para "Maybe that thing"
	line "really is a"
	cont "fictitious #"
	cont "after all<⋯⋯>"
	cont "<⋯⋯> From your"
	cont "assistant"
	done

SilentHillLabFrontText2:
	ld hl, wSilentHillLabFrontFlags
	bit 0, [hl]
	set 0, [hl]
	jr z, .jump
	res 0, [hl]
	ld hl, SilentHillLabFrontTextString2A
	jr .skip
.jump
	ld hl, SilentHillLabFrontTextString2B
.skip
	call OpenTextbox
	ret

SilentHillLabFrontTextString2A:
	text "Push the START"
	line "button! Press it"
	cont "and a menu opens"
	cont "up, ya know."
	done

SilentHillLabFrontTextString2B:
	text "To save, write a"
	line "# REPORT."
	cont "Best to do it"
	cont "often, ya know."
	done

SilentHillLabFrontText3:
	ld hl, SilentHillLabFrontTextString3
	call OpenTextbox
	ret

SilentHillLabFrontTextString3:
	text "It's locked."
	done

SilentHillLabFrontText4:
	ld a, [wMapScriptNumber]
	cp SCENE_SILENT_HILL_LAB_FRONT_RIVAL_LEFT
	jp nc, SilentHillLabFrontText7
	ld hl, SilentHillLabFrontTextString4
	call OpenTextbox
	ret

SilentHillLabFrontTextString4:
	text "OAK: Good work!"
	done

SilentHillLabFrontTextString5:
	text "OAK: That's right!"
	line "I'm OAK! Sorry"
	cont "for being an old"
	cont "geezer!"

	para "You two, I'm the"
	line "one who called"
	cont "you here!"

	para "Won't you hear me"
	line "out for a bit?@"

	start_asm
	call YesNoBox
	jr c, .jump
.loop
	ld hl, SilentHillLabFrontTextString6A
	call PrintText
	call TextAsmEnd
	ret

.jump
	ld hl, SilentHillLabFrontTextString6B
	call PrintText
	call YesNoBox
	jr c, .jump
	jr .loop

SilentHillLabFrontTextString6A:
	text "OAK: One year ago,"
	line "in KANTO I handed"
	cont "boys like you a"
	cont "POKéDEX and some"
	cont "#, for the"
	cont "sake of research."

	para "And they did a"
	line "truly fine job!"

	para "They succeeded in"
	line "finding 150 kinds"
	cont "of #!"
	cont "But <⋯⋯> <⋯⋯> <⋯⋯>"
	cont "and yet <⋯⋯> <⋯⋯>"

	para "The world is vast."
	line "Since then, new"
	cont "# have been"
	cont "turning up one"
	cont "after another all"
	cont "across the land!"

	para "So I moved my"
	line "research base from"
	cont "KANTO to here,"
	cont "SILENT HILL."

	para "Change the place,"
	line "and you can meet"
	cont "new # too."
	cont "<⋯⋯> <⋯⋯> <⋯⋯> <⋯⋯>"

	para "I'll keep pushing"
	line "my research, but"
	cont "as you can see I'm"
	cont "a worn-out old"
	cont "man."

	para "I have grandkids"
	line "and assistants,"
	cont "but even so there"
	cont "aren't enough"
	cont "hands!"

	para "<PLAYER>! <RIVAL>!"
	line "Won't you lend"
	cont "your strength to"
	cont "# research?"
	done

SilentHillLabFrontTextString6B:
	text "OAK: I see<⋯⋯>"
	line "So I had no eye"
	cont "for people after"
	cont "all<⋯⋯>"

	para "No! My eye for"
	line "people can't be"
	cont "wrong!"

	para "Right?"
	cont "You'll hear me"
	cont "out, won't you?"
	done

SilentHillLabFrontTextString7:
	text "OAK: You two!"
	line "Come with me a"
	cont "moment!"
	done

SilentHillLabFrontText7:
	ld a, [wMapScriptNumber]
	cp SCENE_SILENT_HILL_LAB_FRONT_FINISHED
	jr z, .jump
	ld hl, SilentHillLabFrontTextString11A
	call OpenTextbox
	ret

.jump
	ld hl, SilentHillLabFrontTextString11B
	call OpenTextbox
	ret

SilentHillLabFrontTextString8:
	text "OAK: <PLAYER>!"
	line "<RIVAL>! I entrust"
	cont "this POKéDEX to"
	cont "you both!"
	done

SilentHillLabFrontTextString9:
	text "<PLAYER> received"
	line "the POKéDEX from"
	cont "PROF.OAK!"
	done

SilentHillLabFrontTextString10:
	text "OAK: To make a"
	line "complete POKéDEX"
	cont "recording every"
	cont "# in this"
	cont "world, that was"
	cont "my dream!"

	para "But new species"
	line "keep turning up"
	cont "one after another!"

	para "The time left to"
	line "me is short!"

	para "So I want you two"
	line "to fulfil my dream"
	cont "in my place!"

	para "Now, you two, set"
	line "off at once!"

	para "This is a great"
	line "task that will go"
	cont "down in #"
	cont "history!"
	done

SilentHillLabFrontTextString11A:
	text "OAK: # all"
	line "over the world are"
	cont "waiting for"
	cont "<PLAYER>!"
	done

SilentHillLabFrontTextString11B:
	text "OAK: Oh! <PLAYER>,"
	line "how's it going?"

	para "The # I gave"
	line "you<⋯⋯>?"

	para "Oho! It seems"
	cont "quite attached to"
	cont "you now."

	para "You may have a"
	line "talent for being a"
	cont "# TRAINER."

	para "Keep dropping by"
	line "to see me now and"
	cont "then. I'm curious"
	cont "about the pages of"
	cont "your POKéDEX."
	done

SilentHillLabFrontText8: ; unreferenced
	ld hl, SilentHillLabFrontTextString12
	call OpenTextbox
	ret

SilentHillLabFrontTextString12:
	text "OAK: Welcome!"
	line "How's your POKéDEX"
	cont "coming along?"

	para "Let's see<⋯⋯>"
	cont "shall I take a"
	cont "little look?"
	done

SilentHillLabFrontText9: ; unreferenced
	ld hl, SilentHillLabFrontTextString13
	call OpenTextbox
	ret

SilentHillLabFrontTextString13:
	text "OAK: <⋯⋯> Ahem!"
	line "Well done,"
	cont "<PLAYER>!"

	para "Come with me a"
	line "moment!"

	para "<RIVAL>, sorry,"
	line "but wait there!"

	para "<RIVAL>: Aww!"
	line "What a cheapskate!"

	para "OAK: <RIVAL>,"
	line "weren't you just"
	cont "after a legendary"
	cont "#?"
	cont "<RIVAL>: Gulp!"
	done

SilentHillLabFrontText10: ; unreferenced
	ld hl, SilentHillLabFrontTextString14
	call OpenTextbox
	ret

SilentHillLabFrontTextString14:
	text "<RIVAL>: What, if"
	line "it isn't <PLAYER>!"
	cont "I came because"
	cont "this place seemed"
	cont "suspicious too,"
	cont "but it looks like"
	cont "nobody's here<⋯⋯>"
	done

SilentHillLabFrontText11:
	ld hl, SilentHillLabFrontTextString16
	call OpenTextbox
	ret

SilentHillLabFrontTextString15:
	text "<RIVAL>: Alright!"
	line "Gramps! Leave it"
	cont "to me!"
	done

SilentHillLabFrontTextString16:
	text "<RIVAL>: The one I"
	line "picked looks"
	cont "stronger! You"
	cont "wanted this one,"
	cont "didn't you?"
	done

SilentHillLabFrontTextString17:
	text "<RIVAL>: <PLAYER>!"
	line "Since we got"
	cont "# from the"
	cont "old man<⋯⋯> let's"
	cont "have them battle"
	cont "a bit!"
	done

SilentHillLabFrontTextString18:
	text "<RIVAL>: Dammit!"
	line "Next time I"
	cont "definitely won't"
	cont "lose!"
	done

SilentHillLabFrontTextString19:
	text "<RIVAL>: Alright!"
	line "Let's battle other"
	cont "# and get"
	cont "stronger and"
	cont "stronger!"

	para "Well then, bye!"
	done

SilentHillLabFrontTextString20:
	text "Gramps! I brought"
	line "them along!"
	done

SilentHillLabFrontTextString21:
	text "I once aimed to"
	line "reach the very top"
	cont "as a #"
	cont "TRAINER. Back then"
	cont "I was full of"
	cont "myself, until"
	cont "someone knocked me"
	cont "down a peg."

	para "You remind me a"
	line "little of him."

	para "Thanks to him, I"
	line "turned over a new"
	cont "leaf and began"
	cont "helping with the"
	cont "old man's work."
	cont "<⋯⋯> <⋯⋯> <⋯⋯>"

	para "Now! This is the"
	line "POKéDEX!"

	para "When you find a"
	line "#, its data"
	cont "is written in"
	cont "automatically and"
	cont "the pages keep"
	cont "growing. A very"
	cont "high-tech POKéDEX!"
	done

SilentHillLabFrontText12:
	ld hl, SilentHillLabFrontTextString22
	call OpenTextbox
	ret

SilentHillLabFrontTextString22:
	text "I did it long ago"
	line "too, and it's"
	cont "quite a challenge"
	cont "<⋯⋯> Good luck!"
	done

SilentHillLabFrontText13:
	ld hl, SilentHillLabFrontTextString24
	call OpenTextbox
	ret

SilentHillLabFrontTextString23:
	text "NANAMI: That young"
	line "boy who brought"
	cont "you here earlier"
	cont "<⋯⋯> he's my"
	cont "little brother."
	cont "<⋯⋯>Which means,"
	cont "yes!"

	para "I'm OAK's"
	line "granddaughter too!"

	para "Grandpa is a fine"
	line "# researcher"
	cont "and I'm so happy I"
	cont "can help out!"

	para "Oh, if he found"
	line "out I said that,"
	cont "Grandpa would get"
	cont "carried away, so"
	cont "keep it a secret!"

	para "<⋯⋯>Grandpa seems"
	line "to have completely"
	cont "forgotten, so I'll"
	cont "give you this"
	cont "instead!"

	para "It's the latest"
	line "model # PACK"

	para "<PLAYER> received"
	line "the # PACK!"

	para "NANAMI: This PACK"
	line "has a BALL HOLDER"
	cont "that stores POKé"
	cont "BALLS together,"
	cont "and a TM HOLDER"
	cont "that stores <TM>s"
	cont "together."

	para "I'll throw in 6"
	line "POKé BALLS and one"
	cont "<TM> as a bonus."
	cont "An empty holder is"
	cont "lonely, after all!"

	para "Say, <PLAYER>,"
	line "your mom will"
	cont "worry, so before"
	cont "you leave town, go"
	cont "show her your face"

	para "<⋯⋯>I'm praying"
	line "for your success."
	done

SilentHillLabFrontTextString24:
	text "<⋯⋯>I'm praying"
	line "for your success."
	done

SilentHillLabFrontText14:
	ld hl, SilentHillLabFrontTextString25
	call OpenTextbox
	ret

SilentHillLabFrontTextString25:
	text "I am the"
	line "PROFESSOR's"
	cont "assistant."

	para "Of course, I hold"
	line "the PROFESSOR in"
	cont "deep respect."

	para "I have a feeling"
	line "you and I will"
	cont "meet again"
	cont "somewhere."
	done

SilentHillLabFrontText15:
	ld hl, SilentHillLabFrontTextString26
	call OpenTextbox
	ret

SilentHillLabFrontTextString26:
	text "I am the"
	line "PROFESSOR's"
	cont "assistant."

	para "Of course, I hold"
	line "the PROFESSOR in"
	cont "deep respect."

	para "I have a feeling"
	line "you and I will"
	cont "meet again"
	cont "somewhere."
	done

SilentHillLabFrontText16:
	ld hl, SilentHillLabFrontTextString27
	call OpenTextbox
	ret

SilentHillLabFrontTextString27:
	text "What's this?"
	line "An electronic"
	cont "organiser, maybe?"
	done

SilentHillLabFrontText17:
	ld hl, SilentHillLabFrontTextString28
	call OpenTextbox
	ret

SilentHillLabFrontTextString28:
	text "<RIVAL>: So that"
	line "OAK who sent the"
	cont "mail is this old"
	cont "geezer<⋯⋯>"

	para "Ah, sorry. This"
	line "old man?"
	cont "It's my first time"
	cont "seeing the real"
	cont "thing!"
	done

SilentHillLabFrontTextString29:
	text "<RIVAL>: <PLAYER>!"
	line "Somehow this is"
	cont "starting to get"
	cont "fun!"
	done

SilentHillLabFrontText18:
	ld hl, SilentHillLabFrontTextString30
	call OpenTextbox
	ret

SilentHillLabFrontTextString30:
	text "I am the"
	line "PROFESSOR's"
	cont "assistant."

	para "I have a feeling"
	line "you and I will"
	cont "meet again"
	cont "somewhere."
	done

SilentHillLabFrontText19:
	ld hl, SilentHillLabFrontTextString31
	call OpenTextbox
	ret

SilentHillLabFrontTextString31:
	text "I am the"
	line "PROFESSOR's"
	cont "assistant."

	para "I have a feeling"
	line "you and I will"
	cont "meet again"
	cont "somewhere."
	done
