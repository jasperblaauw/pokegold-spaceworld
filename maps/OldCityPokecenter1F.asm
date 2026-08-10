	map_attributes OldCityPokecenter1F, OLD_CITY_POKECENTER_1F

OldCityPokecenter1F_MapEvents::
	dw $4000 ; unknown

	def_warp_events
	warp_event  5,  7, OLD_CITY, 10, 59
	warp_event  6,  7, OLD_CITY, 10, 60
	warp_event  0,  7, OLD_CITY_POKECENTER_2F, 1, 57

	def_bg_events
	bg_event 13,  1, 1

	def_object_events
	object_event  5,  1, SPRITE_NURSE, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event 14,  6, SPRITE_GENTLEMAN, SPRITEMOVEFN_RANDOM_SPIN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  2,  5, SPRITE_YOUNGSTER, SPRITEMOVEFN_RANDOM_WALK_Y, 0, 2, -1, -1, 0, 0, 0, 0, 0, 0
	object_event 10,  1, SPRITE_35, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0

OldCityPokecenter1F_Blocks::
INCBIN "maps/Pokecenter1F.blk"

	map_generic_scriptloader
	map_generic_script_pointers
	map_generic_script

	map_generic_npc_ids

OldCityPokecenter1FSignPointers:
	dw OldCityPokecenter1FPCText

OldCityPokecenter1FPCText:
	ld hl, OldCityPokecenter1FTextString1
	call OpenTextbox
	ret

OldCityPokecenter1FTextString1:
	text "A PC for TRAINERS"
	line "to use. Its screen"
	cont "is dark right now."
	done

OldCityPokecenter1F_TextPointers::
	dw OldCityPokecenter1FNPCText1
	dw OldCityPokecenter1FNPCText2
	dw OldCityPokecenter1FNPCText3
	dw OldCityPokecenter1FNPCText4

OldCityPokecenter1FNPCText1:
	ld hl, OldCityPokecenter1FTextString2
	call OpenTextbox
	ret

; feature/completion: the first real, working Pokémon Center nurse -- Silent
; Hill's is deliberately kept "under repair" (see PlayerHouse1F, MOM heals
; instead for the first act) and every other centre's nurse is still a stub.
; AnimateHealingMachine runs while this box is still open (start_asm), same as
; PlayerHouse2FCheckEmail's yes/no pattern -- the flashing-lights animation is
; meant to play alongside the dialogue, not after it closes.
OldCityPokecenter1FTextString2:
	text "Welcome to the"
	line "POKéMON CENTER!"

	para "Would you like me"
	line "to heal your"
	cont "#?@"

	start_asm
	call OldCityPokecenter1FHeal
	call TextAsmEnd
	ret

OldCityPokecenter1FHeal:
	call YesNoBox
	jr c, .declined
	callfar AnimateHealingMachine
	predef HealParty
	ld a, SPAWN_POINT_OLD
	ld [wDefaultSpawnPoint], a
	ld de, SFX_FULL_HEAL
	call WaitPlaySFX
	call WaitSFX
	ld hl, OldCityPokecenter1FTextString3
	call PrintText
	ret

.declined
	ld hl, OldCityPokecenter1FTextString4
	call PrintText
	ret

OldCityPokecenter1FTextString3:
	text "Your #"
	line "are fighting fit!"

	para "We hope to see you"
	line "again!"
	done

OldCityPokecenter1FTextString4:
	text "OK. Please take"
	line "care of yourself"
	cont "out there!"
	done

OldCityPokecenter1FNPCText2:
	ld hl, OldCityPokecenter1FTextString5
	call OpenTextbox
	ret

OldCityPokecenter1FTextString5:
	text "The GYM here is"
	line "just up the road."

	para "I hear the LEADER"
	line "is quite the"
	cont "character!"
	done

OldCityPokecenter1FNPCText3:
	ld hl, OldCityPokecenter1FTextString6
	call OpenTextbox
	ret

OldCityPokecenter1FTextString6:
	text "My #"
	line "got beat up"
	cont "pretty bad on"
	cont "ROUTE 3."

	para "Good thing this"
	line "place is free!"
	done

OldCityPokecenter1FNPCText4:
	ld hl, OldCityPokecenter1FTextString7
	call OpenTextbox
	ret

OldCityPokecenter1FTextString7:
	text "Just resting up"
	line "before I head back"
	cont "out."
	done
