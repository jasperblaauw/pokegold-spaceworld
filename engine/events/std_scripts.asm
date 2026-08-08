; The actual code for std_collision.asm isn't present yet, so scripts are currently loaded
; from an object placed over the corresponding collision tile.

; Early duplicate of PlayerHouse2FRadioText, which is present in the map's bank in the final game.
; Uses the long "POKéMON" and "<⋯⋯><⋯⋯>" spelled out instead of their shortcut
; control codes, and lacks the final sentence.
_Unreferenced_PokemonNewsScript::
	ld hl, .DuplicatePokemonNewsText
	call OpenTextbox
	ret

.DuplicatePokemonNewsText
	text "<PLAYER> switched"
	line "on the radio!"

	para "J-O-P-M. This is"
	line "POKéMON Radio,"
	cont "bringing you the"
	cont "POKéMON News."

	para "<⋯⋯> The famous"
	line "POKéMON researcher"
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

	para "<⋯⋯><⋯⋯> That was"
	line "the POKéMON News."

	para "⋯⋯⋯⋯⋯⋯⋯⋯⋯⋯⋯⋯"
	done

_PokemonBooksScript::
	ld hl, .PokemonBooksText
	call OpenTextbox
	ret

; "Crammed full of POKéMON books!" flavor text
.PokemonBooksText:
	text "Crammed full of"
	line "# books!"
	done

_FridgeScript::
	ld hl, .FridgeText
	call OpenTextbox
	ret

.FridgeText:
	text "Inside<⋯⋯>"
	line "it's almost"
	cont "empty<⋯⋯>"
	done

_StoveScript::
	ld hl, .StoveText
	call OpenTextbox
	ret

.StoveText:
	text "The gas burner is"
	line "switched off."
	cont "Safety first!"
	done

_SinkScript::
	ld hl, .SinkText
	call OpenTextbox
	ret

.SinkText:
	text "A sparkling clean"
	line "sink!"
	cont "What's on the menu"
	cont "tonight?"
	done

_PokecenterSignScript::
	ld hl, .PokecenterSignText
	call OpenTextbox
	ret

.PokecenterSignText:
	text "Restore #"
	line "to full health!"
	cont "# CENTER"
	done

_WindowScript::
	ld hl, .WindowText
	call OpenTextbox
	ret

.WindowText:
	text "The window is"
	line "dirty, isn't it?"
	done

; Various scenes from the Pokemon anime that play on the player and rival's TVs
_TVScript::
	ld a, [wTimeOfDay]
	and a
	jr nz, .not_day
	ld hl, .TVDayText
	jr .done

.not_day
	dec a
	jr nz, .not_night
	ld hl, .TVNightText
	jr .done

.not_night
	ld hl, .TVMorningText
.done
	call OpenTextbox
	ret

; Scene from "Pokémon: I Choose You!"
.TVDayText:
	text "PIKACHU battles a"
	line "SPEAROW<⋯⋯>"
	cont "SATOSHI has tears"
	cont "in his eyes<⋯⋯>"
	cont "It's the #"
	cont "cartoon!"
	done

; Scene from "Primeape Goes Bananas"
.TVNightText:
	text "A PRIMEAPE is on"
	cont "the rampage<⋯⋯>"
	cont "SATOSHI is running"
	cont "for his life!<⋯⋯>"
	cont "It's the #"
	cont "cartoon!"
	done

; Scene from "Bulbasaur's Mysterious Garden"
.TVMorningText:
	text "A BULBASAUR is"
	cont "sulking<⋯⋯>"
	cont "SATOSHI doesn't"
	cont "know what to do<⋯⋯>"
	cont "It's the #"
	cont "cartoon!"
	done
