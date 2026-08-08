GetCurNick::
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames

GetNick::
; Get nickname a from a party-width list hl.
	ld bc, MON_NAME_LENGTH
	; fallthrough

GetNickWithWidth::
; Get nickname a from list hl, whose entries are bc bytes wide. Boxed-mon lists
; are still stored at the Japanese width, so their callers pass a BOX_MON_* width.
; bc carries that width through both the index and the copy; AddNTimes leaves it
; untouched.
	push hl
	push bc
	call AddNTimes
	ld de, wStringBuffer1
	push de
	call CopyBytes
	pop de
	callfar CorrectNickErrors
	pop bc
	pop hl
	ret
