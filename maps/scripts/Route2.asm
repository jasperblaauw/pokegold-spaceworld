Route2_ScriptLoader::
	ld hl, Route2ScriptPointers
	call RunMapScript
	call WriteBackMapScriptNumber
	ret

Route2ScriptPointers::
	def_script_pointers
	script_pointer Route2Script, Route2NPCIDs, SCENE_ROUTE_2_DEFAULT

Route2NPCIDs:
	npc_id ROUTE_2_KIMONO_GIRL
	db -1

Route2SignPointers:
	dw Route2TextSign1

Route2_TextPointers::
	dw Route2Text2

Route2Script::
; feature/completion: the demo checked for the player standing at (9,6), in
; front of the ROUTE 2 gate, and ran Route2Text1 -- the rival's "turn back
; here" speech followed by `jp Init` (a soft reset), i.e. the end of the demo.
; That, plus the rival object itself blocking (8,6), sealed the gate. Both are
; gone; the gate's warps at (8,5)/(9,5) are now reachable.
	ld hl, Route2NPCIDs ;data
	ld de, Route2SignPointers ;start of textld pointers?
	call CallMapTextSubroutine
	ret

Route2Text1: ; unreferenced (the demo's end-of-demo rival, see Route2Script)
	ld hl, Route2TextString4
	call OpenTextbox
	call GBFadeOutToBlack
	jp Init

Route2Text2:
	ld hl, wRoute2Flags
	bit 1, [hl]
	jr nz, .Text2Jump ; already fought
	ld hl, Route2TextString1
	call OpenTextbox
	ld hl, wRoute2Flags
	set 1, [hl]
	ld a, TRAINER_KIMONO_GIRL
	ld [wOtherTrainerClass], a
if DEF(_GOLD)
	ld a, KIMONO_GIRL_KOUME
endc
if DEF(_SILVER)
	ld a, KIMONO_GIRL_TAMAO
endc
	ld [wOtherTrainerID], a
	ld hl, wOverworldFlags
	set OVERWORLD_PAUSE_MAP_PROCESSES_F, [hl]
	ld a, MAPSTATUS_START_TRAINER_BATTLE
	ld [wMapStatus], a
	ret

.Text2Jump
Route2Text3:
	ld hl, Route2TextString3
	call OpenTextbox
	ret

Route2TextSign1:
	ld hl, Route2TextString5
	call OpenTextbox
	ret

if DEF(_GOLD)
Route2TextString1:
	text "My, what a sweet"
	line "little TRAINER."
	cont "Care for a #"
	cont "battle with me?"
	done

Route2TextString2: ; (unused?)
	text "Oh my, do forgive"
	line "me!"
	done

Route2TextString3:
	text "Such a sweet face,"
	line "and yet so strong."
	cont "Do keep it up now."
	done
endc
if DEF(_SILVER)
Route2TextString1:
	text "My # are"
	line "ever so adorable,"
	cont "you know."
	done

Route2TextString2: ; (unused?)
	text "You can't be"
	line "serious!"
	cont "Really, what are"
	cont "you doing?"
	done

Route2TextString3:
	text "Poor little"
	line "JIGGLYPUFF."
	done
endc

Route2TextString4: ; unreferenced (see Route2Text1)
if DEF(_GOLD)
	text "SHIGERU: Oh, if it"
	line "isn't SATOSHI!"

	para "Looks like you"
	line "barely made it"
	cont "this far."
endc
if DEF(_SILVER)
	text "SATOSHI: Oh, if it"
	line "isn't SHIGERU!"
	cont "Looks like you"
	cont "barely made it"
	cont "this far."
endc
	para "Don't push it when"
	line "you haven't got"
	cont "the skill."

	para "Catch more #"
	line "and raise all"
	cont "sorts of them<⋯⋯>"
	cont "You've got things"
	cont "to do, right?"

	para "You'd best turn"
	line "back here!"
	cont "See you."
	done

Route2TextString5:
	text "ROUTE 2"
	line "SILENT HILL <⋯⋯>"
	cont "OLD CITY"
	done
