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
; hWY is only a HRAM shadow -- VBlank copies it into the real rWY once per
; VBlank (home/vblank.asm), on its own schedule. Without waiting here, .Transfer
; below can start blanking vBGMap0 (via raw HBlank-timed writes, not through the
; VBlank-synced copy queue) before that copy has actually happened, i.e. before
; the window is really covering the screen on hardware -- corrupting the still-
; visible BG map and flashing a black band for the rest of that frame. One
; DelayFrame guarantees the freeze-frame is actually up before we touch it.
	call DelayFrame
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
; Blank vBGMap0 before the anchor moves onto it.
;
; feature/completion: this used to stage 128 bytes of '■' in wTileMapBackup and
; push them through Request2bpp eight times over. Request2bpp copies eight tiles
; per VBlank and spends one more frame draining the last chunk, so a 1024-byte
; fill cost *sixteen frames* -- a quarter of a second, on both halves of every
; single textbox (PrepareTextbox and TextboxCleanup both reanchor). That was the
; largest remaining part of the delay before a textbox opened.
;
; None of it is ever seen. The window map covers the screen for the whole
; reanchor, and the WaitBGMap that follows repaints the 20x18 region that
; SCX/SCY = 0 actually displays; only the off-screen margin of the map keeps what
; is written here. So the tiles can go straight into VRAM whenever the PPU is not
; in mode 3, which finishes the same 1024 bytes in well under one frame. (An
; interrupt landing between the test and the store could drop a byte; in the
; margin that is invisible, and anywhere visible it is overwritten below, so this
; loop does not need to run with interrupts off.)
	ld hl, vBGMap0
	ld de, TILEMAP_AREA
	ld b, '■'
.loop
	ldh a, [rSTAT]
	and STAT_BUSY
	jr nz, .loop
	ld [hl], b
	inc hl
	dec e
	jr nz, .loop
	dec d
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
;
; The order below is retail Gold's (pret/pokegold, LoadFonts_NoOAMUpdate.LoadGFX):
; extras, then drop the window, then the font. It matters more than any of the
; copying does. ReanchorBGMap_NoOAMUpdate parks a snapshot of the map in vBGMap1
; and sets hWY to 0, so the window covers the whole screen while vBGMap0 is
; blanked and repainted with the textbox in it; the box is only *seen* when hWY
; goes back to SCREEN_HEIGHT_PX. Doing that last -- after the font upload --
; meant the finished textbox sat hidden behind the window for the whole copy,
; and the box and its first line of text appeared together after a long pause.
;
; Revealing before the font restores the retail feel: the NPC turns, the box
; opens ~9 frames later, and the dialogue then fills it in. The font is copied
; into the walking-sprite half of VRAM, which nothing on screen is using while
; the objects are frozen, so uploading it in plain view is invisible -- only the
; box frame and its blank interior are drawn, and those live in vChars2 ($79 and
; $7f), above vExteriorTileset, untouched by anything the overworld loads.
	ld a, [wFontExtraInVRAM]
	and a
	jr nz, .extra_still_loaded
	call LoadFontExtra
	ld a, 1
	ld [wFontExtraInVRAM], a
.extra_still_loaded
	call UpdateSprites
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	call LoadFontPartial
	ret
