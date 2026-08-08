	const_def 1
	const PINK_PAGE  ; 1
	const GREEN_PAGE ; 2
	const BLUE_PAGE  ; 3
DEF NUM_STAT_PAGES EQU const_value - 1

StatsScreenMain::
	ld a, [wCurPartySpecies]
	cp DEX_EGG
	jr z, .got_stats

	call CopyMonToTempMon
	ld a, [wMonType]
	cp BOXMON
	jr c, .got_stats

	ld a, [wTempMonLevel]
	ld [wCurPartyLevel], a
	ld hl, wTempMonExp + 2
	ld de, wTempMonMaxHP
	ld b, 1
	predef CalcMonStats

.got_stats
	ld hl, wPokedexMenuFlags
	set 1, [hl]
	call ClearBGPalettes
	call ClearTileMap
	call UpdateSprites
	callfar LoadPokemonStatsGraphics

	ldh a, [hMapAnims]
	push af
	xor a
	ldh [hMapAnims], a
	ld c, PINK_PAGE
	ld b, 0
	ld hl, LoadPinkPage
.StatsScreen_LoadPage
	push bc
	ld de, .done_loading
	push de
	jp hl

.done_loading
	pop bc
.joypad_loop
	call GetJoypadDebounced
	ldh a, [hJoySum]
	and PAD_LEFT | PAD_RIGHT | PAD_B | PAD_A
	jr z, .joypad_loop
	bit B_PAD_B, a
	jr nz, .b_button
	bit B_PAD_LEFT, a
	jr nz, .d_left
	inc c
	ld a, BLUE_PAGE
	cp c
	jr nc, .StatsScreen_JumpToLoadPageFunction
	ld c, PINK_PAGE
	jr .StatsScreen_JumpToLoadPageFunction

.d_left
	dec c
	jr nz, .StatsScreen_JumpToLoadPageFunction
	ld c, BLUE_PAGE
.StatsScreen_JumpToLoadPageFunction
	ld hl, .StatsScreen_LoadPageJumptable
	dec c
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc c
	ld b, 1
	jr .StatsScreen_LoadPage

.b_button
	call ClearBGPalettes
	pop af
	ldh [hMapAnims], a
	ret

.StatsScreen_LoadPageJumptable
	table_width 2
	dw LoadPinkPage
	dw LoadGreenPage
	dw LoadBluePage
	assert_table_length NUM_STAT_PAGES

LoadPinkPage::
	call WaitBGMap
	xor a
	ldh [hBGMapMode], a
	ld a, [wMonHIndex]
	ld [wMoveGrammar], a
	ld [wCurSpecies], a
.draw_page
	push bc
; The divider is redrawn on every page load, not just the first: the green
; page's move-list box has to be wide enough for English move names, so its
; left border covers column 7. It now skips rows 10-11, where the nickname and
; the species name run the full width of the screen — a 10-character English
; name does not fit in the 7-column strip left of the divider.
	ld bc, SCREEN_WIDTH
	hlcoord 7, 0
	ld d, 10
	call StatsScreen_DrawDividerRun
	hlcoord 7, 12
	ld d, SCREEN_HEIGHT - 12
	call StatsScreen_DrawDividerRun

	ld b, 1
	call StatsScreen_LoadPageIndicators
	hlcoord 8, 0
	lb bc, SCREEN_HEIGHT, SCREEN_WIDTH - 8
	call ClearBox

; Everything below used to be drawn only on the first load. ClearBox above wipes
; columns 8-19 on every row, so the two full-width name rows would be erased
; when paging away and back; the whole tilemap is now redrawn each page load.
	hlcoord 1, 0
	ld [hl], '・'
	inc hl
	ld [hl], '．'
	inc hl

	ld de, wMoveGrammar
	lb bc, PRINTNUM_LEADINGZEROS | 1, 3
	call PrintNumber
	hlcoord 1, 8
	call PrintLevel
; The gender symbol goes one column right of the level tag (columns 1-3) rather
; than trailing the nickname. GetBaseData has to run first: wCurSpecies is
; already this mon's, but nothing before this point has loaded its header —
; PrintMonTypes does its own call further down.
	call GetBaseData
	ld hl, wTempMonDVs
	call GetGenderChar
	hlcoord 5, 8
	ld [hl], a

	ld hl, NicknamePointers
	ld e, MON_NAME_LENGTH
	call GetNicknamePointer
	ld d, h
	ld e, l
	hlcoord 1, 10
	call PlaceString
	hlcoord 1, 11
	ld a, '／'
	ld [hli], a
	ld a, [wMonHIndex]
	ld [wMoveGrammar], a
	call GetPokemonName
	call PlaceString
; The page row was four tiles: the ◀/▶ arrows ($32/$35) around a two-tile "ページ"
; graphic ($33/$34). "PAGE" needs four columns of ordinary font, so the arrows
; move out to columns 1 and 6 — still inside this page's 7-column left strip.
	hlcoord 1, 16
	ld [hl], $32 ; ◀
	hlcoord 2, 16
	ld de, StatsText_Page
	call PlaceString
	hlcoord 6, 16
	ld [hl], $35 ; ▶

	hlcoord 10, 1
	ld b, 0
	call DrawPlayerHP

	hlcoord 18, 1
	ld [hl], $41

	ld hl, wCurHPPal
	call SetHPPal
	ld b, SGB_STATS_SCREEN_HP_PALS
	call GetSGBLayout

	hlcoord 9, 4
	ld de, StatusText_StatusType
	call PlaceString

	hlcoord 16, 4
	ld a, [wMonType]
	cp 2
	jr z, .StatusOK
	push hl
	ld de, wTempMonStatus
	call PlaceStatusString
	pop hl
.StatusOK
	ld de, StatusText_OK
	call z, PlaceString
; Type names print in full and reach 8 characters (FIGHTING / ELECTRIC), so
; they go on the rows below the "TYPE/" label rather than beside it.
	hlcoord 11, 7
	call PrintMonTypes

; The EXP box moved down two rows (top border 10 -> 12) to free rows 10-11 for
; the full-width name rows above. Its four interior rows (13-16) still hold the
; same five items: the "EXP POINTS" title sits on the top border as before.
	hlcoord 8, 12
	ld b, 4
	ld c, 10
	call DrawTextBox

	hlcoord 9, 12
	ld de, StatusText_ExpPoints
	call PlaceString

	ld a, [wTempMonLevel]
	push af
	cp MAX_LEVEL
	jr z, .got_level

	inc a
	ld [wTempMonLevel], a
.got_level
	hlcoord 16, 14
	call PrintLevel

	pop af
	ld [wTempMonLevel], a
	ld de, wTempMonExp
	hlcoord 12, 13
	lb bc, 3, 7
	call PrintNumber

	call .CalcExpToNextLevel
	ld de, wExpToNextLevel
	hlcoord 10, 15
	lb bc, 3, 7
	call PrintNumber

	hlcoord 9, 14
	ld de, StatusText_Ato
	call PlaceString

	ld a, [wTempMonLevel]
	ld b, a
	ld de, wTempMonExp + 2
	hlcoord 10, 16
	predef CalcAndPlaceExpBar

	hlcoord 9, 16
	ld [hl], $40
	hlcoord 18, 16
	ld [hl], $41
	call WaitBGMap

	ld a, 1
	ldh [hBGMapMode], a
	pop bc
	ld a, b
	and a
	ret nz

	call SetDefaultBGPAndOBP
	ld hl, wTempMonDVs
	call GetUnownLetter

	hlcoord 0, 1
	call PrepMonFrontpic
	ld a, [wCurPartySpecies]
	call PlayCry
	ret

.CalcExpToNextLevel::
	ld a, [wTempMonLevel]
	cp MAX_LEVEL
	jr z, .AlreadyAtMaxLevel
	inc a
	ld d, a
	call CalcExpAtLevel
	ld hl, wTempMonExp + 2
	ld hl, wTempMonExp + 2    ; Seemingly an unnecessary duplicate line
	ldh a, [hQuotient + 3]
	sub [hl]
	dec hl
	ld [wExpToNextLevel + 2], a
	ldh a, [hQuotient + 2]
	sbc [hl]
	dec hl
	ld [wExpToNextLevel + 1], a
	ldh a, [hQuotient + 1]
	sbc [hl]
	ld [wExpToNextLevel], a
	ret

.AlreadyAtMaxLevel
	ld hl, wExpToNextLevel
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret

NicknamePointers:
	dw wPartyMonNicknames, wOTPartyMonNicknames, wBoxMonNicknames, wBufferMonNickname

StatusText_StatusType:
	db   "STATUS/"
	next "TYPE/@"

StatusText_OK:
	db "OK@"

StatsText_Page:
	db "PAGE@"

StatusText_ExpPoints:
	db "EXP POINTS@"

StatusText_Ato:
; Labels the row above the remaining-EXP figure; PrintLevel puts the level it
; counts towards on the same row. The Japanese layout's trailing "で" particle
; (StatusText_De) has no English equivalent and was dropped.
	db "TO NEXT@"

LoadGreenPage::
	call WaitBGMap
	xor a
	ldh [hBGMapMode], a
	ld b, GREEN_PAGE
	call StatsScreen_LoadPageIndicators

	hlcoord 8, 0
	lb bc, SCREEN_HEIGHT, SCREEN_WIDTH - 8
	call ClearBox

	hlcoord 8, 1
	ld de, .Item
	call PlaceString

	ld a, [wTempMonItem]
	and a
	ld de, .NoItem
	jr z, .got_item_name
	ld [wNamedObjectIndexBuffer], a
	call GetItemName
.got_item_name
; Item names are up to ITEM_NAME_LENGTH - 1 = 12 characters, so they start at
; the left edge of the right-hand column.
	hlcoord 8, 2
	call PlaceString

	ld hl, wTempMonMoves
	ld de, wListMoves_MoveIndicesBuffer
	ld bc, NUM_MOVES
	call CopyBytes

; Widened one column to the left (the divider column, which LoadPinkPage
; redraws) so that 12-character English move names fit the interior.
	hlcoord 7, 4
	ld b, 12
	ld c, 11
	call DrawTextBox

	hlcoord 11, 4
	ld de, .Moves
	call PlaceString

	hlcoord 8, 6
	ld a, SCREEN_WIDTH * 3
	ld [wListMovesLineSpacing], a
	call ListMoves

	hlcoord 10, 7
	ld a, SCREEN_WIDTH * 3
	ld [wListMovesLineSpacing], a
	call ListMovePP

	call WaitBGMap
	ld a, 1
	ldh [hBGMapMode], a
	ret

.Item
	db "ITEM@"

.NoItem
	db "NONE@"

.Moves
	db "MOVES@"

LoadBluePage::
	call WaitBGMap
	xor a
	ldh [hBGMapMode], a
	ld b, BLUE_PAGE
	call StatsScreen_LoadPageIndicators

	hlcoord 8, 0
	lb bc, SCREEN_HEIGHT, SCREEN_WIDTH - 8
	call ClearBox

	hlcoord 9, 1
	ld de, .IDNo_OT
	call PlaceString

	hlcoord 12, 1
	ld de, wTempMonID
	lb bc, PRINTNUM_LEADINGZEROS | 2, 5
	call PrintNumber

	ld hl, .OTPointers
	ld e, PLAYER_NAME_LENGTH
	call GetNicknamePointer

	ld de, wStringBuffer1
	push de
	ld bc, PLAYER_NAME_LENGTH
	call CopyBytes

	pop de
	callfar CorrectNickErrors
	hlcoord 12, 3
	call PlaceString

	ld d, 0
	call PrintTempMonStats
	hlcoord 10, 6
	ld de, .Parameters
	call PlaceString

	call WaitBGMap
	ld a, 1
	ldh [hBGMapMode], a
	ret

.IDNo_OT
; Both labels are kept to 3 columns: the ID number (5 digits) and the OT name
; are both placed at column 12, immediately to the right.
	db   "ID/"
	next "OT/"
	next "@"

.Parameters
	db "STATS@"

.OTPointers
	dw wPartyMonOTs
	dw wOTPartyMonOT
	dw wBoxMonOTs
	dw wBufferMonOT

; Draws d rows of the vertical divider downwards from hl. bc must be SCREEN_WIDTH.
StatsScreen_DrawDividerRun:
	ld a, $31
	ld [hl], a
	add hl, bc
	dec d
	jr nz, StatsScreen_DrawDividerRun
	ret

StatsScreen_LoadPageIndicators::
	hlcoord 1, 14
	ld a, $36
	call .load_square
	hlcoord 3, 14
	ld a, $36
	call .load_square
	hlcoord 5, 14
	ld a, $36
	call .load_square
	ld a, b
	cp GREEN_PAGE
	ld a, $3a
	hlcoord 3, 14
	jr c, .load_square
	hlcoord 5, 14
	jr z, .load_square
	hlcoord 1, 14
.load_square
	ld [hli], a
	inc a
	ld [hld], a
	push bc
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	inc a
	ld [hli], a
	inc a
	ld [hl], a
	ret

; hl = a table of four list pointers indexed by wMonType; e = the entry width of
; that table's PARTYMON / OTPARTYMON lists. This routine serves both the nickname
; tables (MON_NAME_LENGTH) and the OT tables (PLAYER_NAME_LENGTH), which are no
; longer the same width, so the caller has to say which it is passing. BOXMON
; lists are still stored at the Japanese width, and TEMPMON is a single buffer
; with no index.
GetNicknamePointer::
	ld a, [wMonType]
	add a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wMonType]
	cp TEMPMON
	ret z
	cp BOXMON
	jr nz, .got_width
	ld e, BOX_MON_NAME_LENGTH
.got_width
	ld b, 0
	ld c, e
	ld a, [wCurPartyMon]
	jp AddNTimes
