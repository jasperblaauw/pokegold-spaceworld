ReanchorBGMap_NoOAMUpdate::
	xor a
	ldh [hLCDCPointer], a
	ld hl, wToolgearFlags
	set 7, [hl] ; hide toolgear
	res 2, [hl] ; transfer toolgear to window
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	xor a
	ldh [hBGMapMode], a
	xor a
	ldh [hBGMapAddress], a
	ld a, HIGH(vBGMap1)
	ldh [hBGMapAddress+1], a
	call LoadMapPart
	call WaitBGMap
	xor a
	ldh [hBGMapMode], a
	ldh [hWY], a
	call .Transfer
	xor a ; LOW(vBGMap0)
	ld [wBGMapAnchor], a
	ld a, HIGH(vBGMap0)
	ldh [hBGMapAddress+1], a
	ld [wBGMapAnchor+1], a
	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	call WaitBGMap
	ret

.Transfer
	ld a, $60 ; blank tile?
	ld hl, wTileMapBackup
	ld bc, (SCREEN_WIDTH * 6) + 8
	call ByteFill
	ld hl, vBGMap0
	ld c, 8
.loop
	push bc
	push hl
	ld de, wTileMapBackup
	lb bc, BANK(wTileMapBackup), 8
	call Request2bpp
	pop hl
	ld bc, TILEMAP_WIDTH * 4
	add hl, bc
	pop bc
	dec c
	jr nz, .loop
	ret

LoadFonts_NoOAMUpdate::
; feature/completion: this is the tail of PrepareTextbox, and re-uploading the
; font and its extras here cost ~21 frames of VBlank-throttled tile copying
; (128 1bpp font tiles at 8 tiles per frame, plus 23 font-extra tiles and the
; textbox frame) -- about a third of a second of dead time before every single
; textbox.
;
; The two halves are not equally dirty, so they are tracked separately:
;
; - The font at vFont ($8800) genuinely cannot be kept. It shares that VRAM
;   with the overworld's walking sprite frames, and VRAM here is heavily
;   oversubscribed, so closing a textbox has to put the sprites back (see
;   TextboxCleanup -> LoadWalkingSpritesGFX). What *can* be avoided is copying
;   the whole thing: LoadOverworldSprite records how far into vFont it reached,
;   and only that much comes back. A map using every sprite slot dirties 120 of
;   the 128 tiles, but an interior with three or four sprites dirties ~48.
; - The font extras at vChars2 $60+ sit above vExteriorTileset and nothing in
;   the overworld writes there, so they survive from one textbox to the next
;   and only need reloading after a menu, battle or SGB transfer -- each of
;   which calls InvalidateVRAMFonts.
	call UpdateSprites
	call LoadFontPartial
	ld a, [wFontExtraInVRAM]
	and a
	jr nz, .extra_still_loaded
	call LoadFontExtra
	ld a, 1
	ld [wFontExtraInVRAM], a
.extra_still_loaded
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	ret
