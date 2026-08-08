; Leftovers from a deleted map?
DeletedMap_ScriptLoader:
	ret

DeletedMap_TextPointers:
	dw DeletedMapText1

DeletedMapText1:
	text "What a convenient"
	line "world we live in."
	done

DeletedMap_TextPointers2:
rept 9
	ret
endr
