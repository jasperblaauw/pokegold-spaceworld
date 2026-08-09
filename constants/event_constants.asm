; wEventFlags bit flags

; Silent Hill events
	const_def
	const PLAYER_HOUSE_2F_READ_EMAIL
	const_skip 2
	const PLAYER_HOUSE_2F_TALKED_TO_KEN
	const_skip 1
	const SILENT_HILL_RIVAL_EVENT
	const RIVAL_HOUSE_READ_RIVAL_EMAIL
	const SILENT_HILL_TALKED_TO_BLUE
	const_skip 1
	const SILENT_HILL_LAB_BACK_FOLLOWED_OAK
	const SILENT_HILL_LAB_BACK_CHOSE_STARTER
	const_skip 9
	const SILENT_HILL_LAB_FRONT_GOT_POKEDEX
	const_skip 5
	const SILENT_HILL_LAB_FRONT_RIVAL_BATTLED
	const_skip 7
	const RIVAL_HOUSE_GOT_POKEGEAR_MAP
	const_skip 2
	const RIVAL_HOUSE_KEN_LEFT

; feature/completion: story events added by this romhack. wEventFlags is a
; flag_array, so bits 38-39 were already allocated as padding in the last byte —
; naming them costs no WRAM and no SRAM, and does not move anything after it.
; Adding a 41st event WILL grow the array by a byte and shift the saved data.
	const OAK_MISSING ; set when the §3 "Prof. Oak has vanished" beat fires (M3)
DEF NUM_EVENTS EQU const_value
