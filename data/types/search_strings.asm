; Fixed-stride table: Pokedex_GetTypeString indexes it with
; POKEDEX_TYPE_STRING_LENGTH, so every entry must be padded to exactly that many
; bytes including the "@".
;
; The budget is 7 columns, set by the narrower of the two places these render:
; the search screen's selected-type box (interior columns 12-18). ELECTRIC and
; FIGHTING are the only English type names that do not fit, so they are the only
; two abbreviated here; data/types/names.asm keeps the full names everywhere else.
PokedexTypeSearchStrings::
	db "NORMAL @" ; NORMAL
	db "FIRE   @" ; FIRE
	db "WATER  @" ; WATER
	db "GRASS  @" ; GRASS
	db "ELECTR @" ; ELECTRIC
	db "ICE    @" ; ICE
	db "FIGHT  @" ; FIGHTING
	db "POISON @" ; POISON
	db "GROUND @" ; GROUND
	db "FLYING @" ; FLYING
	db "PSYCHIC@" ; PSYCHIC
	db "BUG    @" ; BUG
	db "ROCK   @" ; ROCK
	db "GHOST  @" ; GHOST
	db "DRAGON @" ; DRAGON
