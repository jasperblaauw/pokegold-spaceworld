Route1_ScriptLoader::
	ld hl, Route1ScriptPointers
	call RunMapScript
	call WriteBackMapScriptNumber
	ret

Route1ScriptPointers::
	def_script_pointers
	script_pointer Route1Script, Route1NPCIDs, SCENE_ROUTE_1_DEFAULT

Route1NPCIDs:
	npc_id ROUTE_1_SUPER_NERD
	npc_id ROUTE_1_YOUNGSTER
	db -1

Route1SignPointers:
	dw Route1TextSign1
	dw Route1TextSign2

Route1_TextPointers::
	dw Route1TextNPC1
	dw Route1TextNPC2

Route1Script::
	ld hl, Route1NPCIDs
	ld de, Route1SignPointers
	call CallMapTextSubroutine
	ret

Route1TextNPC1:
	ld hl, Route1TextString1
	call OpenTextbox
	ret

Route1TextNPC2:
	ld hl, Route1TextString2
	call OpenTextbox
	ret

Route1TextSign1:
	ld hl, Route1TextString3
	call OpenTextbox
	ret

Route1TextSign2:
	ld hl, Route1TextString4
	call OpenTextbox
	ret

Route1TextString1:
	text "Hey, kid!"

	para "The basics of a"
	line "POKé BALL: weaken"
	cont "the wild # "
	cont "first, then throw!"
	done

Route1TextString2:
	text "On my way home"
	line "from cram school"
	cont "this evening, I"
	cont "saw an odd one!"
	done

Route1TextString3:
	text "QUIET HILL ahead."
	line "Watch out for"
	cont "wild #."
	done

Route1TextString4:
	text "ROUTE 1"
	line "SILENT HILL <⋯⋯>"
	cont "OLD CITY"
	done
