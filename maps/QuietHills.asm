	map_attributes QuietHills, QUIET_HILLS

	object_const_def
	const QUIET_HILLS_ROCKER
	const QUIET_HILLS_TRAINER1
	const QUIET_HILLS_TRAINER2
	const QUIET_HILLS_TRAINER3
	const QUIET_HILLS_TRAINER4
	const QUIET_HILLS_TRAINER5

QuietHills_MapEvents::
	dw $4000 ; unknown

	def_warp_events
	warp_event 49, 28, ROUTE_1, 1, 490
	warp_event 49, 29, ROUTE_1, 1, 490
	warp_event 49, 30, ROUTE_1, 2, 521
	warp_event 49, 31, ROUTE_1, 2, 521
	warp_event  4,  0, ROUTE_2, 3, 34
	warp_event  5,  0, ROUTE_2, 3, 34
	warp_event  6,  0, ROUTE_2, 3, 35
	warp_event  7,  0, ROUTE_2, 4, 35
	warp_event  8,  0, ROUTE_2, 4, 36
	warp_event  9,  0, ROUTE_2, 4, 36

	def_bg_events
	bg_event  9,  2, 1
	bg_event 47, 28, 2

	def_object_events
	object_event 41, 28, SPRITE_ROCKER, SPRITEMOVEFN_TURN_DOWN, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  9,  7, SPRITE_YOUNGSTER, SPRITEMOVEFN_TURN_LEFT, 0, 0, -1, -1, 0, 0, 0, 5, 0, 0
	object_event 41, 19, SPRITE_YOUNGSTER, SPRITEMOVEFN_TURN_LEFT, 0, 0, -1, -1, 0, 0, 0, 4, 0, 0
	object_event 27, 14, SPRITE_FISHER, SPRITEMOVEFN_RANDOM_SPIN, 0, 0, -1, -1, 0, 0, 0, 2, 0, 0
	object_event 36, 16, SPRITE_TEACHER, SPRITEMOVEFN_TURN_UP, 0, 0, -1, -1, 0, 0, 0, 5, 0, 0
	object_event  9, 25, SPRITE_YOUNGSTER, SPRITEMOVEFN_TURN_RIGHT, 0, 0, -1, -1, 0, 0, 0, 4, 0, 0

QuietHills_Blocks::
INCBIN "maps/QuietHills.blk"

	map_generic_scriptloader
	map_generic_script_pointers
	map_generic_npc_ids

QuietHillsSignPointers:
	dw QuietHillsSignpost1
	dw QuietHillsSignpost2

QuietHills_TextPointers:
	dw QuietHillsText1
	dw QuietHillsTrainer2
	dw QuietHillsTrainer3
	dw QuietHillsTrainer4
	dw QuietHillsTrainer5
	dw QuietHillsTrainer6

	map_generic_script

QuietHillsText1:
	ld hl, QuietHillsText1String
	call OpenTextbox
	ret

QuietHillsTrainer2:
	ld hl, wQuietHillsFlags
	bit 1, [hl]
	jr nz, .Trainer2Won
	ld hl, QuietHillsTrainer2EncounterString
	call OpenTextbox
	ld hl, wQuietHillsFlags
	set 1, [hl]
if DEF(_GOLD)
	ld a, TRAINER_SCHOOLBOY
	ld [wOtherTrainerClass], a
	ld a, SCHOOLBOY_TETSUYA
endc
if DEF(_SILVER)
	ld a, TRAINER_SPORTSMAN
	ld [wOtherTrainerClass], a
	ld a, SPORTSMAN_TETSUJI
endc
	ld [wOtherTrainerID], a
	call InitTrainerBattle
	ret
.Trainer2Won ;Already won
	ld hl, QuietHillsTrainer2WonString
	call OpenTextbox
	ret

QuietHillsTrainer3:
	ld hl, wQuietHillsFlags
	bit 2, [hl]
	jr nz, .Trainer3Won
	ld hl, QuietHillsTrainer3EncounterString
	call OpenTextbox
	ld hl, wQuietHillsFlags
	set 2, [hl]
if DEF(_GOLD)
	ld a, TRAINER_BUG_CATCHER_BOY
	ld [wOtherTrainerClass], a
	ld a, BUG_CATCHER_BOY_JUNICHI
endc
if DEF(_SILVER)
	ld a, TRAINER_BUG_CATCHER_BOY
	ld [wOtherTrainerClass], a
	ld a, BUG_CATCHER_BOY_KEN
endc
	ld [wOtherTrainerID], a
	call InitTrainerBattle
	ret
.Trainer3Won ;Already won
	ld hl, QuietHillsTrainer3WonString
	call OpenTextbox
	ret

QuietHillsTrainer4:
	ld hl, wQuietHillsFlags
	bit 3, [hl]
	jr nz, .Trainer4Won
	ld hl, QuietHillsTrainer4EncounterString
	call OpenTextbox
	ld hl, wQuietHillsFlags
	set 3, [hl]
if DEF(_GOLD)
	ld a, TRAINER_FIREBREATHER
	ld [wOtherTrainerClass], a
	ld a, FIREBREATHER_AKITO
endc
if DEF(_SILVER)
	ld a, TRAINER_FISHER
	ld [wOtherTrainerClass], a
	ld a, FISHER_HISASHI
endc
	ld [wOtherTrainerID], a
	call InitTrainerBattle
	ret
.Trainer4Won ;Already won
	ld hl, QuietHillsTrainer4WonString
	call OpenTextbox
	ret

QuietHillsTrainer5:
	ld hl, wQuietHillsFlags
	bit 4, [hl]
	jr nz, .Trainer5Won
	ld hl, QuietHillsTrainer5EncounterString
	call OpenTextbox
	ld hl, wQuietHillsFlags
	set 4, [hl]
if DEF(_GOLD)
	ld a, TRAINER_BEAUTY
	ld [wOtherTrainerClass], a
	ld a, BEAUTY_MEGUMI
endc
if DEF(_SILVER)
	ld a, TRAINER_LASS
	ld [wOtherTrainerClass], a
	ld a, LASS_HIZUKI
endc
	ld [wOtherTrainerID], a
	call InitTrainerBattle
	ret
.Trainer5Won ;Already won
	ld hl, QuietHillsTrainer5WonString
	call OpenTextbox
	ret

QuietHillsTrainer6:
	ld hl, wQuietHillsFlags
	bit 5, [hl]
	jr nz, .Trainer6Won
	ld hl, QuietHillsTrainer6EncounterString
	call OpenTextbox
	ld hl, wQuietHillsFlags
	set 5, [hl]
if DEF(_GOLD)
	ld a, TRAINER_BUG_CATCHER_BOY
	ld [wOtherTrainerClass], a
	ld a, BUG_CATCHER_BOY_SOUSUKE
endc
if DEF(_SILVER)
	ld a, TRAINER_BUG_CATCHER_BOY
	ld [wOtherTrainerClass], a
	ld a, BUG_CATCHER_BOY_KENJI
endc
	ld [wOtherTrainerID], a
	call InitTrainerBattle
	ret
.Trainer6Won ;Already won
	ld hl, QuietHillsTrainer6WonString
	call OpenTextbox
	ret

QuietHillsSignpost2:
	ld hl, QuietHillsSignpost2String
	call OpenTextbox
	ret

QuietHillsSignpost1:
	ld hl, QuietHillsSignpost1String
	call OpenTextbox
	ret

if DEF(_GOLD)

QuietHillsTrainer6EncounterString:
	text "Hey, hey, look at"
	line "this!"

	para "This has GOT to be"
	line "a new species of"
	cont "#!"
	done

	text "I still don't know"
	line "this one's traits,"
	cont "so it can't be"
	cont "helped."
	done

QuietHillsTrainer6WonString:
	text "Rumour has it that"
	line "not just new"
	cont "# have been"
	cont "found, but new"
	cont "types too."
	done

QuietHillsTrainer5EncounterString:
	text "Lovely weather,"
	line "isn't it?"
	cont "How are you doing?"
	done

	text "What was that for,"
	line "meow!"
	cont "<⋯⋯>what am I even"
	cont "saying?"
	done

QuietHillsTrainer5WonString:
	text "Why did it turn"
	line "out like this?"
	cont "I was only taking"
	cont "a walk<⋯⋯>@@"

QuietHillsTrainer4EncounterString:
	text "Practising my"
	line "fire-breathing out"
	cont "here!"
	done

	text "Ow-ow-ow, I blew"
	line "it!"
	done

QuietHillsTrainer4WonString:
	text "It gets dark once"
	line "night falls, so"
	cont "kids, hurry home!"

	para "Me? I'm fine."
	line "I breathe fire."
	done

QuietHillsTrainer3EncounterString:
	text "When it comes to"
	line "BUG #, I"
	cont "know more than"
	cont "anyone."
	done

	text "Para-para!"
	done

QuietHillsTrainer3WonString:
	text "You're making a"
	line "POKéDEX? Let me"
	cont "see it a sec."

	para "Ohh, so you can"
	line "search for #"
	cont "by type."
	done

QuietHillsTrainer2EncounterString:
	text "Just so you know,"
	line "I study harder"
	cont "than you, so I'm"
	cont "definitely"
	cont "stronger than you!"
	done

	text "W-why<⋯⋯>?"
	done

QuietHillsTrainer2WonString:
	text "That's strange<⋯⋯>"
	line "I study # "
	cont "properly every"
	cont "single day, and"
	cont "yet I lost<⋯⋯>"
	done

endc

if DEF(_SILVER)

QuietHillsTrainer6EncounterString:
	text "Ta-daa!"
	line "A never-before-"
	cont "seen #, a"
	cont "huge discovery!"
	done

	text "I should have"
	line "caught some other"
	cont "# too<⋯⋯>"
	done

QuietHillsTrainer6WonString:
	text "I've never seen"
	line "your #"
	cont "either. Say, want"
	cont "a trade?"
	done

QuietHillsTrainer5EncounterString:
	text "Hey, hey, let's"
	line "have a # "
	cont "battle, come on!"
	done

	text "Nooo!"
	done

QuietHillsTrainer5WonString:
	text "It gets dark when"
	line "night falls, no?"
	cont "Even walking, I"
	cont "can't see much"
	cont "around me. Scary."
	done

QuietHillsTrainer4EncounterString:
	text "You!"

	para "I won't get mad,"
	line "so tell me where"
	cont "there's a pond!"
	done

	text "If there's no"
	line "water nearby<⋯⋯>"
	done

QuietHillsTrainer4WonString:
	text "Why is a grown man"
	line "in a place like"
	cont "this?"
	done

QuietHillsTrainer3EncounterString:
	text "Just started out"
	line "with #? In"
	cont "that case I won't"
	cont "lose!"
	done

	text "Whoa, what the"
	line "heck?"
	done

QuietHillsTrainer3WonString:
	text "Man, that's"
	line "seriously"
	cont "frustrating."
	done

QuietHillsTrainer2EncounterString:
	text "This place is wide"
	line "open, perfect for"
	cont "training."

	para "Training for what?"
	line "# training,"
	cont "of course!"
	done

	text "A-am I short on"
	line "practice<⋯⋯>?"
	done

QuietHillsTrainer2WonString:
	text "Alright, time to"
	line "run!"
	done

endc

QuietHillsText1String:
	text "The # on"
	line "this hill are"
	cont "weak! That's why"
	cont "lots of TRAINERS"
	cont "train here."

	para "Everyone loves"
	line "battling, so it's"
	cont "a good place to"
	cont "test your skill."
	done

QuietHillsSignpost2String:
	text "QUIET HILL"
	line "SILENT HILL, this"
	cont "way."
	done

QuietHillsSignpost1String:
	text "QUIET HILL"
	line "OLD CITY, this"
	cont "way."
	done
