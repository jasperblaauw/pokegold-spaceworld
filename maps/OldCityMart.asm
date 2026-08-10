	map_attributes OldCityMart, OLD_CITY_MART

OldCityMart_MapEvents::
	dw $4000 ; unknown

	def_warp_events
	warp_event  4,  7, OLD_CITY, 8, 51
	warp_event  5,  7, OLD_CITY, 8, 51

	def_bg_events
	bg_event  0,  7, 1

	def_object_events
	object_event  1,  3, SPRITE_CLERK, SPRITEMOVEFN_TURN_RIGHT, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event 10,  5, SPRITE_YOUNGSTER, SPRITEMOVEFN_RANDOM_WALK_X, 2, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  4,  1, SPRITE_COOLTRAINER_M, SPRITEMOVEFN_TURN_UP, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0

OldCityMart_Blocks::
INCBIN "maps/Mart.blk"

	map_generic_scriptloader
	map_generic_script_pointers
	map_generic_script

	map_generic_npc_ids

OldCityMartSignPointers:
	dw OldCityMartSignText

OldCityMartSignText:
	ld hl, OldCityMartTextString1
	call OpenTextbox
	ret

OldCityMartTextString1:
	text "OLD CITY MART"
	line "Buy what you need"
	cont "before you go!"
	done

OldCityMart_TextPointers::
	dw OldCityMartNPCText1
	dw OldCityMartNPCText2
	dw OldCityMartNPCText3

; feature/completion: the first real, working mart -- shares RunMartBuyMenu
; (engine/debug/field/pokemart_menu.asm) with the debug field mart rather
; than duplicating the scrolling-list/quantity/purchase UI. Structure mirrors
; FieldDebug_PokemartMenu/.DoPokemartMenu: a welcome box that fully closes
; (prompt), then a separate menu-drawing routine -- not one continuous
; start_asm-nested text stream, since `prompt` ends the box and returns to
; the caller rather than falling through to more text data.
OldCityMartNPCText1:
	ld hl, OldCityMartTextString2
	call OpenTextbox
	call OldCityMartMenu
	ret

OldCityMartTextString2:
	text "Welcome to the"
	line "POKéMON MART!"
	prompt

OldCityMartMenu:
	call LoadStandardMenuHeader
	callfar PlaceMoneyTopRight
	ld hl, OldCityMartTextString3
	call PrintText
	ld hl, .MenuHeader
	call CopyMenuHeader
	call VerticalMenu
	push af
	call ExitMenu
	pop af
	jr c, .goodbye
	ld a, [wMenuCursorY]
	cp 1
	jr nz, .goodbye
	ld de, OldCityMartItemList
	callfar RunMartBuyMenu
	jp OldCityMartMenu

.goodbye
	ld hl, OldCityMartTextString4
	call MenuTextBoxBackup
	ret

.MenuHeader:
	db MENU_BACKUP_TILES
	menu_coords 0, 0, 10, 5
	dw .MenuData
	db 1 ; default

.MenuData:
	db STATICMENU_CURSOR
	db 2 ; items
	db "BUY@"
	db "CANCEL@"

OldCityMartTextString3:
	text "What can I do"
	line "for you?"
	done

OldCityMartTextString4:
	text "We hope to see"
	line "you again!"
	prompt

OldCityMartItemList:
	db ITEM_POKE_BALL
	db ITEM_POTION
	db ITEM_ANTIDOTE
	db ITEM_PARLYZ_HEAL
	db ITEM_AWAKENING
	db ITEM_BURN_HEAL
	db ITEM_ESCAPE_ROPE
	db ITEM_REPEL
	db -1

OldCityMartNPCText2:
	ld hl, OldCityMartTextString5
	call OpenTextbox
	ret

OldCityMartTextString5:
	text "This MART sells"
	line "all sorts of"
	cont "handy stuff!"
	done

OldCityMartNPCText3:
	ld hl, OldCityMartTextString6
	call OpenTextbox
	ret

OldCityMartTextString6:
	text "I always stock up"
	line "on POKé BALLS"
	cont "before a trip."
	done
