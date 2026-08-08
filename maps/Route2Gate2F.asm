	map_attributes Route2Gate2F, ROUTE_2_GATE_2F

	object_const_def
	const ROUTE_2_GATE_2F_LASS
	const ROUTE_2_GATE_2F_TWIN

Route2Gate2F_MapEvents::
	dw $4000 ; unknown

	def_warp_events
	warp_event  5,  0, ROUTE_2_GATE_1F, 5, 13

	def_bg_events
	bg_event  1,  0, 1
	bg_event  3,  0, 2

	def_object_events
	object_event  3,  3, SPRITE_LASS, SPRITEMOVEFN_RANDOM_WALK_XY, 1, 1, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  6,  4, SPRITE_TWIN, SPRITEMOVEFN_RANDOM_SPIN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0

Route2Gate2F_Blocks::
INCBIN "maps/Route2Gate2F.blk"

	map_generic_scriptloader
	map_generic_script_pointers
	map_generic_npc_ids

Route2Gate2FSignPointers:
	dw Route2Gate2FTextSign1
	dw Route2Gate2FTextSign2
Route2Gate2F_TextPointers::
	dw Route2Gate2FTextNPC1
	dw Route2Gate2FTextNPC2

	map_generic_script

Route2Gate2FTextNPC1:
	ld hl, Route2Gate2FTextString1
	call OpenTextbox
	ret

Route2Gate2FTextNPC2:
	ld hl, Route2Gate2FTextString2
	call OpenTextbox
	ret

Route2Gate2FTextSign1:
	ld hl, Route2Gate2FTextString3
	call OpenTextbox
	ret

Route2Gate2FTextSign2:
	ld hl, Route2Gate2FTextString4
	call OpenTextbox
	ret

Route2Gate2FTextString1:
	text "Do you know"
	line "Mr.GANTETSU?"

	para "If you can get on"
	line "his good side,"
	cont "you're quite the"
	cont "TRAINER."
	done

Route2Gate2FTextString2:
	text "Did you come"
	line "sightseeing?"
	cont "Then that's a"
	cont "shame."

	para "OLD CITY's FIVE-"
	line "STORY PAGODA isn't"
	cont "a place just"
	cont "anyone can enter."
	done

Route2Gate2FTextString3:
	text "<PLAYER> peered"
	line "through the"
	cont "telescope!"

	para "Mmm! A tall, tall"
	line "tower is visible!"
	done

Route2Gate2FTextString4:
	text "<PLAYER> peered"
	line "through the"
	cont "telescope!"

	para "Hmm? A long, long"
	line "river is visible."
	done
