_AddEnemyMonToPlayerParty::
	ret ; dummied out via an early return
	ld a, [wPartyCount]
	cp PARTY_LENGTH
	jr c, .bigjump
	ld a, [wBoxCount]
	cp MONS_PER_BOX
	jr nc, .fullbox
	xor a
	ld [wEnemySubStatus5], a
	ld a, [wCurPartySpecies]
	ld [wTempEnemyMonSpecies], a
	callfar LoadEnemyMon
	call RecievePokemon
	predef SendMonIntoBox
	and $7F
	add a, $F7
	ld hl, wStringBuffer2
	ld [hli], a
	ld [hl], '@'
	ld hl, BoxCantHoldText
	call PrintText
	scf
	ret
.fullbox
	ld hl, BoxFullText
	call PrintText
	and a
	ret
.bigjump
	call RecievePokemon
	predef TryAddMonToParty
	scf
	ret

RecievePokemon:
	ld a, [wCurPartySpecies]
	push af
	ld [wNamedObjectIndexBuffer], a
	dec a
	ld c, a
	ld hl, wPokedexCaught
	ld b, SET_FLAG
	predef SmallFarFlagAction
	pop af
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	ld hl, RecievePokemonText
	jp PrintText

RecievePokemonText:
	text "<PLAYER> got"
	line "@"
	text_from_ram wStringBuffer1
	text "!@"
	sound_dex_fanfare_50_79
	text_end

BoxCantHoldText:
	text "The party is full!"
	line "@"
	text_from_ram wBoxMonNicknames
	text " went to"
	cont "the <PC> BOX!"
	done

BoxFullText:
	text "The party is full!"

	para "The BOX is full,"
	line "so nothing can be"
	cont "sent there!"

	para "Swap the BOX at a"
	line "# CENTER!"
	done
