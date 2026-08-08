	ret

SilentHill_ScriptLoader::
	ld hl, SilentHillScriptPointers
	call RunMapScript
	call WriteBackMapScriptNumber
	ret

SilentHillNPCIDs1:
	npc_id SILENT_HILL_RIVAL
	npc_id SILENT_HILL_TEACHER
	npc_id SILENT_HILL_SUPER_NERD
	db -1

SilentHillNPCIDs2:
	npc_id SILENT_HILL_TEACHER
	npc_id SILENT_HILL_SUPER_NERD
	db -1

SilentHillNPCIDs3:
	npc_id SILENT_HILL_BLUE
	npc_id SILENT_HILL_TEACHER
	npc_id SILENT_HILL_SUPER_NERD
	db -1

SilentHillScriptPointers::
	def_script_pointers
	script_pointer SilentHillScript1, SilentHillNPCIDs1, SCENE_SILENT_HILL_DEFAULT
	script_pointer SilentHillScript2, SilentHillNPCIDs1, SCENE_SILENT_HILL_RIVAL_CUTSCENE
	script_pointer SilentHillScript3, SilentHillNPCIDs1, SCENE_SILENT_HILL_RIVAL_CUTSCENE_2
	script_pointer SilentHillScript4, SilentHillNPCIDs2, SCENE_SILENT_HILL_RIVAL_CUTSCENE_END
	script_pointer SilentHillScript5, SilentHillNPCIDs3, SCENE_SILENT_HILL_BLUE_CUTSCENE
	script_pointer SilentHillScript6, SilentHillNPCIDs2, SCENE_SILENT_HILL_FOLLOW_BLUE
	script_pointer SilentHillScript7, SilentHillNPCIDs2, SCENE_SILENT_HILL_GOT_STARTER

SilentHillScript1:
	ld a, [wYCoord]
	cp 5
	ret nz
	ld a, [wXCoord]
	cp 5
	ret nz
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, SILENT_HILL_RIVAL
	call FreezeAllOtherObjects
	ld a, SILENT_HILL_RIVAL
	ld hl, SilentHillMovement1
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, SCENE_SILENT_HILL_RIVAL_CUTSCENE
	ld [wMapScriptNumber], a
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

SilentHillMovement1:
	big_step UP
	big_step UP
	big_step UP
	step UP
	slow_step UP
	turn_head LEFT
	step_end

SilentHillScript2:
	ld a, 0
	ld d, RIGHT
	call SetObjectFacing
	ld hl, SilentHillTextRival1
	call OpenTextbox
	ld hl, SilentHillTextRival2
	call OpenTextbox
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, SILENT_HILL_RIVAL
	ld hl, SilentHillMovement2
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ld a, SCENE_SILENT_HILL_RIVAL_CUTSCENE_2
	ld [wMapScriptNumber], a
	ret

SilentHillMovement2:
	turn_head DOWN
	slow_step DOWN
	step DOWN
	big_step DOWN
	big_step DOWN
	big_step DOWN
	remove_object

SilentHillScript3:
	call UnfreezeAllObjects
	ld a, SCENE_SILENT_HILL_RIVAL_CUTSCENE_END
	ld [wMapScriptNumber], a
	call InitObjectMasks
	ret

SilentHillScript4:
	ld a, [wXCoord]
	cp 0
	jr nz, .bigjump
	ld a, [wYCoord]
	cp 8
	jr z, .jump
	cp 9
	jr nz, .bigjump
.jump
	call .TalkedToBlue
	ld hl, SilentHillTextNorthExit
	call OpenTextbox
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, SILENT_HILL_BLUE
	call CopyMapObjectToReservedObjectStruct
	ld a, SILENT_HILL_BLUE
	call FreezeAllOtherObjects
	ld a, [wYCoord]
	cp 9
	jr z, .jump2
	ld hl, SilentHillMovement3
	jr .skip
.jump2
	ld hl, SilentHillMovement4
.skip
	ld a, SILENT_HILL_BLUE
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ld a, SCENE_SILENT_HILL_BLUE_CUTSCENE
	ld [wMapScriptNumber], a
	ret

.bigjump
	ld hl, SilentHillNPCIDs2
	ld de, SilentHillSignPointers
	call CallMapTextSubroutine
	ret

.TalkedToBlue:
	SetEvent SILENT_HILL_TALKED_TO_BLUE
	ld a, SCENE_SILENT_HILL_LAB_FRONT_START_BLUE_CUTSCENE
	ld hl, wSilentHillLabFrontSceneID
	ld [hl], a
	ret

SilentHillMovement3:
	step LEFT
	step LEFT
	step LEFT
	step UP
	step LEFT
	slow_step LEFT
	turn_head LEFT
	step_end

SilentHillMovement4:
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	slow_step LEFT
	turn_head LEFT
	step_end

SilentHillScript5:
	ld a, 0
	ld d, RIGHT
	call SetObjectFacing
	ld hl, SilentHillTextPokemonInGrassString
	call OpenTextbox
	ld hl, wJoypadFlags
	set 4, [hl]
	ld a, SILENT_HILL_BLUE
	call FreezeAllOtherObjects
	ld a, 0
	call UnfreezeObject
	ld b, SILENT_HILL_BLUE
	ld c, 0
	call StartFollow
	ld a, [wYCoord]
	cp 9
	jr z, .jump
	ld hl, SilentHillMovement5
	jr .skip
.jump
	ld hl, SilentHillMovement6
.skip
	ld a, SILENT_HILL_BLUE
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ld a, SCENE_SILENT_HILL_FOLLOW_BLUE
	ld [wMapScriptNumber], a
	ret

SilentHillMovement5:
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	slow_step UP
	remove_object

SilentHillMovement6:
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step DOWN
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	slow_step UP
	remove_object

SilentHillScript6:
	ld hl, SilentHillNPCIDs2
	ld de, SilentHillSignPointers
	call CallMapTextSubroutine
	CheckEvent SILENT_HILL_LAB_BACK_CHOSE_STARTER
	ret z
	ld a, SCENE_SILENT_HILL_LAB_FRONT_FINISHED
	ld [wSilentHillLabFrontSceneID], a
	ld a, SCENE_SILENT_HILL_GOT_STARTER
	ld [wMapScriptNumber], a
	ret

SilentHillScript7:
; The demo sealed the lab once you had your starter (call CheckLabDoor / ret z
; below). The lab front has an authored post-story scene of its own
; (SCENE_SILENT_HILL_LAB_FRONT_FINISHED spawns Oak and his two aides, and the
; PC is readable), so the door stays open here; the back room with the starter
; table is still locked by SilentHillLabFrontMoveDown.
	ld hl, SilentHillNPCIDs2
	ld de, SilentHillSignPointers
	call CallMapTextSubroutine
	ret

CheckLabDoor: ; unreferenced (see SilentHillScript7)
	ld a, [wYCoord]
	cp $C
	ret nz
	ld a, [wXCoord]
	cp $E
	jr z, .jump
	ld a, [wXCoord]
	cp $F
	ret nz
.jump
	ldh a, [hJoyState]
	bit 6, a
	ret z
	ld a, 0
	ld d, UP
	call SetObjectFacing
	ld hl, wJoypadFlags
	set 6, [hl]
	ld hl, SilentHillTextString1
	call OpenTextbox
	call LabClosed
	call xor_a
	ret

LabClosed: ; unreferenced (see SilentHillScript7)
	ld a, 0
	ld hl, SilentHillMovement7
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

SilentHillTextString1: ; unreferenced (see SilentHillScript7)
	text "Huh? It's locked."
	done

SilentHillMovement7: ; unreferenced (see SilentHillScript7)
	slow_step DOWN
	step_end

SilentHillSignPointers::
	dw SilentHillPlayerHouseText
	dw PokecenterSignScript
	dw SilentHillSignText1
	dw SilentHillLabText
	dw SilentHillRivalHouseText

SilentHillLabText:
	ld hl, SilentHillTextString2
	call OpenTextbox
	ret

SilentHillTextString2:
	text "Residents wanted!"
	done

SilentHillSignText1:
	ld hl, SilentHillTextString3
	call OpenTextbox
	ret

SilentHillTextString3:
	text "SILENT HILL"
	line "A quiet hill."
	done

SilentHillPlayerHouseText:
	ld hl, SilentHillTextString4
	call OpenTextbox
	ret

SilentHillTextString4:
	text "<PLAYER>'s house"
	done

SilentHillRivalHouseText:
	ld hl, SilentHillTextString5
	call OpenTextbox
	ret

SilentHillTextString5:
	text "<RIVAL>'s house"
	done

SilentHill_TextPointers::
	dw SilentHillTextRival1 ; west
	dw SilentHillTextNorthExit ; north
	dw SilentHillTextBackpack ; npc1
	dw SilentHillTextPokemonHate ; npc2

SilentHillTextRival1:
	text "<RIVAL>: Yo!"
	cont "I came over 'cause"
	cont "I've got something"
	cont "to brag about."

	para "I got mail from"
	line "the famous OAK!"
	cont "Huh? You got one"
	cont "too? Tch! No fun!"

	para "<⋯⋯>Hmph! Then say,"
	line "say, what do you"
	cont "always call your"
	cont "own mother?@"

	start_asm
	call LoadStandardMenuHeader
	callfar MomNamePrompt
	call CloseWindow
	call GetMemSGBLayout
	call UpdateSprites
	call UpdateTimePals
	jp TextAsmEnd

MomNameMenuHeaderUnused:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 10, 11
	dw .MomNameMenuDataUnused
	db 1 ; initial selection

.MomNameMenuDataUnused:
	db STATICMENU_CURSOR
	db 4 ; items
	db "NEW NAME@"
	db "MOM@"
	db "MAMA@"
	db "MOMMY@"

SilentHillTextRival2: ; BYTE OFF
	text "<RIVAL>: Ehh, how"
	line "uncool! Calling"
	cont "her something that"
	cont "childish is just a"
	cont "joke! Ahh, I feel"
	cont "a bit better now!"

	para "Well then, I'm"
	line "off to OAK's place"
	cont "a step ahead of"
	cont "you!"
	done

SilentHillTextNorthExit:
	text "Hold on a sec!"
	line "Wait! Wait up!"
	done

SilentHillTextPokemonInGrassString:
	text "You really don't"
	line "know a thing, huh!"
	cont "Wild # leap"
	cont "out of the grass!"

	para "If you had one of"
	line "your own, you"
	cont "could fight<⋯⋯>"

	para "Ah! Could it be"
	line "that you're<⋯⋯>"
	cont "Hold on, come"
	cont "with me!"
	done

SilentHillTextBackpack:
	ld hl, SilentHillTextBackpackString
	call OpenTextbox
	ret

SilentHillTextBackpackString:
if DEF(_GOLD)
	text "Your PACK looks"
	line "great! Where did"
	cont "you get it?"
	done
endc
if DEF(_SILVER)
	text "That watch is so"
	line "cool. Oh, it's a"
	cont "TRAINER GEAR?"
	done
endc

SilentHillTextPokemonHate:
	ld hl, SilentHillTextPokemonHateString
	call OpenTextbox
	ret

SilentHillTextPokemonHateString:
if DEF(_GOLD)
	text "I wonder if anyone"
	line "in the world"
	cont "dislikes #?"
	done
endc
if DEF(_SILVER)
	text "What? You collect"
	line "#!"

	para "That's a wonderful"
	line "thing to do."
	done
endc
