	map_attributes PlayerHouse2F, PLAYER_HOUSE_2F

	object_const_def
	const PLAYER_HOUSE_2F_KEN
	const PLAYER_HOUSE_2F_POKEDOLL

PlayerHouse2F_MapEvents::
	dw $4000 ; unknown

	def_warp_events
	warp_event  9,  0, PLAYER_HOUSE_1F, 3, 16

	def_bg_events
	bg_event  1,  1, 1
	bg_event  2,  1, 2
	bg_event  3,  1, 3
	bg_event  5,  1, 4
	bg_event  7,  2, 5

	def_object_events
	object_event  8,  1, SPRITE_ROCKER, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  6,  1, SPRITE_CLEFAIRY, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0

PlayerHouse2F_Blocks::
INCBIN "maps/PlayerHouse2F.blk"

	map_generic_scriptloader

PlayerHouse2FScriptPointers::
	def_script_pointers
	script_pointer PlayerHouse2FScript1, PlayerHouse2FNPCIDs1, SCENE_PLAYER_HOUSE_2F_DEFAULT
	script_pointer PlayerHouse2FScript2, PlayerHouse2FNPCIDs2, SCENE_PLAYER_HOUSE_2F_KEN_LEFT

PlayerHouse2F_TextPointers::
	dw PlayerHouse2FText1
	dw PlayerHouse2FDollText

PlayerHouse2FNPCIDs1:
	npc_id PLAYER_HOUSE_2F_KEN
	npc_id PLAYER_HOUSE_2F_POKEDOLL
	db -1

PlayerHouse2FNPCIDs2:
	npc_id PLAYER_HOUSE_2F_POKEDOLL
	db -1

PlayerHouse2FSignPointers:
	dw PokemonBooksScript
	dw PlayerHouse2FRadioText
	dw PlayerHouse2FComputerText
	dw PokemonBooksScript
	dw PlayerHouse2FN64Text

PlayerHouse2FScript1:
	call PlayerHouse2PositionCheck
	ret z
	ld hl, PlayerHouse2FNPCIDs1
	ld de, PlayerHouse2FSignPointers
	call CallMapTextSubroutine
	ret nz
	ret

PlayerHouse2PositionCheck:
	CheckEvent PLAYER_HOUSE_2F_READ_EMAIL
	ret nz
	ld a, [wYCoord]
	cp 1
	ret nz
	ld a, [wXCoord]
	cp 9
	ret nz
	ld hl, wJoypadFlags
	set 6, [hl]
	ld a, LEFT
	ld d, 0
	call SetObjectFacing
	ld hl, PlayerHouse2FTextString2
	call OpenTextbox
	call PlayerHouse2FMovePlayer
	call xor_a
	ret

PlayerHouse2FMovePlayer:
	ld a, 0
	ld hl, .Movement
	call LoadMovementDataPointer
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, MAPSTATUS_EVENT_RUNNING
	call SetMapStatus
	ret

.Movement:
	step DOWN
	slow_step DOWN
	step_end

PlayerHouse2FScript2:
	ld hl, PlayerHouse2FNPCIDs2
	ld de, PlayerHouse2FSignPointers
	call CallMapTextSubroutine
	ret

PlayerHouse2FText1:
	CheckEvent PLAYER_HOUSE_2F_TALKED_TO_KEN
	jr nz, .jump
	ld hl, PlayerHouse2FTextString1
	call OpenTextbox
	SetEvent PLAYER_HOUSE_2F_TALKED_TO_KEN
	ld c, 3
	call DelayFrames
.jump
	ld hl, PlayerHouse2FTextString2
	call OpenTextbox
	ret

PlayerHouse2FDollText:
	ld hl, PlayerHouse2FTextString3
	call OpenTextbox
	ret

PlayerHouse2FRadioText:
	ld hl, PlayerHouse2FTextString9
	call OpenTextbox
	ret

PlayerHouse2FComputerText:
	CheckEvent PLAYER_HOUSE_2F_READ_EMAIL
	jr nz, .jump
	ld hl, PlayerHouse2FTextString5
	call OpenTextbox
	ret

.jump
	call ReanchorMap
	callfar PokemonCenterPC
	call CloseText
	ret

PlayerHouse2FCheckEmail:
	call YesNoBox
	jr c, .jump2
	SetEvent PLAYER_HOUSE_2F_READ_EMAIL
	ld hl, PlayerHouse2FTextString6
	call PrintText
	ret

.jump2
	ld hl, PlayerHouse2FTextString7
	call PrintText
	ret

PlayerHouse2FN64Text:
	ld hl, PlayerHouse2FTextString4
	call OpenTextbox
	ret

PlayerHouse2FTextString1:
	text "KEN: Whoa! That"
	line "watch shining on"
	cont "your wrist<⋯⋯>"
	cont "<PLAYER>, you got a"
	cont "TRAINER GEAR too!"

	para "Pretty sharp!"
	line "But fresh out of"
	cont "the box, all it"
	cont "tells you is the"
	cont "time, right?"
	cont "Later I'll set it"
	cont "up to show a map!"

	para "You're off to play"
	line "anyway, right?"

	para "Too bad, though."
	line "MOM's out shopping"
	cont "so no allowance"
	cont "for you today!"
	done

PlayerHouse2FTextString2:
	text "That's right, you"
	line "had mail on your"
	cont "<PC>. If you're"
	cont "going out, read"
	cont "it first at least."
	done

PlayerHouse2FTextString3:
	text "It's a doll my"
	line "relatives in KANTO"
	cont "gave me for"
	cont "CHRISTMAS."
	done

PlayerHouse2FTextString4:
	text "Playing my"
	cont "NINTENDO 64!"
	cont "<⋯⋯> Right then!"
	cont "Guess it's time to"
	cont "go outside!"
	done

PlayerHouse2FTextString5:
	text "<PLAYER> turned on"
	line "the <PC>!"

	para "Huh? There's mail"
	line "for <PLAYER>."
	cont "Read it?@"

	start_asm
	call PlayerHouse2FCheckEmail
	call TextAsmEnd
	ret

PlayerHouse2FTextString6:
	text "Forgive me for"
	line "writing to you so"
	cont "suddenly."

	para "The truth is, I"
	line "have something I"
	cont "must give you."
	cont "Would you accept"
	cont "it?"

	para "# researcher"
	line "OAK"
	done

PlayerHouse2FTextString7:
	text "I'll read it"
	line "later<⋯⋯>"
	done

PlayerHouse2FTextString8: ; (unused?)
	text "New release: the"
	line "TRAINER GEAR!"
	cont "The cutting-edge"
	cont "watch made for"
	cont "# TRAINERS."

	para "Of course it tells"
	line "the time. Add a"
	cont "cartridge and it"
	cont "shows your place!"
	cont "It makes calls!"

	para "And to top it off,"
	line "you can listen to"
	cont "the radio!"

	para "To order<⋯⋯>"
	line "<⋯⋯><⋯⋯><⋯⋯>"
	cont "SILPH's home page."
	done

PlayerHouse2FTextString9:
	text "<PLAYER> switched"
	line "on the radio!"

	para "J-O-P-M. This is"
	line "# Radio,"
	cont "bringing you the"
	cont "# News."

	para "<⋯⋯> The famous"
	line "# researcher"
	cont "PROF.OAK has"
	cont "vanished from"
	cont "KANTO!"

	para "Some believe he"
	line "moved on to find a"
	cont "new place for his"
	cont "research."

	para "But he may have"
	line "been caught up in"
	cont "some incident, and"
	cont "those close to him"
	cont "are very worried."

	para "<⋯⋯> That was"
	line "the # News."

	para "<⋯⋯><⋯⋯><⋯⋯>"
	line "And now, please"
	cont "enjoy the music."
	done
