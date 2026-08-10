; Meters
DEF POKEDEX_m EQU $60
; Kilograms
DEF POKEDEX_k EQU $61
DEF POKEDEX_g EQU $62

_DisplayDexEntry:
	hlcoord 9, 6
	ld de, PokedexText_HeightWeight
	call PlaceString
	call GetPokemonName
	hlcoord 9, 2
	call PlaceString
	ld hl, PokedexEntryPointers1
	ld a, [wTempSpecies]
	cp DEX_VOLTORB
	jr c, .got_dex_entries
	sub DEX_VOLTORB - 1
	ld hl, PokedexEntryPointers2

.got_dex_entries
	dec a
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 9, 4
	call PlaceString
	ld h, b
	ld l, c
	push de
	ld de, PokedexText_Pokemon
	call PlaceString
	hlcoord 2, 8
	ld a, '№'
	ld [hli], a
	ld a, '．'
	ld [hli], a
	ld de, wTempSpecies
	lb bc, PRINTNUM_LEADINGZEROS | 1, 3
	call PrintNumber
; Return if species isn't caught
	callfar Pokedex_CheckCaught
	push af
	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	pop af
	pop de
	ret z

	inc de
	ld a, [de]
	and a
	jr z, .skip_height

	hlcoord 13, 6
	lb bc, 1, 3
	call PrintNumber

	hlcoord 14, 6
	ld a, [de]
	cp 10
	jr nc, .less_than_1_meter
	ld [hl], '０'

.less_than_1_meter
; Shift last digit to the right and put decimal point in its place.
	inc hl
	ld a, [hli]
	ld [hld], a
	ld [hl], '．'

.skip_height
	inc de
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	or b
	push de
	jr z, .skip_weight

	ld hl, hPokedexTempWeight
	ld a, [hl]
	push af
	ld a, [de]
	ld [hli], a
	ld a, [hl]
	push af
	dec de
	ld a, [de]
	ld [hl], a
	ld de, hPokedexTempWeight
	hlcoord 12, 8
	lb bc, 2, 4
	call PrintNumber

	hlcoord 14, 8
	ldh a, [hPokedexTempWeight + 1]
	sub 10
	ldh a, [hPokedexTempWeight]
	sbc 0
	jr nc, .less_than_1_kilogram
	ld [hl], '０'

.less_than_1_kilogram
; Shift last digit to the right and put decimal point in its place.
	inc hl
	ld a, [hli]
	ld [hld], a
	ld [hl], '．'

	pop af
	ldh [hPokedexTempWeight + 1], a
	pop af
	ldh [hPokedexTempWeight], a
.skip_weight
	pop de
	inc de
; The description is stored as a run of '@'-terminated lines ended by an empty line
; ("@"). Print each on its own row from (1,10) down: single-spaced (rows 10-16, up to
; 7 lines of 18 cols) because English flavor needs far more room than the kana did, and
; this engine's <NEXT> steps two rows while <LINE> is hardwired to (1,16) - neither can
; give a single-spaced column here. PlaceString returns hl at the line's start, so
; advancing one SCREEN_WIDTH lands on the next row.
	hlcoord 1, 10
.print_desc_line
	ld a, [de]
	cp '@'
	ret z
	call PlaceString
	ld bc, SCREEN_WIDTH
	add hl, bc
	inc de
	jr .print_desc_line

; Both rows start at column 9. The placeholder '?' columns must line up with the
; digits PrintNumber writes over them: height at columns 13-16 + 'm' at 17,
; weight at columns 12-16 + "kg" at 17-18. <NEXT> steps TWO rows in this engine
; (home/text.asm), which is why the weight row is row 8, not row 7.
PokedexText_HeightWeight:
	db   "HT  ????", POKEDEX_m
	next "WT ?????", POKEDEX_k, POKEDEX_g
	text_end

PokedexText_Pokemon:
; feature/completion: printed immediately after the species category on row 4, so it
; needs a leading space (the category string ends with no trailing gap). Use the
; compact "Pk"/"Mn" ligature tiles ($e1/$e2) rather than the "#" POKéMON token, which
; expands to 7 columns and crowded the category off the row.
	db " <PK><MN>"
	text_end

PokedexButtonsGFX:
INCBIN "gfx/pokedex/buttons.2bpp"

PokedexPokeBallGFX:
INCBIN "gfx/pokedex/poke_ball.2bpp"

PokedexCursorGFX:
INCBIN "gfx/pokedex/cursor.2bpp"

PokedexBorderGFX:
INCBIN "gfx/pokedex/border.2bpp"

PokedexSearchGFX:
INCBIN "gfx/pokedex/search.2bpp"
