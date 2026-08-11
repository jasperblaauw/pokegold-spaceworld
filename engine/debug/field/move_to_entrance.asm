FieldDebug_MoveToRoute1Entrance:
; Check if the player is currently on Route 1
	ld a, [wMapGroup]
	cp GROUP_ROUTE_1
	jr nz, .cannot_use
	ld a, [wMapId]
	cp MAP_ROUTE_1
	jr nz, .cannot_use

	ldh a, [hROMBank]
	ld hl, .DoMove
	call QueueScript
	ld a, FIELDDEBUG_RETURN_EXIT
	ret

.cannot_use
	ld hl, .CantUseText
	call FieldDebug_ShowTextboxAndExit
	ld a, FIELDDEBUG_RETURN_REOPEN
	ret

.CantUseText:
	text "Can't use here."

	para "Use it on Route 1."
	done

.DoMove:
	call ReanchorMap
	ld hl, .MoveText
	call FieldDebug_ShowTextboxAndExit
	ld d, $d
	ld e, $d
	ld b, PLAYER_OBJECT
	ld c, STEP_WALK
	callfar ComputeObjectPathToCoords_Invisible
	ld a, PLAYER_OBJECT
	ld hl, wMovementBuffer
	call LoadMovementDataPointer
	call CloseText
	ret

.MoveText:
	text "Moving to a"
	next "set point..."
	done
