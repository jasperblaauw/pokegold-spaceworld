	map_attributes SilentHillPokecenter, SILENT_HILL_POKECENTER

	object_const_def
	const SILENT_HILL_POKECENTER_NURSE
	const SILENT_HILL_POKECENTER_GENTLEMAN
	const SILENT_HILL_POKECENTER_COOLTRAINER_M
	const SILENT_HILL_POKECENTER_YOUNGSTER
	const SILENT_HILL_POKECENTER_HOUNDOOM

SilentHillPokecenter_MapEvents::
	dw $4000 ; unknown

	def_warp_events
	warp_event  5,  7, SILENT_HILL, 2, 59
	warp_event  6,  7, SILENT_HILL, 2, 60

	def_bg_events
	bg_event 13,  1, 1

	def_object_events
	object_event  5,  1, SPRITE_NURSE, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event 14,  6, SPRITE_GENTLEMAN, SPRITEMOVEFN_RANDOM_SPIN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  3,  4, SPRITE_COOLTRAINER_M, SPRITEMOVEFN_RANDOM_WALK_X, 1, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  9,  1, SPRITE_YOUNGSTER, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event 10,  1, SPRITE_RHYDON, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0

SilentHillPokecenter_Blocks::
INCBIN "maps/SilentHillPokecenter.blk"

	map_generic_scriptloader
	map_generic_script_pointers
	map_generic_script

	dw SilentHillPokecenterNPCIDs ; leftover from non-demo version?

	map_generic_npc_ids

SilentHillPokecenterSignPointers:
	dw SilentHillPokecenterPCText

SilentHillPokecenterPCText:
	ld hl, SilentHillPokecenterTextString1
	call OpenTextbox
	ret

SilentHillPokecenterTextString1:
	text "Currently under"
	line "adjustment."
	done

SilentHillPokecenter_TextPointers::
	dw SilentHillPokecenterNPCText1
	dw SilentHillPokecenterNPCText2
	dw SilentHillPokecenterNPCText3
	dw SilentHillPokecenterNPCText4
	dw SilentHillPokecenterNPCText5

SilentHillPokecenterNPCText1:
	ld hl, SilentHillPokecenterTextString2
	call OpenTextbox
	ret

SilentHillPokecenterTextString2:
	text "I'm very sorry,"
	line "but we're under"
	cont "repair right now."

	para "We can't heal your"
	line "# just yet."

	para "Please take plenty"
	line "of care when you"
	cont "leave town."
	done

SilentHillPokecenterNPCText2:
	ld hl, SilentHillPokecenterTextString3
	call OpenTextbox
	ret

SilentHillPokecenterTextString3:
	text "That <PC> over"
	line "there is free to"
	cont "use any time, as"
	cont "long as you're a"
	cont "TRAINER."
	cont "Handy, huh!"
	done

SilentHillPokecenterNPCText3:
	ld hl, SilentHillPokecenterTextString4
	call OpenTextbox
	ret

SilentHillPokecenterTextString4:
	text "That machine they"
	line "are preparing now"
	cont "is supposedly"
	cont "amazing."

	para "They say it can"
	line "even trade #"
	cont "across time!"

	para "Is that really"
	line "true?"
	done

SilentHillPokecenterNPCText4:
	ld hl, SilentHillPokecenterTextString5
	call OpenTextbox
	ret

SilentHillPokecenterTextString5:
	text "This is HOUNDOOM."
	line "A type of # "
	cont "there's never"
	cont "been before."
	done

SilentHillPokecenterNPCText5:
	ld hl, SilentHillPokecenterTextString6
	call OpenTextbox
	ret

SilentHillPokecenterTextString6:
	text "HOUNDOOM: Grrrrr!"
	done
