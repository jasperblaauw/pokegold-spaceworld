BattleCommand_Foresight:
	ld hl, wEnemySubStatus1
	ldh a, [hBattleTurn]
	and a
	jr z, .got_substatus
	ld hl, wPlayerSubStatus1

.got_substatus
	ld a, [wAttackMissed]
	and a
	jr nz, .failed

	call CheckHiddenOpponent
	jr nz, .failed

	bit SUBSTATUS_IDENTIFIED, [hl]
	jr nz, .failed

	set SUBSTATUS_IDENTIFIED, [hl]
	call LoadMoveAnim
	ld hl, .IdentifiedText
	jp PrintText

.IdentifiedText:
	text "<USER>"
	line "identified"
	cont "<TARGET>!"
	prompt

.failed
	call BattleCommand_MoveDelay
	jp PrintButItFailed
