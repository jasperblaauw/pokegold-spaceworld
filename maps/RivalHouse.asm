	map_attributes RivalHouse, RIVAL_HOUSE
	
	object_const_def
	const RIVAL_HOUSE_RIVALS_SISTER
	const RIVAL_HOUSE_KEN

RivalHouse_MapEvents::
	dw $4000 ; unknown

	def_warp_events
	warp_event  4,  7, SILENT_HILL, 3, 47
	warp_event  5,  7, SILENT_HILL, 3, 47

	def_bg_events
	bg_event  0,  1, 1
	bg_event  4,  1, 2
	bg_event  5,  1, 3
	bg_event  9,  1, 4
	bg_event  8,  1, 5
	bg_event  2,  0, 6

	def_object_events
	object_event  5,  3, SPRITE_SILVERS_SISTER, SPRITEMOVEFN_TURN_LEFT, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  5,  4, SPRITE_ROCKER, SPRITEMOVEFN_TURN_LEFT, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0

RivalHouse_Blocks::
INCBIN "maps/RivalHouse.blk"

	map_generic_scriptloader

RivalHouseScriptPointers::
	def_script_pointers
	script_pointer RivalHouseScript1, RivalHouseNPCIDs1, SCENE_RIVAL_HOUSE_DEFAULT
	script_pointer RivalHouseScript2, RivalHouseNPCIDs2, SCENE_RIVAL_HOUSE_KEN_HERE
	script_pointer RivalHouseScript3, RivalHouseNPCIDs1, SCENE_RIVAL_HOUSE_GOT_MAP_CARD

RivalHouseScript1:
	ld hl, RivalHouseNPCIDs1
	ld de, RivalHouseTextPointers2
	call CallMapTextSubroutine
	ret

RivalHouseScript2:
	ld hl, RivalHouseNPCIDs2
	ld de, RivalHouseTextPointers2
	call CallMapTextSubroutine
	ret

RivalHouseScript3: ; This could have just been a multidefinition
	ld hl, RivalHouseNPCIDs1
	ld de, RivalHouseTextPointers2
	call CallMapTextSubroutine
	ret

RivalHouseNPCIDs1:
	db 0
	db $FF

RivalHouseNPCIDs2:
	db 0
	db 1
	db $FF

RivalHouseTextPointers2::
	dw RivalHouseNPCText1
	dw TVScript
	dw PokemonBooksScript
	dw SinkScript
	dw StoveScript
	dw WindowScript

RivalHouseNPCText1:
	CheckEvent RIVAL_HOUSE_READ_RIVAL_EMAIL
	jr nz, .jump
	ld hl, RivalHouseTextString1
	call OpenTextbox
	ret

.jump
	call ReanchorMap
	callfar PokemonCenterPC
	call CloseText
	ret

RivalHouseTextString1:
	text "Huh? There's mail"
	line "for <RIVAL>."
	cont "Read it?@"

	start_asm
	call YesNoBox
	jr c, .jump
	SetEvent RIVAL_HOUSE_READ_RIVAL_EMAIL
	ld hl, RivalHouseTextString2
	call PrintText
	call TextAsmEnd
	ret
.jump
	ld hl, RivalHouseTextString3
	call PrintText
	call TextAsmEnd
	ret

RivalHouseTextString2:
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

RivalHouseTextString3:
	text "You shouldn't read"
	line "other people's"
	cont "mail<⋯⋯>"
	done

RivalHouse_TextPointers::
	dw RivalHouseNPCText3
	dw RivalHouseNPCText4

RivalHouseNPCText3:
	ld hl, RivalHouseTextString4
	call OpenTextbox
	ret

RivalHouseTextString4:
	text "The other day I"
	line "spotted a PIDGEY"
	cont "of an odd colour."
	done

RivalHouseNPCText4:
	CheckEvent RIVAL_HOUSE_GOT_POKEGEAR_MAP
	jr nz, .jump
	SetEvent RIVAL_HOUSE_GOT_POKEGEAR_MAP
	ld hl, RivalHouseTextString5
	call OpenTextbox
	call WaitBGMap
	ld hl, RivalHouseTextString6
	jr .skip
.jump
	ld hl, RivalHouseTextString7
.skip
	call OpenTextbox
	ret

RivalHouseTextString5:
	text "KEN: Wh-wh-what,"
	line "if it isn't"
	cont "<PLAYER>!"

	para "I'm, uh, just here"
	line "to help out with"
	cont "some homework!"

	para "Huh? A map?"
	line "Oh right, I did"
	cont "promise that."
	cont "Got it. Lend me"
	cont "your TRAINER GEAR."

	para "Slot the map"
	line "cartridge in<⋯⋯>"
	cont "There! Now you can"
	cont "see the map!"
	done

RivalHouseTextString6:
	text "If you head to"
	line "OLD CITY, go meet"
	cont "a guy named BILL."

	para "He's a friend of"
	line "mine and a huge"
	cont "# maniac!"
	cont "He's sure to lend"
	cont "you a hand."
	done

RivalHouseTextString7:
	text "KEN: <PLAYER>,"
	line "I hear PROF.OAK"
	cont "picked you to make"
	cont "a POKéDEX?"

	para "That's amazing!"
	line "Good luck!"
	done
